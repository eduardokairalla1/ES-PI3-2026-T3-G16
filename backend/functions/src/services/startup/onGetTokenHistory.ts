/**
 * Function callable onGetTokenHistory.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getPriceSnapshots} from '../../db/price_history/storage';
import {getStartup} from '../../db/startups/storage';
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
import {GetTokenHistoryRequest} from '../../types/responders/investment';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

const PERIOD_TO_DAYS: Record<string, number> = {
    daily:    1,
    weekly:   7,
    monthly:  30,
    '6months': 180,
    ytd:      -1, // handled separately
};

function sinceDate(period: string): Date
{
    const now = new Date();

    if (period === 'ytd')
    {
        return new Date(now.getFullYear(), 0, 1); // Jan 1st of current year
    }

    const days = PERIOD_TO_DAYS[period] ?? 30;
    const since = new Date(now);
    since.setDate(since.getDate() - days);
    return since;
}

/**
 * I handle the onGetTokenHistory callable.
 *
 * Returns price snapshots anchored to the user's first purchase of this
 * startup, further filtered by the requested period.
 * If the user has never invested, returns an empty snapshot list.
 *
 * @param request callable request with startupId and period
 *
 * @returns { currentPrice, purchasePrice, snapshots[] }
 */
export async function handleOnGetTokenHistory(request: CallableRequest)
{
    try
    {
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        const {uid}               = request.auth;
        const {startupId, period} = parseRequest(GetTokenHistoryRequest, request.data);

        logger.info(`Fetching token history for "${startupId}" — uid: ${uid}, period: ${period}`);

        const startup = await getStartup(startupId);
        if (startup === null)
        {
            throw new NotFoundError(`Startup "${startupId}" not found.`);
        }

        // Single query sorted by created_at — docs[0] gives firstPurchase, all docs give tokenQuantity.
        const ordersSnap = await db
            .collection('orders')
            .where('uid', '==', uid)
            .where('startup_id', '==', startupId)
            .where('type', '==', 'buy')
            .where('status', '==', 'completed')
            .orderBy('created_at', 'asc')
            .get();

        if (ordersSnap.empty)
        {
            return {
                currentPrice:   startup.token_price,
                purchasePrice:  null,
                tokenQuantity:  0,
                totalValue:     0,
                snapshots:      [],
            };
        }

        const firstTs       = ordersSnap.docs[0].data().created_at;
        const firstPurchase = firstTs?.toDate ? firstTs.toDate() : new Date(firstTs);

        const tokenQuantity = ordersSnap.docs.reduce(
            (sum, doc) => sum + (doc.data().quantity as number),
            0,
        );

        // since = latest of (period start, first purchase date)
        const periodStart = sinceDate(period);
        const since       = firstPurchase > periodStart ? firstPurchase : periodStart;

        const snapshots = await getPriceSnapshots(startupId, since);

        logger.info(`Returning ${snapshots.length} snapshots, tokenQty=${tokenQuantity}`);

        return {
            currentPrice:   startup.token_price,
            purchasePrice:  snapshots.length > 0 ? snapshots[0].price : startup.token_price,
            tokenQuantity,
            totalValue:     tokenQuantity * startup.token_price,
            snapshots:      snapshots.map(s => ({
                price:      s.price,
                recordedAt: s.recorded_at,
            })),
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

        const internal = new InternalError('Failed to fetch token history.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
