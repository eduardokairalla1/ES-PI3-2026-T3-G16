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
        const uid = verifyAuth(request);

        // 2. Dispara consultas assíncronas em paralelo no Firestore para otimizar o tempo de resposta (latência)
        logger.info(`Buscando dados consolidados do dashboard para o usuário "${uid}"...`);

        const [user, favorites, startups, activeInvestors, wallet, orders] = await Promise.all([
            getUser(uid),
            getUserFavoriteIds(uid),
            getStartups(),
            countActiveInvestors(),
            getWallet(uid),
            getOrdersByTypeAndStatus(uid, 'buy', 'completed'),
        ]);

        // Valida se o documento de perfil do usuário existe no banco de dados
        if (user === null)
        {
            throw new AuthError(`Perfil do usuário "${uid}" não foi encontrado no banco de dados.`);
        }

        // 3. Constrói mapas de busca (lookup maps) para otimizar a associação de startups por ID (complexidade O(1))
        const startupPriceMap = new Map<string, number>();
        const startupNameMap  = new Map<string, {name: string; logoUrl: string}>();
        for (const s of startups)
        {
            startupPriceMap.set(s.id, s.token_price);
            startupNameMap.set(s.id, {name: s.name, logoUrl: s.logo_url ?? ''});
        }

        // 4. Calcula a custódia (holdings) atual do usuário com base no histórico de ordens de compra finalizadas
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

        // 5. Formata os investimentos ativos calculando o preço médio de aquisição, valor de mercado atual e variação percentual
        const investimentosFormatted = Array.from(holdingsByStartup.entries()).map(([startupId, holding]) =>
        {
            const currentPrice = startupPriceMap.get(startupId) ?? 0;
            const avgPrice     = holding.quantity > 0 ? holding.totalCost / holding.quantity : 0;
            const currentValue = holding.quantity * currentPrice;
            
            // Calcula variação percentual do investimento
            const variation    = avgPrice > 0
                ? ((currentPrice - avgPrice) / avgPrice) * 100
                : 0;

            // Incrementa o patrimônio total investido em ativos
            patrimonioTotal += currentValue;

            const details = startupNameMap.get(startupId) ?? {name: '', logoUrl: ''};

            return {
                currentPrice,
                startupId,
                startupLogoUrl: details.logoUrl,
                startupName:    details.name,
                tokenQuantity:  holding.quantity,
                variation:      Math.round(variation * 100) / 100, // Arredonda para 2 casas decimais
            };
        });

        // 6. Calcula a rentabilidade semanal real do portfólio utilizando o histórico de preços (últimos 7 dias)
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);

        const totalTokensByStartup = mapTotalTokensByStartup(orders);

        const weeklyValues = await Promise.all(
            Object.entries(totalTokensByStartup).map(async ([startupId, quantity]) =>
            {
                const currentPrice = startupPriceMap.get(startupId);
                if (currentPrice === undefined) return {currentValue: 0, pastValue: 0};

                // Recupera o snapshot de preço mais antigo dentro da janela de 7 dias
                const snapshot = await getOldestSnapshotSince(startupId, weekAgo);
                const pastPrice = snapshot?.price ?? currentPrice;
                return {
                    currentValue: quantity * currentPrice,
                    pastValue: quantity * pastPrice,
                };
            }),
        );

        // Calcula a variação bruta e percentual do portfólio na semana
        const {weeklyReturn, weeklyReturnPct} = calcWeeklyReturn(weeklyValues);
        const rendimentoDiarioValor = Math.round(weeklyReturn * 100) / 100;
        const rendimentoDiarioPorcentagem = Math.round(weeklyReturnPct * 100) / 100;

        // 7. Estatísticas gerais do ecossistema Mescla
        const totalStartups = startups.length;

        // --- Pedro Henrique Medeiros dos Reis - 24801656 ---
        // Rentabilidade mensal real: calcula a variação média de preço de todas as startups do ecossistema,
        // comparando o preço atual com o valor de ~30 dias atrás nos históricos.
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

        // Recupera a lista de IDs de startups favoritas do usuário
        const favoriteIds = favorites;

        logger.info(`Dados do dashboard compilados com sucesso para o usuário "${uid}".`);

        // Retorna todos os dados prontos para consumo na UI do aplicativo
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

    // Tratamento unificado de erros
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(`Erro de autenticação ao obter dashboard: ${error.message}`);
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Falha interna ao compilar dados do dashboard.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
