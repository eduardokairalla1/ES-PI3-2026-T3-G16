/**
 * Function callable onConfirmSetup2FA.
 *
 * Eduardo Kairalla - 24024241
 */

import * as speakeasy from 'speakeasy';
import {HttpsError} from 'firebase-functions/v2/https';
import {getUser, enableTwoFA} from '../../db/users/storage';
import {logger} from '../../utils/logger';
import {parseRequest} from '../../utils/validation';
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {ValidationError} from '../../errors/validationError';
import type {CallableRequest} from 'firebase-functions/v2/https';
import {TwoFACodeRequest} from '../../types/responders/user';


/**
 * I handle the onConfirmSetup2FA callable.
 * Verifies the first TOTP code from the user's authenticator app and, if valid,
 * enables 2FA on their account.
 *
 * @param request callable request with { code: string }
 *
 * @returns { twoFaEnabled: true }
 */
export async function handleOnConfirmSetup2FA(request: CallableRequest)
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

        // retrieve user and verify setup in progress
        const user = await getUser(uid);
        if (user === null)
        {
            throw new AuthError(`Profile not found for user "${uid}".`);
        }

        // verify that user has a pending 2FA setup
        if (user.totp_secret === null)
        {
            throw new ValidationError('No 2FA setup in progress. Call onSetup2FA first.');
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

        // code is valid: enable 2FA for user
        await enableTwoFA(uid);
        logger.info(`2FA enabled for user "${uid}".`);

        // return success response
        return {twoFaEnabled: true};
    }
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

        const internal = new InternalError('Failed to confirm 2FA setup.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
