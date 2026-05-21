/* Function callable onDeposit.
 * Serviço para realização de depósitos virtuais na carteira digital do usuário.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {depositToWallet, getWalletBalance} from '../../db/wallets/storage';
import {recordTransaction} from '../../db/transactions/storage';
import {logger} from '../../utils/logger';
import {verifyAuth} from '../../utils/auth';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * CODE
 */

/**
 * Manipula a requisição da Cloud Function Callable 'onDeposit'.
 * Adiciona fundos à carteira digital do investidor autenticado e registra um histórico de depósito.
 *
 * @param request Objeto da requisição contendo o payload `{ amount: number }` indicando o valor do depósito.
 * @returns Um objeto contendo o novo saldo da carteira (`newBalance`) e uma mensagem de confirmação de sucesso.
 */
export async function handleOnDeposit(request: CallableRequest)
{
    try
    {
        // 1. Valida se a requisição provém de um usuário autenticado no Firebase
        const uid = verifyAuth(request);
        let {amount} = request.data;

        // 2. Validação de regras de negócio para o valor de depósito
        // Garante que o valor informado é numérico e estritamente positivo
        if (typeof amount !== 'number' || amount <= 0)
        {
            throw new HttpsError('invalid-argument', 'O valor do depósito deve ser um número positivo.');
        }

        // Impõe um limite de teto para depósitos individuais no ecossistema (R$ 100.000,00)
        if (amount > 100000)
        {
            throw new HttpsError('out-of-range', 'O valor máximo para cada depósito é de R$ 100.000,00.');
        }

        // 3. Arredonda o valor para garantir precisão exata de duas casas decimais (centavos)
        amount = Math.round(amount * 100) / 100;

        logger.info(`Processando depósito de R$ ${amount} para o usuário "${uid}"...`);

        // 4. Incrementa o saldo do usuário na carteira digital (Firestore)
        await depositToWallet(uid, amount);

        // 5. Registra o depósito no histórico geral de transações do usuário
        await recordTransaction(uid, {
            amount: amount,
            description: 'Depósito em conta',
            status: 'completed',
            type: 'deposit',
        });

        // 6. Consulta o saldo atualizado pós-transação para retorno da interface
        const newBalance = await getWalletBalance(uid);

        return {
            newBalance,
            message: `Depósito de R$ ${amount} realizado com sucesso.`,
        };

    }
    catch (error: unknown)
    {
        // Tratamento específico para erros de autenticação (ex: token expirado/ausente)
        if (error instanceof AuthError)
        {
            throw new HttpsError('unauthenticated', error.message);
        }

        // Erros de argumento/teto já validados são repassados diretamente
        if (error instanceof HttpsError) throw error;

        // Loga falhas inesperadas e retorna um erro genérico
        logger.error('Falha ao processar o depósito:', error);
        throw new HttpsError('internal', 'Falha interna ao processar o depósito.');
    }
}
