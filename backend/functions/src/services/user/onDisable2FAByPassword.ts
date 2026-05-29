/**
 * Function callable onDisable2FAByPassword.
 * Disables 2FA after confirming identity via recent password re-authentication.
 *
 * The client must call FirebaseAuth.reauthenticateWithCredential() immediately
 * before invoking this function. The resulting ID token carries a fresh
 * auth_time claim; this function verifies that auth_time is within the last
 * 5 minutes as proof that the user just confirmed their password.
 *
 * Eduardo Kairalla - 24024241
 */

import {HttpsError} from 'firebase-functions/v2/https';
import {getUser, disableTwoFA} from '../../db/users/storage';
import {logger} from '../../utils/logger';
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {PermissionError} from '../../errors/permissionError';
import {ValidationError} from '../../errors/validationError';
import type {CallableRequest} from 'firebase-functions/v2/https';


export async function handleOnDisable2FAByPassword(request: CallableRequest)
{
    try
    {
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        const uid = request.auth.uid;

        // auth_time is seconds since Unix epoch; verify the re-authentication
        // happened within the last 5 minutes
        const authTimeSecs    = request.auth.token['auth_time'] as number;
        const secondsSinceAuth = Math.floor(Date.now() / 1000) - authTimeSecs;
        if (secondsSinceAuth > 300)
        {
            throw new PermissionError(
                'Re-autenticação expirada. Confirme sua senha novamente.',
            );
        }

        const user = await getUser(uid);
        if (user === null)
        {
            throw new AuthError(`Profile not found for user "${uid}".`);
        }

        if (!user.two_fa_enabled)
        {
            throw new ValidationError('2FA is not enabled for this account.');
        }

        await disableTwoFA(uid);
        logger.info(`2FA disabled via password re-auth for user "${uid}".`);

        return {twoFaEnabled: false};
    }
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }
        if (error instanceof PermissionError)
        {
            logger.error(error.message);
            throw new HttpsError('permission-denied', error.message);
        }
        if (error instanceof ValidationError)
        {
            logger.error(error.message);
            throw new HttpsError('invalid-argument', error.message);
        }

        const internal = new InternalError('Failed to disable 2FA by password.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
