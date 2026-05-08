/**
 * Function callable onUpdateProfile.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getUser, updateUser} from '../../db/users/storage';
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
import {UpdateProfileRequest} from '../../types/responders/user';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * I handle the onUpdateProfile callable.
 * Allows the authenticated user to update their name and/or photo URL.
 *
 * @param request callable request with optional fullName and photoUrl
 *
 * @returns updated profile fields
 */
export async function handleOnUpdateProfile(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        // validate request data
        const parsed = parseRequest(UpdateProfileRequest, request.data);

        // build updates object
        const updates: Parameters<typeof updateUser>[1] = {};
        if (parsed.fullName !== undefined) updates.full_name = parsed.fullName;
        if (parsed.phone    !== undefined) updates.phone     = parsed.phone;
        if (parsed.photoUrl !== undefined) updates.photo_url = parsed.photoUrl;

        if (Object.keys(updates).length === 0)
        {
            throw new ValidationError('No fields provided to update.');
        }

        // apply updates
        logger.info(`Updating profile for user "${request.auth.uid}"...`);
        await updateUser(request.auth.uid, updates);

        // fetch and return the refreshed profile
        const user = await getUser(request.auth.uid);
        if (user === null)
        {
            throw new AuthError(`User "${request.auth.uid}" not found after update.`);
        }

        logger.info(`Profile for user "${request.auth.uid}" updated successfully.`);

        return {
            fullName: user.full_name,
            phone:    user.phone,
            photoUrl: user.photo_url,
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
        if (error instanceof ValidationError)
        {
            logger.error(error.message);
            throw new HttpsError('invalid-argument', error.message);
        }

        const internal = new InternalError('Failed to update profile.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
