/**
 * Function callable onDisable2FAByPassword.
 *
 * Eduardo Kairalla - 24024241
 */

import {HttpsError} from 'firebase-functions/v2/https';
import {getUser, disableTwoFA} from '../../db/users/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {PermissionError} from '../../errors/permissionError';
import {ValidationError} from '../../errors/validationError';
import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * I handle the onDisable2FAByPassword callable.
 * Disables 2FA after confirming identity via recent password re-authentication.
 * The client must call FirebaseAuth.reauthenticateWithCredential() immediately
 * before invoking this function; this function checks that auth_time is within
 * the last 5 minutes as proof that the user just re-confirmed their password.
 *
 * @param request callable request (no data required)
 *
 * @returns { twoFaEnabled: false }
 *
 * @throws HttpsError('unauthenticated')  if the caller is not signed in
 * @throws HttpsError('permission-denied') if re-authentication window has expired
 * @throws HttpsError('invalid-argument') if 2FA is not currently enabled
 */
export async function handleOnDisable2FAByPassword(request: CallableRequest)
{
    try
    {
        // validate authentication and confirmed 2FA session
        const uid = await verifyAuth(request);

        // verify re-authentication happened within the last 5 minutes
        // (auth_time is seconds since Unix epoch)
        const authTimeSecs     = request.auth!.token['auth_time'] as number;
        const secondsSinceAuth = Math.floor(Date.now() / 1000) - authTimeSecs;
        if (secondsSinceAuth > 300)
        {
            throw new PermissionError(
                'Re-autenticação expirada. Confirme sua senha novamente.',
            );
        }

        // retrieve user and verify 2FA is enabled
        const user = await getUser(uid);
        if (user === null)
        {
            throw new AuthError(`Profile not found for user "${uid}".`);
        }

        if (!user.two_fa_enabled)
        {
            throw new ValidationError('2FA is not enabled for this account.');
        }

        // disable 2FA
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
