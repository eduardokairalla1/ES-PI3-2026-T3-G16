/**
 * Function callable onGetDashboard.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getUser, getUserCount} from '../../db/users/storage';
import {getUserFavoriteIds} from '../../db/favorites/storage';
import {getStartups} from '../../db/startups/storage';
import {getWallet} from '../../db/wallets/storage';
import {getUserInvestments} from '../../db/investments/storage';
import {getOldestSnapshotSince} from '../../db/price_history/storage';
import {calcWeeklyReturn} from '../../utils/walletUtils';
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

        const [user, favorites, startups, userCount, wallet, investments] = await Promise.all([
            getUser(uid),
            getUserFavoriteIds(uid),
            getStartups(),
            getUserCount(),
            getWallet(uid),
            getUserInvestments(uid),
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

        // derive portfolio from actual user investments
        let patrimonioTotal = 0;

        const investimentosFormatted = investments.filter(inv => inv.token_quantity > 0).map((holding) =>
        {
            const startupId = holding.startup_id;
            const currentPrice = startupPriceMap.get(startupId) ?? 0;
            const avgPrice     = holding.avg_purchase_price;
            const currentValue = holding.token_quantity * currentPrice;
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
                tokenQuantity:  holding.token_quantity,
                variation:      Math.round(variation * 100) / 100,
            };
        });

        // calculate real weekly return using price history (from onGetWallet logic)
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);

        const totalTokensByStartup: Record<string, number> = {};
        for (const inv of investments) {
            if (inv.token_quantity > 0) {
                totalTokensByStartup[inv.startup_id] = inv.token_quantity;
            }
        }

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

        // calculate average market profitability as percentage variation per startup
        // uses (capital_raised / total_tokens) as a proxy for initial cost price
        const rentabilidadeMedia = startups.length > 0
            ? Math.round(
                startups.reduce((sum, s) =>
                {
                    const costPrice = s.total_tokens > 0 ? s.capital_raised / s.total_tokens : 0;
                    const variation = costPrice > 0
                        ? ((s.token_price - costPrice) / costPrice) * 100
                        : 0;
                    return sum + variation;
                }, 0) / startups.length * 100,
            ) / 100
            : 0;

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
            totalInvestidoresMercado: userCount,
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
