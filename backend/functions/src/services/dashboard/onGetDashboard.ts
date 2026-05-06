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
import {getUserInvestments} from '../../db/investments/storage';
import {getUserFavorites} from '../../db/favorites/storage';
import {getStartups} from '../../db/startups/storage';
import {logger} from '../../utils/logger';


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
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        const {uid} = request.auth;

        // fetch all data in parallel for performance
        logger.info(`Fetching dashboard data for user "${uid}"...`);

        const [user, investments, favorites, startups, userCount] = await Promise.all([
            getUser(uid),
            getUserInvestments(uid),
            getUserFavorites(uid),
            getStartups(),
            getUserCount(),
        ]);

        // user not found
        if (user === null)
        {
            throw new AuthError(`Profile not found for user "${uid}".`);
        }

        // build startup price lookup map
        const startupPriceMap = new Map<string, number>();
        for (const s of startups)
        {
            startupPriceMap.set(s.id, s.token_price);
        }

        // calculate portfolio total and investments with current prices
        let patrimonioTotal = 0;
        let rendimentoTotal = 0;
        let custoTotal = 0;

        const investimentosFormatted = investments.map(inv =>
        {
            const currentPrice = startupPriceMap.get(inv.startup_id) ?? inv.avg_purchase_price;
            const currentValue = inv.token_quantity * currentPrice;
            const costValue = inv.token_quantity * inv.avg_purchase_price;
            const variation = inv.avg_purchase_price > 0
                ? ((currentPrice - inv.avg_purchase_price) / inv.avg_purchase_price) * 100
                : 0;

            patrimonioTotal += currentValue;
            rendimentoTotal += (currentValue - costValue);
            custoTotal += costValue;

            return {
                currentPrice,
                startupId: inv.startup_id,
                startupLogoUrl: inv.startup_logo_url,
                startupName: inv.startup_name,
                tokenQuantity: inv.token_quantity,
                variation: Math.round(variation * 100) / 100,
            };
        });

        // calculate daily yield as a fraction of total variation
        // (simulates daily movement as ~1/30 of monthly variation)
        const rendimentoDiarioPorcentagem = custoTotal > 0
            ? Math.round(((rendimentoTotal / custoTotal) * 100 / 30) * 100) / 100
            : 0;
        const rendimentoDiarioValor = Math.round((rendimentoTotal / 30) * 100) / 100;

        // market stats
        const totalStartups = startups.length;

        // calculate average market profitability from all startups
        // (average token price change — simplified)
        const rentabilidadeMedia = startups.length > 0
            ? Math.round(
                (startups.reduce((sum, s) => sum + s.token_price, 0) / startups.length) * 100,
            ) / 100
            : 0;

        // extract favorite startup IDs
        const favoriteIds = favorites.map(f => f.startup_id);

        logger.info(`Dashboard data for user "${uid}" fetched successfully.`);

        return {
            favoriteIds,
            investimentos: investimentosFormatted,
            nomeUsuario: user.full_name,
            patrimonioTotal,
            saldoDisponivel: user.balance ?? 0,
            rendimentoDiarioPorcentagem,

            rendimentoDiarioValor,
            rentabilidadeMediaMercado: rentabilidadeMedia,
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
