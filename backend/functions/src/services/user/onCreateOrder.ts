// --- Function callable onCreateOrder ---
//
// Davi da Cruz Shieh - 24798076 (original primary-market flow, now moved
//   to onBuyFromStartup.ts)
// Pedro Henrique Medeiros dos Reis - 24801656 (P2P balcão / matching engine)
// Creates a P2P order in the balcão and crosses compatible opposing offers
// inside a single Firestore transaction when possible.

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {getWallet, createWallet} from '../../db/wallets/storage';
import {getStartup} from '../../db/startups/storage';
import {recordTransaction} from '../../db/transactions/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import db from '../../configs';


// --- ERRORS ---
import {AuthError} from '../../errors/authError';
import {ValidationError} from '../../errors/validationError';
import {NotFoundError} from '../../errors/notFoundError';
import {InternalError} from '../../errors/internalError';


// --- TYPES ---
import type {CallableRequest} from 'firebase-functions/v2/https';
import type {OrderDocument, OrderType} from '../../db/orders/model';
import {CreateOrderRequest} from '../../types/responders/investment';
import {parseRequest} from '../../utils/validation';


// --- CONSTANTS ---

// max opposing offers walked per matching transaction. Pulling a few more than
// the cap leaves room to drop the author's own offers (self-trade guard) and
// still satisfy the cap.
const PULL_LIMIT  = 60;
const MATCH_DEPTH = 50;
const MIN_PRICE_FACTOR = 0.5;
const MAX_PRICE_FACTOR = 1.5;
const MAX_ORDER_TOTAL  = 100000;


// --- CODE ---

/**
 * I describe one trade decided by the walking-the-book loop.
 */
interface PlannedTrade
{
    counter:    OrderDocument;
    tradeQty:   number;
    tradePrice: number;
}


/**
 * I describe what the transaction returns so the outer code can record audit
 * trail entries and respond to the caller.
 */
interface MatchOutcome
{
    orderId:     string;
    status:      OrderDocument['status'];
    filled:      number;
    remaining:   number;
    totalAmount: number;
    avgPrice:    number | null;
    completedAt: Date | null;
    trades:      Array<{counterUid: string; tradeQty: number; tradePrice: number}>;
}


/**
 * I compute the available token balance of a user for a given startup based on
 * their order history. Owned = completed buys − completed/cancelled sell fills;
 * reserved = pending sell remaining. Available = owned − reserved.
 *
 * @param orders every order the user has for the startup (any type, any status)
 *
 * @returns number of tokens the user can still place a new sell order against
 */
function computeAvailableTokens(orders: OrderDocument[]): number
{
    let owned    = 0;
    let reserved = 0;

    for (const o of orders)
    {
        const filled = o.filled_quantity ?? 0;

        if (o.type === 'buy')
        {
            // Any filled buy increases owned tokens, regardless of status (pending, completed, cancelled)
            owned += filled;
        }
        else if (o.type === 'sell')
        {
            // Any filled sell decreases owned tokens, regardless of status
            owned -= filled;

            // Pending sells reserve their remaining unfilled portion
            if (o.status === 'pending')
            {
                reserved += (o.quantity - filled);
            }
        }
    }

    return owned - reserved;
}


/**
 * I decide whether an incoming order at `myPrice` crosses an opposing order at
 * `oppPrice`. Buy crosses sell when buy ≥ sell; sell crosses buy when sell ≤ buy.
 *
 * @param type     the incoming order side
 * @param myPrice  price of the incoming order
 * @param oppPrice price of the existing opposing offer
 *
 * @returns true if a trade is allowed
 */
function crosses(type: OrderType, myPrice: number, oppPrice: number): boolean
{
    return type === 'buy' ? oppPrice <= myPrice : oppPrice >= myPrice;
}


