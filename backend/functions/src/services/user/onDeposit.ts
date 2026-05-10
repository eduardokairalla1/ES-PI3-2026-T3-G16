/* Function callable onDeposit.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import { HttpsError } from 'firebase-functions/v2/https';
import { deposit, getUser } from '../../db/users/storage';
import { recordTransaction } from '../../db/transactions/storage';
import { logger } from '../../utils/logger';


/**
 * ERRORS
 */
import { AuthError } from '../../errors/authError';


/**
 * TYPES
 */
import type { CallableRequest } from 'firebase-functions/v2/https';


/**
 * CODE
 */

/**
 * I handle the onDeposit callable.
 * Increments user balance and returns the new value.
 *
 * @param request Body: { amount: number }
 */
export async function handleOnDeposit(request: CallableRequest) {
    try {
        // verify authentication
        if (request.auth === null || request.auth === undefined) {
            throw new AuthError('User must be authenticated.');
        }

        const { uid } = request.auth;
        let { amount } = request.data;

        // validation
        if (typeof amount !== 'number' || amount <= 0) {
            throw new HttpsError('invalid-argument', 'Amount must be a positive number.');
        }

        if (amount > 100000) {
            throw new HttpsError('out-of-range', 'Maximum deposit amount is R$ 100.000,00.');
        }

        // enforce 2 decimal places precision
        amount = Math.round(amount * 100) / 100;

        logger.info(`Processing deposit of R$ ${amount} for user "${uid}"...`);


        await deposit(uid, amount);

        // Record in transaction history
        await recordTransaction(uid, {
            amount: amount,
            description: 'Depósito em conta',
            status: 'completed',
            type: 'deposit',
        });
        
        // Fetch updated balance via existing storage function
        const updatedUser = await getUser(uid);
        const newBalance = updatedUser?.balance ?? 0;

        return {
            newBalance,
            message: 'Deposit successful.',
        };

    }
    catch (error: unknown) {
        if (error instanceof AuthError) {
            throw new HttpsError('unauthenticated', error.message);
        }

        if (error instanceof HttpsError) throw error;

        logger.error('Deposit failed:', error);
        throw new HttpsError('internal', 'Failed to process deposit.');
    }
}
