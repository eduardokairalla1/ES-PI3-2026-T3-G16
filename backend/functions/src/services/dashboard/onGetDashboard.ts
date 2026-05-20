/**
 * Function callable onGetDashboard.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getUser} from '../../db/users/storage';
import {getUserFavoriteIds} from '../../db/favorites/storage';
import {getStartups} from '../../db/startups/storage';
import {getWallet} from '../../db/wallets/storage';
import {getOrdersByTypeAndStatus, countActiveInvestors} from '../../db/orders/storage';
import {getOldestSnapshotSince} from '../../db/price_history/storage';
import {mapTotalTokensByStartup, calcWeeklyReturn} from '../../utils/walletUtils';
import {logger} from '../../utils/logger';
import {verifyAuth} from '../../utils/auth';


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
 * I handle the onGetDashboard callable.
 * Returns consolidated dashboard data: user info, portfolio, market stats,
 * investments, and favorite IDs.
 *
 * @param request callable request (no body params, uses auth context)
 *
 * @returns consolidated dashboard data
 */
export async function handleOnGetDashboard(request: CallableRequest)
{
    try
    {
        // verify authentication
        const uid = verifyAuth(request);

        // fetch all data in parallel for performance
        logger.info(`Fetching dashboard data for user "${uid}"...`);

        const [user, favorites, startups, activeInvestors, wallet, orders] = await Promise.all([
            getUser(uid),
            getUserFavoriteIds(uid),
            getStartups(),
            countActiveInvestors(),
            getWallet(uid),
            getOrdersByTypeAndStatus(uid, 'buy', 'completed'),
        ]);

        // user not found
        if (user === null)
        {
            throw new AuthError(`Profile not found for user "${uid}".`);
        }

        // build startup lookup maps (price + details)
        const startupPriceMap = new Map<string, number>();
        const startupNameMap  = new Map<string, {name: string; logoUrl: string}>();
        for (const s of startups)
        {
            startupPriceMap.set(s.id, s.token_price);
            startupNameMap.set(s.id, {name: s.name, logoUrl: s.logo_url ?? ''});
        }

        // derive portfolio from completed buy orders
        const holdingsByStartup = new Map<string, {quantity: number; totalCost: number}>();
        for (const order of orders)
        {
            const existing = holdingsByStartup.get(order.startup_id);
            if (existing)
            {
                existing.quantity  += order.quantity;
                existing.totalCost += order.unit_price * order.quantity;
            }
            else
            {
                holdingsByStartup.set(order.startup_id, {
                    quantity:  order.quantity,
                    totalCost: order.unit_price * order.quantity,
                });
            }
        }

        let patrimonioTotal = 0;

        const investimentosFormatted = Array.from(holdingsByStartup.entries()).map(([startupId, holding]) =>
        {
            const currentPrice = startupPriceMap.get(startupId) ?? 0;
            const avgPrice     = holding.quantity > 0 ? holding.totalCost / holding.quantity : 0;
            const currentValue = holding.quantity * currentPrice;
            const variation    = avgPrice > 0
                ? ((currentPrice - avgPrice) / avgPrice) * 100
                : 0;

            patrimonioTotal += currentValue;

            const details = startupNameMap.get(startupId) ?? {name: '', logoUrl: ''};

            return {
                currentPrice,
                startupId,
                startupLogoUrl: details.logoUrl,
                startupName:    details.name,
                tokenQuantity:  holding.quantity,
                variation:      Math.round(variation * 100) / 100,
            };
        });

        // calculate real weekly return using price history (from onGetWallet logic)
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);

        const totalTokensByStartup = mapTotalTokensByStartup(orders);

        const weeklyValues = await Promise.all(
            Object.entries(totalTokensByStartup).map(async ([startupId, quantity]) =>
            {
                const currentPrice = startupPriceMap.get(startupId);
                if (currentPrice === undefined) return {currentValue: 0, pastValue: 0};

                const snapshot = await getOldestSnapshotSince(startupId, weekAgo);
                const pastPrice = snapshot?.price ?? currentPrice;
                return {
                    currentValue: quantity * currentPrice,
                    pastValue: quantity * pastPrice,
                };
            }),
        );

        const {weeklyReturn, weeklyReturnPct} = calcWeeklyReturn(weeklyValues);
        const rendimentoDiarioValor = Math.round(weeklyReturn * 100) / 100;
        const rendimentoDiarioPorcentagem = Math.round(weeklyReturnPct * 100) / 100;

        // market stats
        const totalStartups = startups.length;

        // --- Pedro Henrique Medeiros dos Reis - 24801656 ---
        // Real monthly return: average % variation across all startups,
        // comparing today's price to the price from ~30 days ago in the
        // price_history snapshots. If a startup has no snapshot in the
        // window (newer than 30 days), we treat it as 0% (no contribution).
        const monthAgo = new Date();
        monthAgo.setDate(monthAgo.getDate() - 30);

        const startupReturns = await Promise.all(
            startups.map(async (s) =>
            {
                const snap = await getOldestSnapshotSince(s.id, monthAgo);
                if (snap === null || snap.price <= 0) return 0;
                return ((s.token_price - snap.price) / snap.price) * 100;
            }),
        );

        const rentabilidadeMedia = startupReturns.length > 0
            ? Math.round(
                (startupReturns.reduce((sum, r) => sum + r, 0) / startupReturns.length) * 100,
            ) / 100
            : 0;
        // --- end Pedro ---

        // extract favorite startup IDs
        const favoriteIds = favorites; // already string[]

        logger.info(`Dashboard data for user "${uid}" fetched successfully.`);

        return {
            favoriteIds,
            investimentos: investimentosFormatted,
            nomeUsuario: user.full_name,
            patrimonioTotal,
            rendimentoDiarioPorcentagem,
            rendimentoDiarioValor,
            rentabilidadeMediaMercado: rentabilidadeMedia,
            saldoDisponivel: wallet?.balance ?? 0,
            totalInvestidoresMercado: activeInvestors,
            totalStartupsMercado: totalStartups,
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

        const internal = new InternalError('Failed to fetch dashboard data.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
