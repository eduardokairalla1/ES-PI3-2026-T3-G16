/**
 * Auth verification utility.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {AuthError} from '../errors/authError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * CODE
 */

/**
 * I verify that the callable request carries an authenticated user and return
 * its uid. Throws AuthError when no auth context is present.
 *
 * @param request callable request
 *
 * @returns the authenticated user's uid
 */
export function verifyAuth(request: CallableRequest): string
{
    if (request.auth === null || request.auth === undefined)
    {
        throw new AuthError('User must be authenticated.');
    }

    return request.auth.uid;
}
