// --- Function callable onBuyFromStartup ---
//
// Pedro Henrique Medeiros dos Reis - 24801656
// Primary-market purchase: buys tokens directly from the startup using the
// bonding-curve price. The P2P matching engine now lives in onCreateOrder.ts.

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {getWallet, createWallet} from '../../db/wallets/storage';
import {getStartup} from '../../db/startups/storage';
import {getUserDocId} from '../../db/users/storage';
import type {OrderDocument} from '../../db/orders/model';
import {recordTransaction} from '../../db/transactions/storage';
import {verifyAuth} from '../../utils/auth';
import {calcTokenPrice} from '../../utils/pricing';
import {logger} from '../../utils/logger';
import db from '../../configs';


// --- ERRORS ---
import {AuthError} from '../../errors/authError';
import {ValidationError} from '../../errors/validationError';
import {NotFoundError} from '../../errors/notFoundError';
import {InternalError} from '../../errors/internalError';


// --- TYPES ---
import type {CallableRequest} from 'firebase-functions/v2/https';
import {BuyFromStartupRequest} from '../../types/responders/investment';
import {parseRequest} from '../../utils/validation';


// --- CODE ---

/**
 * I handle the onBuyFromStartup callable.
 * Primary-market purchase: buys `quantity` tokens at the startup's current
 * bonding-curve price. Inside a single transaction it debits the wallet,
 * decrements `available_tokens`, recomputes the new price and writes a
 * snapshot to `price_history`. The order document is created as `pending`
 * before the transaction and flipped to `completed` (or `failed`) after.
 *
 * @param request callable request with `startupId` and `quantity`
 *
 * @returns `{orderId, status: 'completed', totalAmount, completedAt}`
 *
 * @throws HttpsError('unauthenticated')  if the caller is not signed in
 * @throws HttpsError('not-found')        if the startup does not exist
 * @throws HttpsError('invalid-argument') if not enough tokens are available
 *   or the wallet balance is insufficient
 */
