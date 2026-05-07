/**
 * Function callable onCreateOrder.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getWallet, createWallet} from '../../db/wallets/storage';
import {getStartup} from '../../db/startups/storage';
import {createOrder, updateOrderStatus} from '../../db/orders/storage';
import {calcTokenPrice} from '../../utils/pricing';
import {logger} from '../../utils/logger';
import db from '../../configs';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {ValidationError} from '../../errors/validationError';
import {NotFoundError} from '../../errors/notFoundError';
import {InternalError} from '../../errors/internalError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';
import {CreateOrderRequest} from '../../types/responders/investment';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * I handle the onCreateOrder callable.
 *
 * Flow:
 *   1. Validate auth + input (reject non-buy types immediately)
 *   2. Verify startup exists
 *   3. Pre-provision wallet if missing
 *   4. Create order with status "pending"
 *   5. Firestore transaction: re-read startup + wallet inside tx,
 *      validate stock + balance, debit wallet, decrement available_tokens,
 *      update token_price, record price snapshot — all atomic
 *   6. Mark order "completed"
 *
 * Using a transaction (not a batch) for step 5 ensures that concurrent
 * purchases re-validate stock against the latest available_tokens and
 * abort on contention, preventing the value from going negative.
 *
 * @param request callable request with startupId, quantity, type
 *
 * @returns orderId, status, totalAmount, completedAt
 */
export async function handleOnCreateOrder(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        const {uid} = request.auth;

        // validate request
        const {startupId, quantity, type} = parseRequest(CreateOrderRequest, request.data);

        // only buy is implemented — reject sell immediately
        if (type !== 'buy')
        {
            throw new ValidationError('Only buy orders are currently supported.');
        }

        // verify startup exists before creating any documents
        logger.info(`Fetching startup "${startupId}"...`);
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

        // create order as pending — audit trail starts here
        const order = await createOrder({
            uid,
            startup_id:     startupId,
            type,
            status:         'pending',
            quantity,
            unit_price:     startup.token_price,
            total_amount:   startup.token_price * quantity,
            created_at:     new Date(),
            completed_at:   null,
            failure_reason: null,
        });

        logger.info(`Order "${order.id}" created as pending.`);

        // transaction: re-read both docs inside to avoid race conditions on available_tokens
        let totalAmount: number;

        try
        {
            ({totalAmount} = await db.runTransaction(async (tx) =>
            {
                const startupRef  = db.collection('startups').doc(startupId);
                const walletRef   = db.collection('wallets').doc(uid);

                const [startupSnap, walletSnap] = await Promise.all([
                    tx.get(startupRef),
                    tx.get(walletRef),
                ]);

                const available         = startupSnap.data()!.available_tokens as number;
                const balance           = walletSnap.data()!.balance            as number;
                const basePrice         = startupSnap.data()!.base_price        as number;
                const totalTokens       = startupSnap.data()!.total_tokens      as number;
                const appreciationFactor = startupSnap.data()!.appreciation_factor as number;
                const unitPrice         = startupSnap.data()!.token_price       as number;
                const amount            = unitPrice * quantity;

                // validate inside transaction — sees the committed state
                if (available < quantity)
                {
                    throw new ValidationError(
                        `Not enough tokens available. Requested: ${quantity}, available: ${available}.`,
                    );
                }

                if (balance < amount)
                {
                    throw new ValidationError(
                        `Insufficient balance. Required: ${amount}, available: ${balance}.`,
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

                return {totalAmount: amount};
            }));
        }
        catch (txError: unknown)
        {
            // mark order failed before re-throwing
            const reason = txError instanceof ValidationError
                ? txError.message
                : 'Transaction failed.';

            await updateOrderStatus(order.id, 'failed', {failure_reason: reason});
            throw txError;
        }

        // mark order as completed
        const completedAt = new Date();
        await updateOrderStatus(order.id, 'completed', {completed_at: completedAt});

        logger.info(`Order "${order.id}" completed. User "${uid}" bought ${quantity} tokens of "${startupId}".`);

        return {
            orderId: order.id,
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

        const internal = new InternalError('Failed to create order.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
