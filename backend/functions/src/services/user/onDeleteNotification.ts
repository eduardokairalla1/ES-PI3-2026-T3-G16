/**
 * Callable onDeleteNotification — removes a single notification.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 */


/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {deleteNotification} from '../../db/notifications/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {ValidationError} from '../../errors/validationError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * CODE
 */

export async function handleOnDeleteNotification(request: CallableRequest)
{
    try
    {
        const uid = verifyAuth(request);

        const notificationId = request.data?.notificationId;
        if (typeof notificationId !== 'string' || notificationId.length === 0)
        {
            throw new ValidationError('notificationId must be a non-empty string.');
        }

        await deleteNotification(uid, notificationId);

        return {deleted: true};
    }
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }
        if (error instanceof ValidationError)
        {
            logger.error(error.message);
            throw new HttpsError('invalid-argument', error.message);
        }

        const internal = new InternalError('Failed to delete notification.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
