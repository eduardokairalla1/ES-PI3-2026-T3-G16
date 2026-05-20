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

        // fetch all completed buy orders for this user
        const ordersSnap = await db
            .collection('orders')
            .where('uid', '==', uid)
            .where('type', '==', 'buy')
            .where('status', '==', 'completed')
            .orderBy('created_at', 'asc')
            .get();

        // --- Pedro Henrique Medeiros dos Reis - 24801656 ---
        // After the balcão / P2P market shipped, completed buys overstate the
        // user's holdings because they don't account for tokens the user sold.
        // We also need to subtract:
        //   - completed sell filled quantities
        //   - cancelled sell filled quantities (partial fills that already left
        //     the user's hands before cancel)
        // We can't easily AND these two extra conditions in the same query, so
        // pull all sell orders (completed and cancelled) and aggregate below.
        const sellOrdersSnap = await db
            .collection('orders')
            .where('uid',  '==', uid)
            .where('type', '==', 'sell')
            .get();
        // --- end Pedro ---

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

        // --- Pedro Henrique Medeiros dos Reis - 24801656 ---
        // subtract tokens that left the user's holdings via sells
        for (const doc of sellOrdersSnap.docs)
        {
            const data      = doc.data();
            const status    = data.status as string;
            const startupId = data.startup_id as string;
            const filled    = (data.filled_quantity as number) ?? 0;

            // only completed or cancelled (partially-filled) sells consumed tokens
            if (status !== 'completed' && status !== 'cancelled') continue;
            if (filled <= 0) continue;
            if (!byStartup.has(startupId)) continue;

            byStartup.get(startupId)!.quantity -= filled;
        }

        // drop startups whose net quantity dropped to zero or less (fully sold)
        for (const [sid, agg] of Array.from(byStartup.entries()))
        {
            if (agg.quantity <= 0) byStartup.delete(sid);
        }
        // --- end Pedro ---

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
