/**
 * Function callable onGetPortfolio.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getStartup} from '../../db/startups/storage';
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


/**
 * CODE
 */

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
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        const {uid} = request.auth;

        logger.info(`Fetching portfolio for user "${uid}"...`);

        // fetch all completed buy orders for this user
        const ordersSnap = await db
            .collection('orders')
            .where('uid', '==', uid)
            .where('type', '==', 'buy')
            .where('status', '==', 'completed')
            .orderBy('created_at', 'asc')
            .get();

        if (ordersSnap.empty)
        {
            return {holdings: []};
        }

        // group orders by startup: total quantity + first purchase price
        const byStartup = new Map<string, {quantity: number; firstUnitPrice: number}>();

        for (const doc of ordersSnap.docs)
        {
            const data      = doc.data();
            const startupId = data.startup_id as string;
            const quantity  = data.quantity   as number;
            const unitPrice = data.unit_price  as number;

            if (byStartup.has(startupId))
            {
                byStartup.get(startupId)!.quantity += quantity;
            }
            else
            {
                // first order for this startup = first purchase price
                byStartup.set(startupId, {quantity, firstUnitPrice: unitPrice});
            }
        }

        // fetch startup details and build holdings
        const holdings = await Promise.all(
            Array.from(byStartup.entries()).map(async ([startupId, {quantity, firstUnitPrice}]) =>
            {
                const startup = await getStartup(startupId);
                if (startup === null) return null;

                const currentPrice  = startup.token_price;
                const totalValue    = quantity * currentPrice;
                const changePercent = firstUnitPrice > 0
                    ? ((currentPrice - firstUnitPrice) / firstUnitPrice) * 100
                    : 0;

                return {
                    startupId,
                    startupName:   startup.name,
                    logoUrl:       startup.logo_url,
                    stage:         startup.stage,
                    tagline:       startup.tagline,
                    tokenPrice:    currentPrice,
                    tokenQuantity: quantity,
                    totalValue,
                    purchasePrice: firstUnitPrice,
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
