// --- Function callable onGetPortfolio ---
//
// Davi da Cruz Shieh - 24798076
// Returns the authenticated user's current startup holdings.

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {getStartup} from '../../db/startups/storage';
import {getUserDocId} from '../../db/users/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import db from '../../configs';


// --- ERRORS ---
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';


// --- TYPES ---
import type {CallableRequest} from 'firebase-functions/v2/https';


// --- CODE ---

/**
 * I handle the onGetPortfolio callable.
 * Returns all startups the user has invested in, with holdings data.
 *
 * @param request callable request (no payload needed)
 *
 * @returns list of portfolio holdings
 */
export async function handleOnGetPortfolio(request: CallableRequest)
{
    try
    {
        // verify authentication and extract uid
        const uid = verifyAuth(request);

        logger.info(`Fetching portfolio for user "${uid}"...`);

        const userDocId = await getUserDocId(uid);
        if (!userDocId)
        {
            return {holdings: []};
        }

        const investmentsSnap = await db
            .collection('users')
            .doc(userDocId)
            .collection('investments')
            .get();

        if (investmentsSnap.empty)
        {
            return {holdings: []};
        }

        // fetch startup details and build holdings
        const holdings = await Promise.all(
            investmentsSnap.docs.map(async (doc) =>
            {
                const invData = doc.data();
                const startupId = invData.startup_id;
                const tokenQuantity = (invData.token_quantity as number) ?? 0;
                const purchasePrice = (invData.avg_purchase_price as number) ?? 0;

                if (tokenQuantity <= 0) return null;

                const startup = await getStartup(startupId);
                if (startup === null) return null;

                const currentPrice  = startup.token_price;
                const totalValue    = tokenQuantity * currentPrice;
                const changePercent = purchasePrice > 0
                    ? ((currentPrice - purchasePrice) / purchasePrice) * 100
                    : 0;

                return {
                    startupId,
                    startupName:   startup.name,
                    logoUrl:       startup.logo_url,
                    stage:         startup.stage,
                    tagline:       startup.tagline,
                    tokenPrice:    currentPrice,
                    tokenQuantity,
                    totalValue,
                    purchasePrice,
                    changePercent,
                };
            }),
        );

        return {holdings: holdings.filter(Boolean)};
    }

    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Failed to fetch portfolio.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
