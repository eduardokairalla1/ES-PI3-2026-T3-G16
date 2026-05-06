 * Function callable onDeposit.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import db from '../../configs';
import {deposit} from '../../db/users/storage';
import {logger} from '../../utils/logger';


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
 * I handle the onDeposit callable.
 * Increments user balance and returns the new value.
 *
 * @param request Body: { amount: number }
 */
export async function handleOnDeposit(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        const {uid} = request.auth;
        const {amount} = request.data;

        // validation
        if (typeof amount !== 'number' || amount <= 0)
        {
            throw new HttpsError('invalid-argument', 'Amount must be a positive number.');
        }

        logger.info(`Processing deposit of R$ ${amount} for user "${uid}"...`);

        await deposit(uid, amount);
        
        // Fetch updated balance
        const updatedUser = await db.collection('users').where('uid', '==', uid).limit(1).get();
        const newBalance = updatedUser.docs[0].data().balance;

        return {
            newBalance,
            message: 'Deposit successful.',
        };

    }
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            throw new HttpsError('unauthenticated', error.message);
        }

        if (error instanceof HttpsError) throw error;

        logger.error('Deposit failed:', error);
        throw new HttpsError('internal', 'Failed to process deposit.');
    }
}
