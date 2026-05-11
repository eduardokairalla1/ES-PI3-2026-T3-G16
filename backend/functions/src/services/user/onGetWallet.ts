/**
 * Function callable onGetWallet.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getOldestSnapshotSince} from '../../db/price_history/storage';
import {getStartup} from '../../db/startups/storage';
import {getWallet, createWallet} from '../../db/wallets/storage';
import {logger} from '../../utils/logger';
import db from '../../configs';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';
import type {walletDocument} from '../../db/wallets/model';


/**
 * CODE
 */

/**
 * I handle the onGetWallet callable.
 *
 * @param request callable request
 *
 * @returns the authenticated user's wallet balance and daily return
 */
export async function handleOnGetWallet(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        const {uid} = request.auth;

        // fetch wallet — auto-provision if missing (handles users created before this feature)
        logger.info(`Fetching wallet for user "${uid}"...`, {data: {uid}});
        let wallet = await getWallet(uid);

        // wallet not found: create one and fetch again
        if (wallet === null)
        {
            logger.info(`Wallet not found for "${uid}", creating one.`, {data: {uid}});
            await createWallet(uid);
            wallet = await getWallet(uid) as walletDocument;
        }

        logger.info(`Wallet for user "${uid}" fetched successfully.`);

        // compute 7-day portfolio return
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);

        const ordersSnap = await db
            .collection('orders')
            .where('uid', '==', uid)
            .where('type', '==', 'buy')
            .where('status', '==', 'completed')
            .get();

        let weeklyReturn    = 0;
        let weeklyReturnPct = 0;

        if (!ordersSnap.empty)
        {
            // group quantities by startup
            const byStartup = new Map<string, number>();
            for (const doc of ordersSnap.docs)
            {
                const data      = doc.data();
                const startupId = data.startup_id as string;
                const quantity  = data.quantity   as number;
                byStartup.set(startupId, (byStartup.get(startupId) ?? 0) + quantity);
            }

            // fetch current price and 7-day-ago price for each startup in parallel
            const entries = Array.from(byStartup.entries());
            const results = await Promise.all(entries.map(async ([startupId, quantity]) =>
            {
                const [startup, snapshot] = await Promise.all([
                    getStartup(startupId),
                    getOldestSnapshotSince(startupId, weekAgo),
                ]);
                if (startup === null) return {currentValue: 0, pastValue: 0};

                const currentValue = quantity * startup.token_price;
                const pastPrice    = snapshot?.price ?? startup.token_price;
                const pastValue    = quantity * pastPrice;
                return {currentValue, pastValue};
            }));

            const totalCurrent = results.reduce((s, r) => s + r.currentValue, 0);
            const totalPast    = results.reduce((s, r) => s + r.pastValue,    0);

            weeklyReturn    = totalCurrent - totalPast;
            weeklyReturnPct = totalPast > 0
                ? (weeklyReturn / totalPast) * 100
                : 0;
        }

        return {
            patrimonioTotal: wallet.balance,
            weeklyReturn,
            weeklyReturnPct,
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

        const internal = new InternalError('Failed to fetch wallet.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
