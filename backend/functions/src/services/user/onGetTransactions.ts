/**
 * Function callable onGetTransactions.
 * Returns a unified statement: deposits from transactions + buy/sell from orders.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

import {HttpsError} from 'firebase-functions/v2/https';
import {getTransactions} from '../../db/transactions/storage';
import {getAllCompletedOrdersByUid} from '../../db/orders/storage';
import {getStartups} from '../../db/startups/storage';
import {logger} from '../../utils/logger';
import {verifyAuth} from '../../utils/auth';

import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';

import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * I handle the onGetTransactions callable.
 * Merges deposit transactions with completed token orders, sorted by date descending.
 *
 * @param request Body: { limit?: number }
 */
export async function handleOnGetTransactions(request: CallableRequest)
{
    try
    {
        const uid = verifyAuth(request);
        const limit: number = request.data.limit || 20;

        logger.info(`Fetching unified transaction history for user "${uid}"...`);

        const [deposits, orders, startups] = await Promise.all([
            getTransactions(uid, 200),
            getAllCompletedOrdersByUid(uid),
            getStartups(),
        ]);

        // build startup name lookup
        const startupNameMap = new Map<string, string>();
        for (const s of startups)
        {
            startupNameMap.set(s.id, s.name);
        }

        // map orders to the unified transaction shape
        const orderTransactions = orders.map(order =>
        {
            const startupName = startupNameMap.get(order.startup_id) ?? order.startup_id;
            const description = order.type === 'buy'
                ? `Compra de tokens — ${startupName}`
                : `Venda de tokens — ${startupName}`;

            return {
                id:          order.id,
                amount:      order.total_amount,
                description,
                created_at:  order.completed_at ?? order.created_at,
                type:        order.type,
                status:      order.status,
            };
        });

        // merge and sort by date descending, then apply limit
        const all = [...deposits, ...orderTransactions].sort((a, b) =>
        {
            const dateA = a.created_at instanceof Date ? a.created_at : new Date(a.created_at as string);
            const dateB = b.created_at instanceof Date ? b.created_at : new Date(b.created_at as string);
            return dateB.getTime() - dateA.getTime();
        });

        const transactions = all.slice(0, limit);

        logger.info(`Returning ${transactions.length} transactions for user "${uid}".`);

        return {transactions};
    }
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Failed to fetch transaction history.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