/**
 * I handle the onCreateOrder callable.
 * Creates a P2P (balcão) order. If there are compatible opposing offers in
 * the book the order is matched against them inside a single Firestore
 * transaction; whatever remains becomes a pending offer.
 *
 * Flow:
 *   1. Validate auth + input.
 *   2. Verify startup exists; pre-provision author wallet so the tx can read it.
 *   3. Inside runTransaction:
 *      a. Read author wallet, top opposing offers, author's previous orders
 *         for this startup (used for sell-side holdings validation).
 *      b. Pre-validate by side: enough balance for buy, enough tokens for sell.
 *      c. Read the wallet of each counter party found in step (a).
 *      d. Walk the book: for each compatible opposing order, accumulate a
 *         trade. Stop when the new order is fully filled or no more crossing
 *         offers exist.
 *      e. Writes: update each crossed order, debit/credit each affected
 *         wallet, create the new order doc (status completed if fully filled,
 *         else pending with filled_quantity recorded).
 *   4. Outside the transaction: record an audit-trail transaction for each
 *      trade (best-effort, does not roll back).
 *
 * @param request callable request with `startupId`, `type` ('buy'|'sell'),
 *   `quantity` and `unitPrice` (limit price)
 *
 * @returns `{orderId, status, filled, remaining, totalAmount, avgPrice,
 *   completedAt, trades}`
 *
 * @throws HttpsError('unauthenticated')  if the caller is not signed in
 * @throws HttpsError('not-found')        if the startup does not exist
 * @throws HttpsError('invalid-argument') if balance is insufficient for buy
 *   side, or available tokens are insufficient for sell side
 */
