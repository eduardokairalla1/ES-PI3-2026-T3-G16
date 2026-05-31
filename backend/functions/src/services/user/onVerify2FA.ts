/**
 * Function callable onVerify2FA.
 *
 * Eduardo Kairalla - 24024241
 */

import * as speakeasy from 'speakeasy';
import {HttpsError} from 'firebase-functions/v2/https';
import db from '../../configs';
import {getUser} from '../../db/users/storage';
import {markTwoFASessionVerified} from '../../utils/auth';
import {logger} from '../../utils/logger';
import {parseRequest} from '../../utils/validation';
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {ValidationError} from '../../errors/validationError';
import type {CallableRequest} from 'firebase-functions/v2/https';
import {TwoFACodeRequest} from '../../types/responders/user';


const MAX_ATTEMPTS = 5;
const LOCK_MS      = 5 * 60 * 1000;


function toDate(value: any): Date | null
{
    if (!value) return null;
    return value.toDate ? value.toDate() : new Date(value);
}


/**
 * I handle the onVerify2FA callable.
 * Called during login when the user has 2FA enabled. Verifies the TOTP code.
 *
 * @param request callable request with { code: string }
 *
 * @returns { verified: true }
 */
export async function handleOnVerify2FA(request: CallableRequest)
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
        const attemptRef = db
            .collection('users')
            .doc(uid)
            .collection('two_fa_attempts')
            .doc('lockout');

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

        const attemptSnap = await attemptRef.get();
        const attempt = attemptSnap.exists ? attemptSnap.data() : null;
        const lockedUntil = toDate(attempt?.locked_until);
        if (lockedUntil !== null && lockedUntil.getTime() > Date.now())
        {
            throw new ValidationError('Muitas tentativas. Tente novamente em alguns minutos.');
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
            const currentAttempts = (attempt?.attempts as number | undefined) ?? 0;
            const nextAttempts = currentAttempts + 1;
            const locked = nextAttempts >= MAX_ATTEMPTS;

            await attemptRef.set({
                'attempts': nextAttempts,
                'locked_until': locked ? new Date(Date.now() + LOCK_MS) : null,
                'updated_at': new Date(),
            }, {merge: true});

            throw new ValidationError('Código inválido. Tente novamente.');
        }

        await attemptRef.delete();
        await markTwoFASessionVerified(request);

        logger.info(`2FA verified for user "${uid}".`);
        return {verified: true};
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

        const internal = new InternalError('Failed to verify 2FA code.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
