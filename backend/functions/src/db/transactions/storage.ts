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
import {getUserDocId} from '../users/storage';


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
    // 1. Obtém o ID interno do documento do usuário correspondente ao UID de Auth
    const userDocId = await getUserDocId(uid);
    if (!userDocId) throw new Error(`Usuário com UID "${uid}" não foi localizado para gravar a transação.`);

    // 2. Prepara o documento de transação anexando o carimbo de data/hora atual
    const transaction: Omit<TransactionDocument, 'id'> = {
        ...data,
        'created_at': new Date(),
    };

    // 3. Salva a transação na subcoleção física no Firestore
    await db.collection('users')
        .doc(userDocId)
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
export async function getTransactions(uid: string, limit = 20): Promise<TransactionDocument[]>
{
    // 1. Obtém o ID de documento do usuário
    const userDocId = await getUserDocId(uid);
    if (!userDocId) return [];

    // 2. Executa a busca ordenada e limitada no Firestore
    const snapshot = await db.collection('users')
        .doc(userDocId)
        .collection('transactions')
        .orderBy('created_at', 'desc')
        .limit(limit)
        .get();

    // 3. Retorna os documentos formatados de acordo com a interface model correspondente
    return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
    } as TransactionDocument));
}