export async function handleOnCreateOrder(request: CallableRequest)
{
    try
    {
        // verify authentication and extract uid
        const uid = verifyAuth(request);

        // validate request
        const {startupId, type, quantity, unitPrice} =
            parseRequest(CreateOrderRequest, request.data);

        // verify startup exists before touching anything else
        logger.info(`Fetching startup "${startupId}" for P2P order...`);
        const startup = await getStartup(startupId);
        if (startup === null)
        {
            throw new NotFoundError(`Startup "${startupId}" not found.`);
        }

        const marketPrice = startup.token_price;
        const minPrice = Math.round(marketPrice * MIN_PRICE_FACTOR * 100) / 100;
        const maxPrice = Math.round(marketPrice * MAX_PRICE_FACTOR * 100) / 100;
        const totalAmount = quantity * unitPrice;

        if (unitPrice < minPrice || unitPrice > maxPrice)
        {
            throw new ValidationError(
                `Price outside allowed range. Use a price between ${minPrice} and ${maxPrice}.`,
            );
        }

        if (totalAmount > MAX_ORDER_TOTAL)
        {
            throw new ValidationError(
                `Order total exceeds the limit of ${MAX_ORDER_TOTAL}.`,
            );
        }

        // pre-provision author wallet so it is guaranteed to exist when the tx reads it
        const existingWallet = await getWallet(uid);
        if (existingWallet === null)
        {
            await createWallet(uid);
        }

        // run the matching transaction
        const outcome = await db.runTransaction(async (tx): Promise<MatchOutcome> =>
        {
            // --- READS PHASE ---

            const walletRef     = db.collection('wallets').doc(uid);
            const opposingType: OrderType = type === 'buy' ? 'sell' : 'buy';

            // top opposing offers, ordered by best price first
            const opposingDirection: FirebaseFirestore.OrderByDirection =
                opposingType === 'sell' ? 'asc' : 'desc';

            const opposingQuery = db.collection('orders')
                .where('startup_id', '==', startupId)
                .where('type', '==', opposingType)
                .where('status', '==', 'pending')
                .orderBy('unit_price', opposingDirection)
                .limit(PULL_LIMIT);

            // author's full order history for this startup (validates sell holdings)
            const authorOrdersQuery = db.collection('orders')
                .where('uid', '==', uid)
                .where('startup_id', '==', startupId);

            // author's active pending buy orders across all startups (validates available BRL balance)
            const authorPendingBuysQuery = db.collection('orders')
                .where('uid', '==', uid)
                .where('type', '==', 'buy')
                .where('status', '==', 'pending');

            const [walletSnap, opposingSnap, authorOrdersSnap, pendingBuysSnap] = await Promise.all([
                tx.get(walletRef),
                tx.get(opposingQuery),
                tx.get(authorOrdersQuery),
                tx.get(authorPendingBuysQuery),
            ]);

            const authorBalance = (walletSnap.data()?.balance as number) ?? 0;

            // Calculate BRL locked in pending buy orders
            let lockedBrl = 0;
            for (const doc of pendingBuysSnap.docs)
            {
                const o = doc.data() as OrderDocument;
                const remainingQty = o.quantity - (o.filled_quantity ?? 0);
                lockedBrl += remainingQty * o.unit_price;
            }
            const availableBrl = authorBalance - lockedBrl;

            // drop the author's own offers (self-trade guard), then cap to the matching depth
            const opposing: OrderDocument[] = opposingSnap.docs
                .map(d => d.data() as OrderDocument)
                .filter(o => o.uid !== uid)
                .slice(0, MATCH_DEPTH);

            const authorOrders: OrderDocument[] = authorOrdersSnap.docs
                .map(d => d.data() as OrderDocument);

            // pre-validation by side
            if (type === 'sell')
            {
                const available = computeAvailableTokens(authorOrders);
                if (available < quantity)
                {
                    throw new ValidationError(
                        `Not enough tokens to sell. Requested: ${quantity}, ` +
                        `available: ${available}.`,
                    );
                }
            }
            else
            {
                // worst-case cost for a limit-price buy is quantity * unitPrice
                // (we may end up paying less if we cross better offers)
                const maxCost = quantity * unitPrice;
                if (availableBrl < maxCost)
                {
                    throw new ValidationError(
                        `Insufficient balance. Required up to ${maxCost}, ` +
                        `available: ${availableBrl} (balance: ${authorBalance}, locked: ${lockedBrl}).`,
                    );
                }
            }

            // read counter-party wallets in parallel (still in the reads phase)
            const counterUids = Array.from(new Set(opposing.map(o => o.uid)));

            const counterWalletEntries = await Promise.all(
                counterUids.map(async (cuid) =>
                {
                    const ref  = db.collection('wallets').doc(cuid);
                    const snap = await tx.get(ref);
                    return {
                        balance: snap.exists ? (snap.data()!.balance as number) : 0,
                        exists:  snap.exists,
                        ref,
                        uid:     cuid,
                    };
                }),
            );

            const walletByUid = new Map<string, {
                ref:     FirebaseFirestore.DocumentReference;
                balance: number;
            }>();
            for (const entry of counterWalletEntries)
            {
                if (entry.exists)
                {
                    walletByUid.set(entry.uid, {balance: entry.balance, ref: entry.ref});
                }
            }

            // --- WALK THE BOOK ---

            const trades: PlannedTrade[] = [];
            let remaining = quantity;
            const buyerBalances = new Map<string, number>();
            const now            = new Date();

            for (const opp of opposing)
            {
                if (remaining === 0) break;

                // book is sorted by best price first — once we stop crossing,
                // every following offer is worse, so we can break
                if (!crosses(type, unitPrice, opp.unit_price)) break;

                // skip if counter wallet doesn't exist (should be rare)
                if (!walletByUid.has(opp.uid)) continue;

                const oppRemaining = opp.quantity - (opp.filled_quantity ?? 0);
                if (oppRemaining <= 0) continue;

                const tradeQty   = Math.min(remaining, oppRemaining);
                const tradePrice = opp.unit_price;
                const tradeAmount = tradeQty * tradePrice;

                // If incoming is sell, counter is buyer. Validate counterparty buyer balance.
                if (type === 'sell')
                {
                    const buyerWallet = walletByUid.get(opp.uid)!;
                    const currentBal = buyerBalances.has(opp.uid)
                        ? buyerBalances.get(opp.uid)!
                        : buyerWallet.balance;

                    if (currentBal < tradeAmount)
                    {
                        // Mark the counterparty order as failed due to insufficient funds
                        const oppRef = db.collection('orders').doc(opp.id);
                        tx.update(oppRef, {
                            status: 'failed',
                            failure_reason: 'Insufficient buyer balance during P2P matching',
                            completed_at: now,
                        });
                        continue;
                    }
                    buyerBalances.set(opp.uid, currentBal - tradeAmount);
                }

                trades.push({counter: opp, tradePrice, tradeQty});
                remaining -= tradeQty;
            }

            // --- RESOLVE USER DOC IDS AND INVESTMENTS (READS) ---
            const matchedCounterUids = Array.from(new Set(trades.map(t => t.counter.uid)));
            const allUidsToResolve = Array.from(new Set([uid, ...matchedCounterUids]));

            const userDocIdByUid = new Map<string, string>();
            const chunks: string[][] = [];
            for (let i = 0; i < allUidsToResolve.length; i += 30)
            {
                chunks.push(allUidsToResolve.slice(i, i + 30));
            }
            
            const snaps = await Promise.all(
                chunks.map(chunk => tx.get(db.collection('users').where('uid', 'in', chunk)))
            );
            
            for (const snap of snaps)
            {
                for (const doc of snap.docs)
                {
                    const data = doc.data();
                    if (data && data.uid)
                    {
                        userDocIdByUid.set(data.uid, doc.id);
                    }
                }
            }

            const authorDocId = userDocIdByUid.get(uid);
            if (!authorDocId)
            {
                throw new ValidationError(`Author user document for "${uid}" not found.`);
            }

            const investmentRefs = allUidsToResolve.map(cuid =>
            {
                const docId = userDocIdByUid.get(cuid);
                if (!docId) return null;
                return {
                    ref: db.collection('users').doc(docId).collection('investments').doc(startupId),
                    uid: cuid,
                };
            }).filter((x): x is {uid: string; ref: FirebaseFirestore.DocumentReference} => x !== null);

            const investmentSnaps = await Promise.all(
                investmentRefs.map(async (item) =>
                {
                    const snap = await tx.get(item.ref);
                    return {
                        ref: item.ref,
                        snap,
                        uid: item.uid,
                    };
                }),
            );

            const investmentByUid = new Map<string, {
                ref: FirebaseFirestore.DocumentReference;
                exists: boolean;
                data: any;
            }>();

            for (const item of investmentSnaps)
            {
                investmentByUid.set(item.uid, {
                    data: item.snap.exists ? item.snap.data() : null,
                    exists: item.snap.exists,
                    ref: item.ref,
                });
            }

            // --- WRITES PHASE ---

            let totalFilledQty   = 0;
            let totalAmount      = 0;
            let authorBalanceAfter = authorBalance;

            for (const trade of trades)
            {
                const tradeAmount = trade.tradeQty * trade.tradePrice;
                totalFilledQty += trade.tradeQty;
                totalAmount    += tradeAmount;

                // 1) update the crossed (counter) order (using weighted average fill price)
                const counterRef       = db.collection('orders').doc(trade.counter.id);
                const prevFilled       = trade.counter.filled_quantity ?? 0;
                const prevAvgPrice     = trade.counter.avg_fill_price ?? 0;
                const newCounterFilled = prevFilled + trade.tradeQty;
                const newAvgPrice = prevFilled > 0
                    ? ((prevFilled * prevAvgPrice) + (trade.tradeQty * trade.tradePrice)) / newCounterFilled
                    : trade.tradePrice;

                const counterUpdate: Partial<OrderDocument> = {
                    avg_fill_price:  newAvgPrice,
                    filled_quantity: newCounterFilled,
                };
                if (newCounterFilled === trade.counter.quantity)
                {
                    counterUpdate.status       = 'completed';
                    counterUpdate.completed_at = now;
                }
                tx.update(counterRef, counterUpdate);

                // 2) move money: buyer pays, seller receives
                const counterWallet = walletByUid.get(trade.counter.uid)!;
                if (type === 'buy')
                {
                    // author = buyer → author debited, counter (seller) credited
                    authorBalanceAfter   -= tradeAmount;
                    counterWallet.balance += tradeAmount;
                }
                else
                {
                    // author = seller → author credited, counter (buyer) debited
                    authorBalanceAfter   += tradeAmount;
                    counterWallet.balance -= tradeAmount;
                }
                tx.update(counterWallet.ref, {
                    balance:    counterWallet.balance,
                    updated_at: now,
                });
            }

            // 3) write the author's wallet once after all trades
            if (trades.length > 0)
            {
                tx.update(walletRef, {
                    balance:    authorBalanceAfter,
                    updated_at: now,
                });
            }

            // 3b) update users/{userId}/investments for all involved users
            const userInvestmentState = new Map<string, {
                qty: number;
                avgPrice: number;
                totalCostPaidForBuys: number;
                totalQtyBought: number;
                totalQtySold: number;
            }>();

            for (const cuid of allUidsToResolve)
            {
                const inv = investmentByUid.get(cuid);
                let qty = 0;
                let avgPrice = 0;
                if (inv && inv.exists)
                {
                    qty = (inv.data.token_quantity as number) ?? 0;
                    avgPrice = (inv.data.avg_purchase_price as number) ?? 0;
                }
                userInvestmentState.set(cuid, {
                    avgPrice,
                    qty,
                    totalCostPaidForBuys: 0,
                    totalQtyBought: 0,
                    totalQtySold: 0,
                });
            }

            for (const trade of trades)
            {
                const tradeAmount = trade.tradeQty * trade.tradePrice;

                // Author side
                const authorState = userInvestmentState.get(uid)!;
                if (type === 'buy')
                {
                    authorState.totalQtyBought += trade.tradeQty;
                    authorState.totalCostPaidForBuys += tradeAmount;
                }
                else
                {
                    authorState.totalQtySold += trade.tradeQty;
                }

                // Counter party side
                const counterState = userInvestmentState.get(trade.counter.uid)!;
                if (type === 'buy')
                {
                    // Counter is seller
                    counterState.totalQtySold += trade.tradeQty;
                }
                else
                {
                    // Counter is buyer
                    counterState.totalQtyBought += trade.tradeQty;
                    counterState.totalCostPaidForBuys += tradeAmount;
                }
            }

            for (const [cuid, state] of userInvestmentState.entries())
            {
                if (state.totalQtyBought === 0 && state.totalQtySold === 0)
                {
                    continue;
                }

                const inv = investmentByUid.get(cuid);
                if (!inv) continue;
                const newQty = state.qty + state.totalQtyBought - state.totalQtySold;

                if (newQty <= 0)
                {
                    if (inv.exists)
                    {
                        tx.delete(inv.ref);
                    }
                }
                else
                {
                    let newAvgPrice = state.avgPrice;
                    if (state.totalQtyBought > 0)
                    {
                        const oldTotalCost = state.qty * state.avgPrice;
                        newAvgPrice = (oldTotalCost + state.totalCostPaidForBuys) / (state.qty + state.totalQtyBought);
                    }

                    if (inv.exists)
                    {
                        tx.update(inv.ref, {
                            avg_purchase_price: newAvgPrice,
                            token_quantity:     newQty,
                            updated_at:         now,
                        });
                    }
                    else
                    {
                        const startupName = startup.name;
                        const startupLogo = startup.logo_url ?? '';

                        tx.set(inv.ref, {
                            avg_purchase_price: newAvgPrice,
                            created_at:         now,
                            startup_id:         startupId,
                            startup_logo_url:   startupLogo,
                            startup_name:       startupName,
                            token_quantity:     newQty,
                            updated_at:         null,
                        });
                    }
                }
            }

            // 4) create the new order document
            const orderRef    = db.collection('orders').doc();
            const fullyFilled = remaining === 0;
            const avgPrice    = totalFilledQty > 0
                ? totalAmount / totalFilledQty
                : null;

            const newOrder: OrderDocument = {
                id:              orderRef.id,
                uid,
                startup_id:      startupId,
                type,
                status:          fullyFilled ? 'completed' : 'pending',
                quantity,
                unit_price:      unitPrice,
                total_amount:    quantity * unitPrice,
                created_at:      now,
                completed_at:    fullyFilled ? now : null,
                failure_reason:  null,
                filled_quantity: totalFilledQty,
                cancelled_at:    null,
                avg_fill_price:  avgPrice,
            };
            tx.set(orderRef, newOrder);

            return {
                orderId:     orderRef.id,
                status:      newOrder.status,
                filled:      totalFilledQty,
                remaining,
                totalAmount,
                avgPrice,
                completedAt: newOrder.completed_at,
                trades:      trades.map(t => ({
                    counterUid: t.counter.uid,
                    tradeQty:   t.tradeQty,
                    tradePrice: t.tradePrice,
                })),
            };
        });

        // --- AUDIT TRAIL (best-effort, outside the tx) ---

        // record one transaction entry per side of each trade
        for (const trade of outcome.trades)
        {
            const amt = trade.tradeQty * trade.tradePrice;

            try
            {
                // author's side
                await recordTransaction(uid, {
                    amount:      amt,
                    description: type === 'buy'
                        ? `Compra no balcão — ${startup.name}`
                        : `Venda no balcão — ${startup.name}`,
                    status:      'completed',
                    type,
                });

                // counter party's side (mirrored)
                await recordTransaction(trade.counterUid, {
                    amount:      amt,
                    description: type === 'buy'
                        ? `Venda no balcão — ${startup.name}`
                        : `Compra no balcão — ${startup.name}`,
                    status:      'completed',
                    type:        type === 'buy' ? 'sell' : 'buy',
                });
            }
            catch (e)
            {
                logger.warning(`Failed to record audit transaction for order "${outcome.orderId}": ${e}`);
            }
        }

        logger.info(
            `Order "${outcome.orderId}" created (type=${type}). ` +
            `Filled ${outcome.filled}/${quantity}, ${outcome.trades.length} trade(s).`,
        );

        return outcome;
    }

    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }
        if (error instanceof ValidationError)
        {
            logger.error(error.message);
            throw new HttpsError('invalid-argument', error.message);
        }
        if (error instanceof NotFoundError)
        {
            logger.error(error.message);
            throw new HttpsError('not-found', error.message);
        }

        const internal = new InternalError('Failed to create order.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
