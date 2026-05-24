/**
 * Function callable onGetWallet.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getStartups} from '../../db/startups/storage';
import {getWallet, createWallet} from '../../db/wallets/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import {computeWalletState} from '../../utils/walletUtils';


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

        logger.info(`Fetching wallet and startups for user "${uid}"...`);
        let [wallet, startups] = await Promise.all([
            getWallet(uid),
            getStartups(),
        ]);

        if (wallet === null)
        {
            logger.info(`Wallet not found for user "${uid}", creating one...`);
            await createWallet(uid);
            wallet = await getWallet(uid) as walletDocument;
        }

        const startupPriceMap = new Map<string, number>();
        for (const s of startups)
        {
            startupPriceMap.set(s.id, s.token_price);
        }

        const {weeklyReturn, weeklyReturnPct} = await computeWalletState(uid, startupPriceMap);

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
