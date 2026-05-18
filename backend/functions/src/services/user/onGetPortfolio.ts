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
import {getUserInvestments} from '../../db/investments/storage';
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

        const investments = await getUserInvestments(uid);

        // fetch pending orders
        const pendingOrdersSnap = await db.collection('orders')
            .where('uid', '==', uid)
            .where('status', '==', 'pending')
            .orderBy('created_at', 'desc')
            .get();

        const pendingOrders = await Promise.all(
            pendingOrdersSnap.docs.map(async (doc) => {
                const data = doc.data();
                const startup = await getStartup(data.startup_id);
                return {
                    id: doc.id,
                    startupId: data.startup_id,
                    startupName: startup?.name ?? 'Desconhecida',
                    logoUrl: startup?.logo_url ?? '',
                    type: data.type,
                    quantity: data.quantity,
                    price: data.unit_price,
                    totalAmount: data.total_amount,
                    createdAt: data.created_at,
                };
            })
        );

        // fetch startup details and build holdings
        const holdings = await Promise.all(
            investments.filter(inv => inv.token_quantity > 0).map(async (inv) =>
            {
                const startupId = inv.startup_id;
                const quantity = inv.token_quantity;
                const avgPrice = inv.avg_purchase_price;

                const startup = await getStartup(startupId);
                if (startup === null) return null;

                const currentPrice  = startup.token_price;
                const totalValue    = quantity * currentPrice;
                const changePercent = avgPrice > 0
                    ? ((currentPrice - avgPrice) / avgPrice) * 100
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
                    purchasePrice: avgPrice,
                    changePercent,
                };
            }),
        );

        return {
            holdings: holdings.filter(Boolean),
            pendingOrders,
        };
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
