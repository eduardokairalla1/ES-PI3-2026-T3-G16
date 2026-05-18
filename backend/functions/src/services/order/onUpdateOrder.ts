/**
 * Function callable onUpdateOrder.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
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
import {UpdateOrderRequest} from '../../types/responders/investment';
import {parseRequest} from '../../utils/validation';
import type {OrderDocument} from '../../db/orders/model';

/**
 * CODE
 */

/**
 * I handle the onUpdateOrder callable.
 *
 * Flow:
 *   1. Validate auth + input
 *   2. Run transaction:
 *      a. Get old order, verify it exists, belongs to user, and is 'pending'.
 *      b. Refund old order costs (balance or tokens).
 *      c. Calculate new costs. Check if user has sufficient balance/tokens (including the refunded amount).
 *      d. Deduct new costs.
 *      e. Delete old order.
 *      f. Create new order with new parameters. This will re-trigger the onMatchOrders engine.
 *
 * @param request callable request with orderId, quantity, price, type
 *
 * @returns newOrderId, status, totalAmount
 */
export async function handleOnUpdateOrder(request: CallableRequest)
{
    try
    {
        // verify authentication and extract uid
        const uid = verifyAuth(request);

        // validate request
        const {orderId, quantity: newQuantity, price: newPrice, type: newType} = parseRequest(UpdateOrderRequest, request.data);

        logger.info(`Updating order "${orderId}" for user "${uid}"...`);

        const userDocId = await getUserDocId(uid);
        if (!userDocId) {
            throw new NotFoundError(`User document not found for uid "${uid}".`);
        }

        let newOrderId = '';
        let newTotalAmount = 0;

        await db.runTransaction(async (tx) =>
        {
            // 1. Get old order
            const oldOrderRef = db.collection('orders').doc(orderId);
            const oldOrderSnap = await tx.get(oldOrderRef);

            if (!oldOrderSnap.exists) {
                throw new NotFoundError(`Order "${orderId}" not found.`);
            }

            const oldOrder = oldOrderSnap.data() as OrderDocument;

            if (oldOrder.uid !== uid) {
                throw new ValidationError(`Order "${orderId}" does not belong to user "${uid}".`);
            }

            if (oldOrder.status !== 'pending') {
                throw new ValidationError(`Cannot update order "${orderId}" because its status is "${oldOrder.status}".`);
            }

            const startupId = oldOrder.startup_id;

            // 2. Read wallet and investment
            const walletRef = db.collection('wallets').doc(uid);
            const investmentRef = db.collection('users').doc(userDocId).collection('investments').doc(startupId);

            const [walletSnap, investmentSnap] = await Promise.all([
                tx.get(walletRef),
                tx.get(investmentRef),
            ]);

            let currentBalance = walletSnap.exists ? (walletSnap.data()!.balance as number) : 0;
            let currentTokens = investmentSnap.exists ? (investmentSnap.data()!.token_quantity as number) : 0;

            const now = new Date();

            // 3. Refund old order
            if (oldOrder.type === 'buy') {
                currentBalance += oldOrder.total_amount;
            } else if (oldOrder.type === 'sell') {
                currentTokens += oldOrder.quantity;
            }

            // 4. Validate new order & Deduct
            newTotalAmount = newPrice * newQuantity;

            if (newType === 'buy') {
                if (currentBalance < newTotalAmount) {
                    throw new ValidationError(`Insufficient balance. Required: ${newTotalAmount}, available: ${currentBalance}.`);
                }
                currentBalance -= newTotalAmount;
                tx.update(walletRef, {balance: currentBalance, updated_at: now});

                // if changing from sell to buy, we must write back the refunded tokens
                if (oldOrder.type === 'sell') {
                    tx.update(investmentRef, {token_quantity: currentTokens, updated_at: now});
                }
            } else if (newType === 'sell') {
                if (currentTokens < newQuantity) {
                    throw new ValidationError(`Not enough tokens to sell. Required: ${newQuantity}, available: ${currentTokens}.`);
                }
                currentTokens -= newQuantity;
                tx.update(investmentRef, {token_quantity: currentTokens, updated_at: now});

                // if changing from buy to sell, we must write back the refunded balance
                if (oldOrder.type === 'buy') {
                    tx.update(walletRef, {balance: currentBalance, updated_at: now});
                }
            }

            // 5. Delete old order and create new one
            tx.delete(oldOrderRef);

            const newOrderRef = db.collection('orders').doc();
            newOrderId = newOrderRef.id;

            tx.set(newOrderRef, {
                id: newOrderId,
                uid,
                startup_id: startupId,
                type: newType,
                status: 'pending',
                quantity: newQuantity,
                unit_price: newPrice,
                total_amount: newTotalAmount,
                created_at: now,
                completed_at: null,
                failure_reason: null,
            });
        });

        logger.info(`Order "${orderId}" successfully updated to "${newOrderId}".`);

        return {
            orderId: newOrderId,
            status:  'pending',
            totalAmount: newTotalAmount,
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

        const internal = new InternalError('Failed to update order.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
