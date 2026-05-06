/**
 * Function callable onGetTransactions.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import { HttpsError } from 'firebase-functions/v2/https';
import { getTransactions } from '../../db/transactions/storage';
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
 * I handle the onGetTransactions callable.
 * Returns the list of recent transactions for the user.
 *
 * @param request Body: { limit?: number }
 */
export async function handleOnGetTransactions(request: CallableRequest) {
    try {
        // verify authentication
        if (request.auth === null || request.auth === undefined) {
            throw new AuthError('User must be authenticated.');
        }

        const { uid } = request.auth;
        const limit = request.data.limit || 20;

        logger.info(`Fetching transactions for user "${uid}" (limit: ${limit})...`);

        const transactions = await getTransactions(uid, limit);

        return {
            transactions,
        };
    }
    catch (error: unknown) {
        if (error instanceof AuthError) {
            throw new HttpsError('unauthenticated', error.message);
        }

        logger.error('Failed to fetch transactions:', error);
        throw new HttpsError('internal', 'Failed to fetch transaction history.');
    }
}
