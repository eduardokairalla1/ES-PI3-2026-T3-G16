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
import {getUserDocId} from '../../db/users/storage';
import {verifyAuth} from '../../utils/auth';
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
 *   1. Validate auth + input
 *   2. Verify startup exists
 *   3. Pre-provision wallet if missing
 *   4. Transaction: Verify balance (if buy) or token quantity (if sell).
 *      Deduct balance or tokens to prevent double-spending.
 *      Create order in 'orders' collection with status 'pending'.
 *
 * @param request callable request with startupId, quantity, price, type
 *
 * @returns orderId, status, totalAmount
 */
export async function handleOnCreateOrder(request: CallableRequest)
{
    try
    {
        // verify authentication and extract uid
        const uid = verifyAuth(request);

        // validate request
        const {startupId, quantity, price, type} = parseRequest(CreateOrderRequest, request.data);

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

        const userDocId = await getUserDocId(uid);
        if (!userDocId) {
            throw new NotFoundError(`User document not found for uid "${uid}".`);
        }

        let orderId = '';
        let totalAmount = 0;

        await db.runTransaction(async (tx) =>
        {
            const walletRef = db.collection('wallets').doc(uid);
            const investmentRef = db.collection('users').doc(userDocId).collection('investments').doc(startupId);

            const [walletSnap, investmentSnap] = await Promise.all([
                tx.get(walletRef),
                tx.get(investmentRef),
            ]);

            totalAmount = price * quantity;
            const now = new Date();

            if (type === 'buy')
            {
                const balance = walletSnap.exists ? (walletSnap.data()!.balance as number) : 0;
                if (balance < totalAmount)
                {
                    throw new ValidationError(`Insufficient balance. Required: ${totalAmount}, available: ${balance}.`);
                }
                tx.update(walletRef, {balance: balance - totalAmount, updated_at: now});
            }
            else if (type === 'sell')
            {
                const tokenQuantity = investmentSnap.exists ? (investmentSnap.data()!.token_quantity as number) : 0;
                if (tokenQuantity < quantity)
                {
                    throw new ValidationError(`Not enough tokens to sell. Required: ${quantity}, available: ${tokenQuantity}.`);
                }
                tx.update(investmentRef, {token_quantity: tokenQuantity - quantity, updated_at: now});
            }

            const orderRef = db.collection('orders').doc();
            orderId = orderRef.id;

            tx.set(orderRef, {
                id: orderId,
                uid,
                startup_id: startupId,
                type,
                status: 'pending',
                quantity,
                unit_price: price,
                total_amount: totalAmount,
                created_at: now,
                completed_at: null,
                failure_reason: null,
            });
        });

        logger.info(`Order "${orderId}" created as pending. User "${uid}" placed a ${type} order for ${quantity} tokens of "${startupId}" at R$${price}.`);

        return {
            orderId,
            status:  'pending',
            totalAmount,
            createdAt: new Date(),
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
