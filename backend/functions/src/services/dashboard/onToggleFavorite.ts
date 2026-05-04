/**
 * Function callable onToggleFavorite.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {toggleFavorite} from '../../db/favorites/storage';
import {getStartup} from '../../db/startups/storage';
import {logger} from '../../utils/logger';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {NotFoundError} from '../../errors/notFoundError';
import {ValidationError} from '../../errors/validationError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';
import {ToggleFavoriteRequest} from '../../types/responders/dashboard';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * I handle the onToggleFavorite callable.
 * Toggles the favorite status of a startup for the authenticated user.
 *
 * @param request callable request with startup ID
 *
 * @returns object with the new favorite status
 */
export async function handleOnToggleFavorite(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        // validate request data
        const parsed = parseRequest(ToggleFavoriteRequest, request.data);

        const {uid} = request.auth;

        // verify startup exists
        const startup = await getStartup(parsed.startupId);
        if (startup === null)
        {
            throw new NotFoundError(`Startup "${parsed.startupId}" not found.`);
        }

        // toggle favorite
        logger.info(`Toggling favorite for user "${uid}" on startup "${parsed.startupId}"...`);
        const isFavorited = await toggleFavorite(uid, parsed.startupId);
        logger.info(`Startup "${parsed.startupId}" is now ${isFavorited ? 'favorited' : 'unfavorited'} by user "${uid}".`);

        return {
            isFavorited,
            startupId: parsed.startupId,
        };
    }

    // handle errors
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }
        if (error instanceof NotFoundError)
        {
            logger.error(error.message);
            throw new HttpsError('not-found', error.message);
        }
        if (error instanceof ValidationError)
        {
            logger.error(error.message);
            throw new HttpsError('invalid-argument', error.message);
        }

        const internal = new InternalError('Failed to toggle favorite.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
