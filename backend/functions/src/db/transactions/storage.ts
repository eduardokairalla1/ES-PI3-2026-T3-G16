/**
 * Transaction database operations.
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
 * I record a new transaction for a user.
 *
 * @param uid         Firebase Auth UID
 * @param transaction Transaction data (without ID and Date)
 */
export async function recordTransaction(
    uid: string,
    data: Omit<TransactionDocument, 'id' | 'created_at'>,
): Promise<void>
{
    const userDocId = await getUserDocId(uid);
    if (!userDocId) throw new Error(`User "${uid}" not found.`);

    const transaction: Omit<TransactionDocument, 'id'> = {
        ...data,
        'created_at': new Date(),
    };

    await db.collection('users')
        .doc(userDocId)
        .collection('transactions')
        .add(transaction);
}


/**
 * I get the transactions for a user.
 *
 * @param uid Firebase Auth UID
 * @param limit max number of transactions to return
 *
 * @returns list of transactions
 */
export async function getTransactions(uid: string, limit = 20): Promise<TransactionDocument[]>
{
    const userDocId = await getUserDocId(uid);
    if (!userDocId) return [];

    const snapshot = await db.collection('users')
        .doc(userDocId)
        .collection('transactions')
        .orderBy('created_at', 'desc')
        .limit(limit)
        .get();

    return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
    } as TransactionDocument));
}
