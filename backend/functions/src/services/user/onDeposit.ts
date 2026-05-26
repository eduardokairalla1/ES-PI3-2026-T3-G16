// --- Function callable onDeposit ---
//
// Alex Gabriel Soares Sousa - 24802449
// Serviço para realização de depósitos virtuais na carteira digital do usuário.

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {getWalletBalance} from '../../db/wallets/storage';
import {getUserDocId} from '../../db/users/storage';
import {logger} from '../../utils/logger';
import {verifyAuth} from '../../utils/auth';
import db from '../../configs';


// --- ERRORS ---
import {AuthError} from '../../errors/authError';


// --- TYPES ---
import type {CallableRequest} from 'firebase-functions/v2/https';


// --- CODE ---

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
        let {amount, depositId} = request.data;

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

        const userDocId = await getUserDocId(uid);
        if (!userDocId)
        {
            throw new HttpsError('not-found', `Documento do usuário com UID "${uid}" não encontrado.`);
        }

        // 4. Executa o depósito e o registro histórico de forma atômica
        await db.runTransaction(async (tx) =>
        {
            const walletRef = db.collection('wallets').doc(uid);
            const walletSnap = await tx.get(walletRef);
            if (!walletSnap.exists)
            {
                throw new HttpsError('not-found', `Carteira não encontrada para o usuário "${uid}".`);
            }

            // Se depositId for informado, verifica se esta transação de depósito já foi processada
            let transactionRef;
            if (depositId)
            {
                transactionRef = db.collection('users')
                    .doc(userDocId)
                    .collection('transactions')
                    .doc(depositId);

                const transactionSnap = await tx.get(transactionRef);
                if (transactionSnap.exists)
                {
                    logger.info(`Deposit with ID "${depositId}" was already processed. Skipping balance increment...`);
                    return;
                }
            }
            else
            {
                transactionRef = db.collection('users')
                    .doc(userDocId)
                    .collection('transactions')
                    .doc();
            }

            const currentBalance = (walletSnap.data()?.balance as number) ?? 0;
            const newBalance = currentBalance + amount;

            // Incrementa o saldo do usuário na carteira digital (Firestore)
            tx.update(walletRef, {
                balance: newBalance,
                updated_at: new Date(),
            });

            // Registra o depósito no histórico geral de transações do usuário
            tx.set(transactionRef, {
                id: transactionRef.id,
                amount: amount,
                description: 'Depósito em conta',
                status: 'completed',
                type: 'deposit',
                created_at: new Date(),
            });
        });

        // 5. Consulta o saldo atualizado pós-transação para retorno da interface
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
