/* Function callable onDeposit.
 * Serviço para realização de depósitos virtuais na carteira digital do usuário.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {createNotification} from '../../db/notifications/storage';
import {logger} from '../../utils/logger';
import {verifyAuth} from '../../utils/auth';
import db from '../../configs';


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
        const uid = await verifyAuth(request);
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

        logger.info(`Processing deposit of R$ ${amount} for user "${uid}"...`);

        // 4. Executa o depósito de forma atômica no banco de dados
        const newBalance = await db.runTransaction(async (tx) =>
        {
            const walletRef = db.collection('wallets').doc(uid);
            const walletSnap = await tx.get(walletRef);

            if (!walletSnap.exists)
            {
                throw new HttpsError('not-found', `Carteira não encontrada para o usuário "${uid}".`);
            }

            const currentBalance = (walletSnap.data()?.balance as number) ?? 0;
            const updatedBalance = Math.round((currentBalance + amount) * 100) / 100;
            const now = new Date();

            tx.update(walletRef, {
                balance: updatedBalance,
                updated_at: now,
            });

            const txRef = db.collection('users').doc(uid).collection('transactions').doc();
            tx.set(txRef, {
                amount: amount,
                created_at: now,
                description: 'Depósito em conta',
                id: txRef.id,
                status: 'completed',
                type: 'deposit',
            });

            return updatedBalance;
        });

        // 5. In-app notification of the confirmed deposit (best-effort).
        const formattedAmount = new Intl.NumberFormat('pt-BR', {
            currency: 'BRL',
            style: 'currency',
        }).format(amount);

        await createNotification(
            uid,
            'deposit_confirmed',
            'Depósito confirmado',
            `${formattedAmount} foi adicionado à sua carteira.`,
        );

        return {
            message: `Depósito de R$ ${amount} realizado com sucesso.`,
            newBalance,
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
        logger.error('Failed to process deposit:', error);
        throw new HttpsError('internal', 'Falha interna ao processar o depósito.');
    }
}
