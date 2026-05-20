/**
 * Function callable onCancelOrder.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 *
 * Cancels one of the caller's own pending P2P orders. If the order has already
 * been partially filled, the filled portion stays as committed history; only
 * the unfilled remainder is cancelled.
 */

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {getOrder, getOrderRef} from '../../db/orders/storage';
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
import {CancelOrderRequest} from '../../types/responders/investment';
import {parseRequest} from '../../utils/validation';


// --- CODE ---

/**
 * I handle the onCancelOrder callable.
 * Cancels one of the caller's own pending P2P orders. If the order has already
 * been partially filled, the filled portion stays as committed history; only
 * the unfilled remainder is cancelled. The status flip happens inside a
 * Firestore transaction so a concurrent matching engine sees the cancellation
 * atomically.
 *
 * @param request callable request with `orderId` in the body
 *
 * @returns `{orderId, status: 'cancelled', cancelledAt}`
 *
 * @throws HttpsError('unauthenticated') if the caller is not signed in
 * @throws HttpsError('not-found')       if the order does not exist
 * @throws HttpsError('invalid-argument') if the caller is not the owner, or
 *   the order is no longer pending
 */
export async function handleOnCancelOrder(request: CallableRequest)
{
    try
    {
        // verify auth and validate input
        const uid           = verifyAuth(request);
        const {orderId}     = parseRequest(CancelOrderRequest, request.data);

        // load the order to validate ownership/status before mutating it
        const order = await getOrder(orderId);
        if (order === null)
        {
            throw new NotFoundError(`Order "${orderId}" not found.`);
        }

        // only the owner can cancel
        if (order.uid !== uid)
        {
            throw new ValidationError('You can only cancel your own orders.');
        }

        // only pending orders can be cancelled (completed/failed already done)
        if (order.status !== 'pending')
        {
            throw new ValidationError(
                `Order is already "${order.status}" and cannot be cancelled.`,
            );
        }

        // update in a transaction so a concurrent matching engine sees the
        // cancellation atomically — once it's cancelled, no further fills
        // can land on it
        const cancelledAt = new Date();
        await db.runTransaction(async (tx) =>
        {
            const ref  = getOrderRef(orderId);
            const snap = await tx.get(ref);

            // re-check inside the transaction in case another matcher just
            // filled this order during our read window
            const fresh = snap.data();
            if (fresh?.status !== 'pending')
            {
                throw new ValidationError(
                    `Order is already "${fresh?.status}" and cannot be cancelled.`,
                );
            }

            tx.update(ref, {
                status:       'cancelled',
                cancelled_at: cancelledAt,
            });
        });

        logger.info(`Order "${orderId}" cancelled by user "${uid}".`);

        return {
            orderId,
            status:      'cancelled',
            cancelledAt,
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

        const internal = new InternalError('Failed to cancel order.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
