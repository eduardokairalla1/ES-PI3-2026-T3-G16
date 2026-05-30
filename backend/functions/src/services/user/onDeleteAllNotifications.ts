/**
 * Callable onDeleteAllNotifications — wipes the inbox in one shot.
 * Powers the "Marcar como lido" label in the modal.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 */


/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {deleteAllNotifications} from '../../db/notifications/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * CODE
 */

export async function handleOnDeleteAllNotifications(request: CallableRequest)
{
    try
    {
        const uid = verifyAuth(request);

        const deletedCount = await deleteAllNotifications(uid);
        logger.info(`Cleared ${deletedCount} notification(s) for user "${uid}".`);

        return {deletedCount};
    }
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Failed to clear notifications.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
