/**
 * Operações do Banco de Dados para Transações.
 * Este módulo gerencia a gravação e consulta das transações financeiras e operacionais do usuário,
 * gravadas na subcoleção `transactions` de cada usuário. Isso inclui depósitos de fundos fictícios,
 * bem como compras e vendas de tokens no balcão de negociações.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import db from '../../configs';


/**
 * TYPES
 */
import type {TransactionDocument} from './model';


/**
 * CODE
 */

/**
 * Registra uma nova movimentação/transação financeira na subcoleção do usuário no Firestore.
 * Atribui automaticamente a data atual de gravação (created_at).
 *
 * @param uid  Identificador exclusivo de autenticação (Firebase Auth UID) do usuário.
 * @param data Dados detalhados da transação (omitindo ID e data de criação que são gerados dinamicamente).
 */
export async function recordTransaction(
    uid: string,
    data: Omit<TransactionDocument, 'id' | 'created_at'>,
): Promise<void>
{
    // O documento do usuário sempre tem o mesmo ID que seu Firebase Auth UID
    // (ver addUser em users/storage.ts: db.collection('users').doc(uid).set(...))
    const transaction: Omit<TransactionDocument, 'id'> = {
        ...data,
        'created_at': new Date(),
    };

    await db.collection('users')
        .doc(uid)
        .collection('transactions')
        .add(transaction);
}


/**
 * Consulta e retorna o extrato de transações de um determinado usuário.
 * Os registros são ordenados de forma decrescente pela data de criação (transações mais recentes primeiro).
 *
 * @param uid   Identificador exclusivo de autenticação (Firebase Auth UID) do usuário.
 * @param limit Quantidade máxima de registros de transações a retornar (padrão 20).
 *
 * @returns Uma lista contendo as transações encontradas.
 */
export async function getTransactions(
    uid: string,
    limit?: number,
    startDate?: Date,
    endDate?: Date,
): Promise<TransactionDocument[]>
{
    // O documento do usuário sempre tem o mesmo ID que seu Firebase Auth UID
    let query = db.collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('created_at', 'desc');

    if (startDate)
    {
        query = query.where('created_at', '>=', startDate);
    }
    if (endDate)
    {
        query = query.where('created_at', '<', endDate);
    }
    if (limit !== undefined)
    {
        query = query.limit(limit);
    }

    const snapshot = await query.get();

    return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
    } as TransactionDocument));
}
