/**
 * Function callable onGetTransactions.
 * Retorna um extrato unificado contendo depósitos da carteira e transações de ordens de compra/venda de tokens.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

import {HttpsError} from 'firebase-functions/v2/https';
import {getTransactions} from '../../db/transactions/storage';
import {getAllCompletedOrdersByUid} from '../../db/orders/storage';
import {getStartups} from '../../db/startups/storage';
import {logger} from '../../utils/logger';
import {verifyAuth} from '../../utils/auth';

import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';

import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * Manipula a requisição da Cloud Function Callable 'onGetTransactions'.
 * Busca, unifica, ordena e limita o histórico de atividades financeiras e de investimentos do investidor.
 *
 * Combina dois fluxos de dados distintos do banco:
 * 1. Transações de depósito direto na carteira virtual.
 * 2. Ordens de compra e venda de tokens de startups concluídas com sucesso.
 *
 * @param request Objeto da requisição contendo o payload opcional (ex: limit para paginação/limitação).
 * @returns Extrato consolidado de transações formatadas e ordenadas por data (mais recente primeiro).
 */
export async function handleOnGetTransactions(request: CallableRequest)
{
    try
    {
        // 1. Valida se a requisição provém de um usuário autenticado no Firebase
        const uid = verifyAuth(request);
        
        // Define o limite padrão de transações a retornar se não especificado pelo cliente (default: 20)
        const limit: number = request.data.limit || 20;

        logger.info(`Buscando histórico unificado de transações para o usuário "${uid}"...`);

        // 2. Executa consultas paralelas ao Firestore para reduzir a latência total
        // - getTransactions: busca os depósitos
        // - getAllCompletedOrdersByUid: busca as ordens concluídas
        // - getStartups: busca todas as startups cadastradas para obter seus nomes amigáveis
        const [deposits, orders, startups] = await Promise.all([
            getTransactions(uid, 200),
            getAllCompletedOrdersByUid(uid),
            getStartups(),
        ]);

        // 3. Constrói um mapa de ID de startup para Nome para acelerar o lookup em O(1)
        const startupNameMap = new Map<string, string>();
        for (const s of startups)
        {
            startupNameMap.set(s.id, s.name);
        }

        // 4. Mapeia o histórico de ordens concluídas para o formato unificado de transação
        const orderTransactions = orders.map(order =>
        {
            const startupName = startupNameMap.get(order.startup_id) ?? order.startup_id;
            
            // Define a descrição da transação baseado no tipo da ordem (compra ou venda)
            const description = order.type === 'buy'
                ? `Compra de tokens — ${startupName}`
                : `Venda de tokens — ${startupName}`;

            return {
                id:          order.id,
                amount:      order.total_amount,
                description,
                created_at:  order.completed_at ?? order.created_at,
                type:        order.type,
                status:      order.status,
            };
        });

        // 5. Filtra a lista de transações para incluir apenas depósitos e saques (excluindo compras/vendas)
        // e mescla com o histórico de ordens concluídas obtidas da coleção de ordens.
        // Isso evita duplicação de dados no extrato, já que compras/vendas são gravadas em ambas as coleções.
        const depositsOnly = deposits.filter(t => t.type !== 'buy' && t.type !== 'sell');

        // E ordena as transações pela data de criação em ordem decrescente (mais recente primeiro)
        const all = [...depositsOnly, ...orderTransactions].sort((a, b) =>
        {
            const dateA = a.created_at instanceof Date ? a.created_at : new Date(a.created_at as string);
            const dateB = b.created_at instanceof Date ? b.created_at : new Date(b.created_at as string);
            return dateB.getTime() - dateA.getTime();
        });

        // 6. Aplica o limite de paginação especificado
        const transactions = all.slice(0, limit);

        logger.info(`Retornando ${transactions.length} transações para o usuário "${uid}".`);

        return {transactions};
    }
    catch (error: unknown)
    {
        // Tratamento de erros de autenticação identificados no verifyAuth
        if (error instanceof AuthError)
        {
            throw new HttpsError('unauthenticated', error.message);
        }

        // Encapsula quaisquer outros erros internos indesejados
        const internal = new InternalError('Falha ao buscar o histórico de transações unificado.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
