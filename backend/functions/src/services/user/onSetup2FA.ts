/**
 * Function callable onSetup2FA.
 *
 * Eduardo Kairalla - 24024241
 */

import * as speakeasy from 'speakeasy';
import {HttpsError} from 'firebase-functions/v2/https';
import {getUser, setPendingTotpSecret} from '../../db/users/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * I handle the onSetup2FA callable.
 * Generates a TOTP secret, persists it, and returns the otpauth URI for QR display.
 *
 * @param request callable request (no data required)
 *
 * @returns { otpauthUri: string }
 */
export async function handleOnSetup2FA(request: CallableRequest)
{
    try
    {

        // retrieve user
        const uid   = await verifyAuth(request);
        const user  = await getUser(uid);
        if (user === null)
        {
            throw new AuthError(`Profile not found for user "${uid}".`);
        }

        // generate TOTP secret
        const secret = speakeasy.generateSecret({
            name: `MesclaInvest:${user.email}`,
            issuer: 'MesclaInvest',
            length: 20,
        });

        // persist secret
        await setPendingTotpSecret(uid, secret.base32);
        logger.info(`TOTP secret generated for user "${uid}".`);

        // return otpauth URI for QR code generation
        return {otpauthUri: secret.otpauth_url};
    }

    // handle errors
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Failed to set up 2FA.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
