/**
 * Function callable onGetDashboard.
 * Serviço responsável por consolidar e retornar todas as informações do Dashboard do usuário.
 * Realiza consultas agregadas para obter dados de perfil, carteira, investimentos,
 * startups favoritas e estatísticas gerais do mercado em uma única chamada.
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
import {countActiveInvestors} from '../../db/orders/storage';
import {getHistoricalPrice} from '../../db/price_history/storage';
import {computeWalletState} from '../../utils/walletUtils';
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
 * Manipula a requisição da Cloud Function Callable 'onGetDashboard'.
 * Consolida as informações de perfil do usuário, saldo da carteira digital, investimentos
 * em startups (calculados a partir do histórico de ordens executadas) e indicadores gerais
 * do mercado inovador do Mescla.
 *
 * @param request Objeto da requisição contendo o contexto de autenticação do usuário.
 * @returns Um objeto com dados consolidados do dashboard do investidor.
 */
export async function handleOnGetDashboard(request: CallableRequest)
{
    try
    {
        // 1. Valida se a requisição provém de um usuário devidamente autenticado
        const uid = await verifyAuth(request);

        // 2. Dispara consultas assíncronas em paralelo no Firestore para otimizar o tempo de resposta (latência)
        logger.info(`Fetching consolidated dashboard data for user "${uid}"...`);

        const [user, favorites, startups, activeInvestors, wallet] = await Promise.all([
            getUser(uid),
            getUserFavoriteIds(uid),
            getStartups(),
            countActiveInvestors(),
            getWallet(uid),
        ]);

        // Valida se o documento de perfil do usuário existe no banco de dados
        if (user === null)
        {
            throw new AuthError(`Perfil do usuário "${uid}" não foi encontrado no banco de dados.`);
        }

        // 3. Constrói mapas de busca (lookup maps) para otimizar a associação de startups por ID (complexidade O(1))
        const startupPriceMap = new Map<string, number>();
        const startupNameMap  = new Map<string, {name: string; logoUrl: string; tokenName: string}>();
        for (const s of startups)
        {
            startupPriceMap.set(s.id, s.token_price);
            startupNameMap.set(s.id, {name: s.name, logoUrl: s.logo_url ?? '', tokenName: s.token_name ?? ''});
        }

        // 4. Calcula a custódia (holdings) atual do usuário e o rendimento semanal utilizando a nova função com fluxo de caixa
        const {holdingsByStartup, weeklyReturn, weeklyReturnPct} = await computeWalletState(uid, startupPriceMap);

        let assetsValue = 0;

        // 5. Formata os investimentos ativos calculando o preço médio de aquisição, valor de mercado atual e variação percentual
        const investimentosFormatted = Array.from(holdingsByStartup.entries()).map(([startupId, holding]) =>
        {
            const currentPrice = startupPriceMap.get(startupId) ?? 0;
            const avgPrice     = holding.buyQuantity > 0 ? holding.totalCost / holding.buyQuantity : 0;
            const currentValue = holding.quantity * currentPrice;

            // Calcula variação percentual do investimento
            const variation    = avgPrice > 0
                ? ((currentPrice - avgPrice) / avgPrice) * 100
                : 0;

            // Incrementa o patrimônio total investido em ativos
            assetsValue += currentValue;

            const details = startupNameMap.get(startupId) ?? {name: '', logoUrl: '', tokenName: ''};

            return {
                currentPrice,
                startupId,
                startupLogoUrl: details.logoUrl,
                startupName:    details.name,
                tokenName:      details.tokenName,
                tokenQuantity:  holding.quantity,
                variation:      Math.round(variation * 100) / 100, // Arredonda para 2 casas decimais
            };
        });

        const patrimonioTotal = (wallet?.balance ?? 0) + assetsValue;

        // 6. Calcula a variação bruta e percentual do portfólio na semana arredondando os valores
        const rendimentoDiarioValor = Math.round(weeklyReturn * 100) / 100;
        const rendimentoDiarioPorcentagem = Math.round(weeklyReturnPct * 100) / 100;

        // 7. Estatísticas gerais do ecossistema Mescla
        const totalStartups = startups.length;

        // --- Pedro Henrique Medeiros dos Reis - 24801656 ---
        // Maior alta do mês: encontra a startup com a maior valorização de preço
        // nos últimos 30 dias comparando o preço atual com o preço histórico de 30 dias atrás.
        const monthAgo = new Date();
        monthAgo.setDate(monthAgo.getDate() - 30);

        // Para cada startup, busca o preço histórico de 30 dias atrás e calcula a variação percentual
        const startupChanges = await Promise.all(
            startups.map(async (s) =>
            {
                const histPrice = await getHistoricalPrice(s.id, monthAgo, s.base_price, s.token_price);
                const pct = histPrice > 0 ? ((s.token_price - histPrice) / histPrice) * 100 : 0;
                return {name: s.name, pct};
            }),
        );

        let maiorAltaNome: string | null = null;
        let maiorAltaPct: number | null  = null;
        
        // Encontra a startup que teve a maior valorização percentual (incluindo as de 0% de variação)
        if (startupChanges.length > 0)
        {
            const best = startupChanges.reduce((a, b) => (a.pct > b.pct ? a : b));
            maiorAltaNome = best.name;
            maiorAltaPct  = Math.round(best.pct * 100) / 100;
        }
        // --- end Pedro ---

        // Recupera a lista de IDs de startups favoritas do usuário
        const favoriteIds = favorites;

        logger.info(`Dashboard data compiled successfully for user "${uid}".`);

        // Retorna todos os dados prontos para consumo na UI do aplicativo
        return {
            favoriteIds,
            investimentos: investimentosFormatted,
            nomeUsuario: user.full_name,
            patrimonioTotal,
            rendimentoDiarioPorcentagem,
            rendimentoDiarioValor,
            maiorAltaNome,
            maiorAltaPct,
            saldoDisponivel: wallet?.balance ?? 0,
            totalInvestidoresMercado: activeInvestors,
            totalStartupsMercado: totalStartups,
        };
    }

    // Tratamento unificado de erros
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(`Authentication error fetching dashboard: ${error.message}`);
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Falha interna ao compilar dados do dashboard.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
