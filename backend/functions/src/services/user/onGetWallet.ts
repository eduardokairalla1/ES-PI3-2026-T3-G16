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
import {getOrdersByTypeAndStatus} from '../../db/orders/storage';
import {getWallet, createWallet} from '../../db/wallets/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import {mapTotalTokensByStartup, calcWeeklyReturn} from '../../utils/walletUtils';


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
 * @returns the authenticated user's wallet balance and weekly return
 */
export async function handleOnGetWallet(request: CallableRequest)
{
    try
    {
        const uid = verifyAuth(request);

        logger.info(`Fetching wallet for user "${uid}"...`);
        let wallet = await getWallet(uid);

        if (wallet === null)
        {
            logger.info(`Wallet not found for user "${uid}", creating one...`);
            await createWallet(uid);
            wallet = await getWallet(uid) as walletDocument;
        }

        const orders = await getOrdersByTypeAndStatus(uid, 'buy', 'completed');
        const totalTokensByStartup = mapTotalTokensByStartup(orders);

        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);

        const values = await Promise.all(
            Object.entries(totalTokensByStartup).map(async ([startupId, quantity]) =>
            {
                const [startup, snapshot] = await Promise.all([
                    getStartup(startupId),
                    getOldestSnapshotSince(startupId, weekAgo),
                ]);
                if (startup === null) return {currentValue: 0, pastValue: 0};
                const pastPrice = snapshot?.price ?? startup.token_price;
                return {
                    currentValue: quantity * startup.token_price,
                    pastValue: quantity * pastPrice,
                };
            }),
        );

        const {weeklyReturn, weeklyReturnPct} = calcWeeklyReturn(values);

        logger.info(`Wallet for user "${uid}" fetched successfully.`);

        return {
            patrimonioTotal: wallet.balance,
            weeklyReturn,
            weeklyReturnPct,
        };
    }

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
