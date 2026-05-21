/**
 * Investment database operations.
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
import type {InvestmentDocument} from './model';


/**
 * CODE
 */


/**
 * I get all investments for a user.
 *
 * @param uid Firebase Auth UID of the user
 *
 * @returns list of investment documents
 */
export async function getUserInvestments(uid: string): Promise<InvestmentDocument[]>
{
    const userDocId = await getUserDocId(uid);
    if (userDocId === null) return [];

    const snapshot = await db
        .collection('users')
        .doc(userDocId)
        .collection('investments')
        .orderBy('startup_name')
        .get();

    return snapshot.docs.map(doc => ({id: doc.id, ...doc.data()} as InvestmentDocument));
}