export async function handleOnBuyFromStartup(request: CallableRequest)
{
    try
    {
        // verify authentication and extract uid
        const uid = verifyAuth(request);

        // validate input
        const {startupId, quantity} = parseRequest(BuyFromStartupRequest, request.data);

        // verify startup exists before creating any documents
        logger.info(`Fetching startup "${startupId}" for primary buy...`);
        const startup = await getStartup(startupId);
        if (startup === null)
        {
            throw new NotFoundError(`Startup "${startupId}" not found.`);
        }

        // pre-provision wallet so the transaction can always read it
        logger.info(`Ensuring wallet exists for user "${uid}"...`);
        const existingWallet = await getWallet(uid);
        if (existingWallet === null)
        {
            await createWallet(uid);
        }

        // fetch userDocId before transaction
        const userDocId = await getUserDocId(uid);
        if (userDocId === null)
        {
            throw new NotFoundError(`User document for "${uid}" not found.`);
        }

        const orderRef = db.collection('orders').doc();
        const orderId = orderRef.id;

        // transaction: re-read startup + wallet inside, validate, debit, update
        let totalAmount: number;
        let completedAt: Date;

        try
        {
            ({totalAmount, completedAt} = await db.runTransaction(async (tx) =>
            {
                const startupRef = db.collection('startups').doc(startupId);
                const walletRef  = db.collection('wallets').doc(uid);
                const investmentRef = db.collection('users').doc(userDocId).collection('investments').doc(startupId);
                const pendingBuysQuery = db.collection('orders')
                    .where('uid', '==', uid)
                    .where('type', '==', 'buy')
                    .where('status', '==', 'pending');

                const [startupSnap, walletSnap, investmentSnap, pendingBuysSnap] = await Promise.all([
                    tx.get(startupRef),
                    tx.get(walletRef),
                    tx.get(investmentRef),
                    tx.get(pendingBuysQuery),
                ]);

                const available          = startupSnap.data()!.available_tokens    as number;
                const balance            = walletSnap.data()!.balance              as number;
                const basePrice          = startupSnap.data()!.base_price          as number;
                const totalTokens        = startupSnap.data()!.total_tokens        as number;
                const appreciationFactor = startupSnap.data()!.appreciation_factor as number;
                const unitPrice          = startupSnap.data()!.token_price         as number;
                const amount             = unitPrice * quantity;

                // Calculate BRL locked in pending buy orders
                let lockedBrl = 0;
                for (const doc of pendingBuysSnap.docs)
                {
                    const o = doc.data() as OrderDocument;
                    const remainingQty = o.quantity - (o.filled_quantity ?? 0);
                    lockedBrl += remainingQty * o.unit_price;
                }
                const availableBrl = balance - lockedBrl;

                // validate inside transaction — sees the committed state
                if (available < quantity)
                {
                    throw new ValidationError(
                        `Not enough tokens available. Requested: ${quantity}, available: ${available}.`,
                    );
                }

                if (availableBrl < amount)
                {
                    throw new ValidationError(
                        `Insufficient balance. Required: ${amount}, available: ${availableBrl} (balance: ${balance}, locked: ${lockedBrl}).`,
                    );
                }

                const newAvailable = available - quantity;
                const newPrice     = calcTokenPrice(basePrice, totalTokens, newAvailable, appreciationFactor);
                const tokensSold   = totalTokens - newAvailable;
                const now          = new Date();

                tx.update(walletRef, {balance: balance - amount, updated_at: now});
                tx.update(startupRef, {
                    available_tokens: newAvailable,
                    token_price:      newPrice,
                    updated_at:       now,
                });

                const snapRef = db
                    .collection('price_history')
                    .doc(startupId)
                    .collection('snapshots')
                    .doc();

                tx.set(snapRef, {
                    id:          snapRef.id,
                    startup_id:  startupId,
                    price:       newPrice,
                    tokens_sold: tokensSold,
                    recorded_at: now,
                });

                // Update users/{userId}/investments
                const startupName = startupSnap.data()!.name as string;
                const startupLogo = (startupSnap.data()!.logo_url as string | null) ?? '';

                let oldQty = 0;
                let oldTotalCost = 0;
                if (investmentSnap.exists)
                {
                    const invData = investmentSnap.data()!;
                    oldQty = (invData.token_quantity as number) ?? 0;
                    const oldAvgPrice = (invData.avg_purchase_price as number) ?? 0;
                    oldTotalCost = oldQty * oldAvgPrice;
                }

                const newQty = oldQty + quantity;
                const newAvgPrice = (oldTotalCost + amount) / newQty;

                if (investmentSnap.exists)
                {
                    tx.update(investmentRef, {
                        token_quantity:     newQty,
                        avg_purchase_price: newAvgPrice,
                        updated_at:         now,
                    });
                }
                else
                {
                    tx.set(investmentRef, {
                        avg_purchase_price: newAvgPrice,
                        created_at:         now,
                        startup_id:         startupId,
                        startup_logo_url:   startupLogo,
                        startup_name:       startupName,
                        token_quantity:     newQty,
                        updated_at:         null,
                    });
                }

                // Write completed order directly inside the transaction
                const orderData: OrderDocument = {
                    id:              orderId,
                    uid,
                    startup_id:      startupId,
                    type:            'buy',
                    status:          'completed',
                    quantity,
                    unit_price:      unitPrice,
                    total_amount:    amount,
                    created_at:      now,
                    completed_at:    now,
                    failure_reason:  null,
                    filled_quantity: quantity,
                    cancelled_at:    null,
                    avg_fill_price:  unitPrice,
                };
                tx.set(orderRef, orderData);

                return {totalAmount: amount, completedAt: now};
            }));
        }
        catch (txError: unknown)
        {
            throw txError;
        }

        // Record in transaction history — best-effort, does not roll back the order
        try
        {
            await recordTransaction(uid, {
                amount:      totalAmount,
                description: `Compra de tokens — ${startup.name}`,
                status:      'completed',
                type:        'buy',
            });
        }
        catch (txErr)
        {
            logger.warning(`Failed to record transaction for primary order "${orderId}": ${txErr}`);
        }

        logger.info(`Primary order "${orderId}" completed. User "${uid}" bought ${quantity} tokens of "${startupId}".`);

        return {
            orderId,
            status:  'completed',
            totalAmount,
            completedAt,
        };
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

        const internal = new InternalError('Failed to buy tokens from startup.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
