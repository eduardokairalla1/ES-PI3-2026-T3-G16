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
import {verifyAuth} from '../../utils/auth';
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
        // verify authentication and extract uid
        const uid = verifyAuth(request);

        logger.info(`Fetching portfolio for user "${uid}"...`);

        // fetch all buy orders for this user
        const ordersSnap = await db
            .collection('orders')
            .where('uid', '==', uid)
            .where('type', '==', 'buy')
            .get();

        // pull all sell orders and aggregate below
        const sellOrdersSnap = await db
            .collection('orders')
            .where('uid',  '==', uid)
            .where('type', '==', 'sell')
            .get();

        if (ordersSnap.empty)
        {
            return {holdings: []};
        }

        // group orders by startup: total quantity + first purchase price
        const byStartup = new Map<string, {quantity: number; firstUnitPrice: number}>();

        // Sort buy orders in memory by created_at to correctly identify the first purchase price
        const buyDocs = ordersSnap.docs.map(doc => {
            const data = doc.data();
            return {
                id: doc.id,
                startup_id: data.startup_id as string,
                filled_quantity: (data.filled_quantity as number) ?? 0,
                unit_price: data.unit_price as number,
                created_at: data.created_at,
            };
        }).sort((a, b) => {
            const timeA = a.created_at?.toDate?.()?.getTime() || 0;
            const timeB = b.created_at?.toDate?.()?.getTime() || 0;
            return timeA - timeB;
        });

        for (const data of buyDocs)
        {
            const startupId = data.startup_id;
            const filled    = data.filled_quantity;
            const unitPrice = data.unit_price;

            if (filled <= 0) continue;

            if (byStartup.has(startupId))
            {
                byStartup.get(startupId)!.quantity += filled;
            }
            else
            {
                // first order for this startup = first purchase price
                byStartup.set(startupId, {quantity: filled, firstUnitPrice: unitPrice});
            }
        }

        // subtract tokens that left the user's holdings via sells
        for (const doc of sellOrdersSnap.docs)
        {
            const data      = doc.data();
            const startupId = data.startup_id as string;
            const filled    = (data.filled_quantity as number) ?? 0;

            if (filled <= 0) continue;
            if (!byStartup.has(startupId)) continue;

            byStartup.get(startupId)!.quantity -= filled;
        }

        // drop startups whose net quantity dropped to zero or less (fully sold)
        for (const [sid, agg] of Array.from(byStartup.entries()))
        {
            if (agg.quantity <= 0) byStartup.delete(sid);
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
