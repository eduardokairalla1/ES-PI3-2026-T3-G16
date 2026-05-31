/**
 * Callable onGetNotifications — lists the user's pending notifications.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 */


/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getRecentNotifications} from '../../db/notifications/storage';
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

export async function handleOnGetNotifications(request: CallableRequest)
{
    try
    {
        const uid = await verifyAuth(request);
        const docs = await getRecentNotifications(uid);

        // camelCase response for the Flutter client
        return {
            notifications: docs.map(d => ({
                body:      d.body,
                createdAt: d.created_at,
                id:        d.id,
                payload:   d.payload,
                title:     d.title,
                type:      d.type,
            })),
        };
    }
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Failed to fetch notifications.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
