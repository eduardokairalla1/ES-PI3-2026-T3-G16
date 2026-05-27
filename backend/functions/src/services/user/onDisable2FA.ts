/**
 * Function callable onDisable2FA.
 *
 * Eduardo Kairalla - 24024241
 */

import * as speakeasy from 'speakeasy';
import {HttpsError} from 'firebase-functions/v2/https';
import {getUser, disableTwoFA} from '../../db/users/storage';
import {logger} from '../../utils/logger';
import {parseRequest} from '../../utils/validation';
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {ValidationError} from '../../errors/validationError';
import type {CallableRequest} from 'firebase-functions/v2/https';
import {TwoFACodeRequest} from '../../types/responders/user';


/**
 * I handle the onDisable2FA callable.
 * Verifies the current TOTP code and, if valid, disables 2FA and clears the secret.
 *
 * @param request callable request with { code: string }
 *
 * @returns { twoFaEnabled: false }
 */
export async function handleOnDisable2FA(request: CallableRequest)
{
    try
    {
        // validate authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        // parse and validate request data
        const {uid} = request.auth;
        const {code} = parseRequest(TwoFACodeRequest, request.data);

        // retrieve user
        const user = await getUser(uid);
        if (user === null)
        {
            throw new AuthError(`Profile not found for user "${uid}".`);
        }

        // verify that user has 2FA enabled
        if (user.totp_secret === null || !user.two_fa_enabled)
        {
            throw new ValidationError('2FA is not enabled for this account.');
        }

        // verify code against stored secret
        const valid = speakeasy.totp.verify({
            secret: user.totp_secret,
            encoding: 'base32',
            token: code,
            window: 1,
        });

        // code is invalid: throw error
        if (!valid)
        {
            throw new ValidationError('Código inválido. Verifique o app autenticador.');
        }

        // disable 2FA
        await disableTwoFA(uid);
        logger.info(`2FA disabled for user "${uid}".`);

        return {twoFaEnabled: false};
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

        const internal = new InternalError('Failed to disable 2FA.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
