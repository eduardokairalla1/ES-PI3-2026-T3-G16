/**
 * Function callable onUserCreated.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {onCall, HttpsError} from 'firebase-functions/v2/https';
import {addUser} from '../../db/users';
import {logger} from '../../utils/logger';
import {parseRequest} from '../../utils/validation';


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
import {requestSchema} from './types';


/**
 * CODE
 */

/**
 * I handle the onUserCreated callable.
 *
 * @param request callable request
 *
 * @returns created user data
 */
async function handleOnUserCreated(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        // extract user info from auth context
        const {uid, token} = request.auth;

        // ensure email is present in auth token
        const email = token.email;

        // email is missing: throw an error
        if (email == null || email === undefined)
        {
            throw new ValidationError('User email is required.');
        }

        // validate request data
        const parsed = parseRequest(requestSchema, request.data);

        // add user
        logger.info(`Adding user "${uid}"...`, {data: {uid, email}});

        const addedUser = await addUser(
            {
                created_at: new Date().toISOString(),
                cpf: parsed.cpf,
                email,
                full_name: parsed.fullName,
                phone: parsed.phone,
                status: 'active',
                uid,
                updated_at: null,
            },
        );

        logger.info(`User "${uid}" added successfully.`, {data: addedUser});

        return {
            uid: addedUser.uid,
            email: addedUser.email,
            fullName: addedUser.full_name,
            status: addedUser.status,
            createdAt: addedUser.created_at,
            updatedAt: addedUser.updated_at,
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

        // for any other errors, log and throw a generic internal error
        const internal = new InternalError('Failed to create user.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}


// export the callable function
export const onUserCreated = onCall(handleOnUserCreated);
