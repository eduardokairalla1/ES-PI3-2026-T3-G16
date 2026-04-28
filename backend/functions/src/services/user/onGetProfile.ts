/**
 * Function callable onGetProfile.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getUser} from '../../db/users/storage';
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

/**
 * I handle the onGetProfile callable.
 *
 * @param request callable request
 *
 * @returns the authenticated user's profile data
 */
export async function handleOnGetProfile(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        // extract uid from auth context
        const {uid} = request.auth;

        // fetch user document from Firestore
        logger.info(`Fetching profile for user "${uid}"...`, {data: {uid}});
        const user = await getUser(uid);

        // user document not found: throw an error
        if (user === null)
        {
            throw new AuthError(`Profile not found for user "${uid}".`);
        }

        logger.info(`Profile for user "${uid}" fetched successfully.`);

        // return user profile data
        return {
            uid: user.uid,
            email: user.email,
            fullName: user.full_name,
            cpf: user.cpf,
            phone: user.phone,
            birthDate: user.birth_date,
            createdAt: user.created_at,
            updatedAt: user.updated_at,
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

        // for any other errors, log and throw a generic internal error
        const internal = new InternalError(
            'Failed to fetch user profile.',
            error
        );
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
