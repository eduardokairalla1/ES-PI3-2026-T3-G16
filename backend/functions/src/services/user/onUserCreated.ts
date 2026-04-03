/**
 * Function callable onUserCreated.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {addUser} from '../../db/users/storage';
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
import {CreateUserRequest} from '../../types/responders/user';


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
export async function handleOnUserCreated(request: CallableRequest)
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
        const parsed = parseRequest(CreateUserRequest, request.data);

        // add user
        logger.info(`Adding user "${uid}"...`, {data: {uid, email}});
        const addedUser = await addUser(
            parsed.birthDate,
            parsed.cpf,
            email,
            parsed.fullName,
            parsed.phone,
            uid,
        );
        logger.info(`User "${uid}" added successfully.`, {data: addedUser});

        return {
            uid: addedUser.uid,
            email: addedUser.email,
            fullName: addedUser.full_name,
            birthDate: addedUser.birth_date,
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
