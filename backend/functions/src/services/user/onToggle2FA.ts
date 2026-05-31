/**
 * ATENÇÃO: DEAD CODE — Arquivo não registrado como Cloud Function.
 *
 * Este arquivo existe mas handleOnToggle2FA NÃO está importado em responders/index.ts
 * e NÃO é exportado em index.ts. Portanto nunca pode ser invocado pelo frontend.
 *
 * O fluxo correto de habilitação/desabilitação do 2FA é:
 *   - Habilitar: onSetup2FA → onConfirmSetup2FA
 *   - Desabilitar: onDisable2FAByPassword (requer reautenticação + senha)
 *
 * toggleUserTwoFA não deve ser exposta diretamente pois não requer validação TOTP.
 *
 * @deprecated Não utilizar. Manter apenas para referência histórica.
 *
 * Function callable onToggle2FA.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {toggleUserTwoFA} from '../../db/users/storage';
import {verifyAuth} from '../../utils/auth';
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
 * I handle the onToggle2FA callable.
 * Flips the two_fa_enabled flag for the authenticated user.
 *
 * @param request callable request (no data required)
 *
 * @returns { twoFaEnabled: boolean } — the new state
 */
export async function handleOnToggle2FA(request: CallableRequest)
{
    try
    {
        // verify authentication and extract uid
        const uid = await verifyAuth(request);

        logger.info(`Toggling 2FA for user "${uid}"...`);
        const twoFaEnabled = await toggleUserTwoFA(uid);
        logger.info(`2FA for user "${uid}" is now ${twoFaEnabled ? 'enabled' : 'disabled'}.`);

        return {twoFaEnabled};
    }

    // handle errors
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Failed to toggle 2FA.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
