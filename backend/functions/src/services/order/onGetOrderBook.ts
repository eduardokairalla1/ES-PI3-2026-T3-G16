/**
 * Function callable onGetOrderBook.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getPendingOrdersByStartupId} from '../../db/orders/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {ValidationError} from '../../errors/validationError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';
import {GetOrderBookRequest} from '../../types/responders/startups';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * I handle the onGetOrderBook callable.
 * Returns the list of pending buy and sell orders for a startup.
 *
 * @param request callable request with startup ID
 *
 * @returns list of pending orders
 */
export async function handleOnGetOrderBook(request: CallableRequest)
{
    try
    {
        // verify authentication
        verifyAuth(request);

        // validate request data
        const parsed = parseRequest(GetOrderBookRequest, request.data);

        logger.info(`Fetching order book for startup "${parsed.startupId}"...`, {data: {startupId: parsed.startupId}});
        const orders = await getPendingOrdersByStartupId(parsed.startupId);

        logger.info(`Order book for startup "${parsed.startupId}" fetched successfully (${orders.length} orders).`);

        return {
            orders: orders.map(order => {
                // Firestore returns Timestamp objects; convert to ISO string safely
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                const createdAt = (order.created_at as any);
                const createdAtStr = createdAt
                    ? (typeof createdAt.toDate === 'function'
                        ? createdAt.toDate().toISOString()
                        : new Date(createdAt).toISOString())
                    : null;

                return {
                    id: order.id,
                    uid: order.uid,
                    startup_id: order.startup_id,
                    type: order.type,
                    status: order.status,
                    quantity: order.quantity,
                    unit_price: order.unit_price,
                    total_amount: order.total_amount,
                    created_at: createdAtStr,
                };
            }),
        };
    }

    // handle errors
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

        const internal = new InternalError('Failed to fetch order book.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
