/**
 * Function callable onUserCreated.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import db from '../../configs';
import {deleteUser} from '../../db/users/storage';
import {createWallet} from '../../db/wallets/storage';
import {createNotification} from '../../db/notifications/storage';
import {verifyAuth} from '../../utils/auth';
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
        // verify authentication and extract uid
        const uid   = await verifyAuth(request, {skipTwoFa: true});
        const token = request.auth!.token;

        // ensure email is present in auth token
        const email = token.email;

        // email is missing: throw an error
        if (email == null || email === undefined)
        {
            throw new ValidationError('User email is required.');
        }

        // validate request data
        const parsed = parseRequest(CreateUserRequest, request.data);

        // reject duplicate UID and CPF atomically in a transaction
        const cleanCpf = parsed.cpf.replace(/\D/g, '');

        logger.info(`Adding user "${uid}" in transaction...`, {data: {email, uid}});
        const addedUser = await db.runTransaction(async (tx) =>
        {
            const cpfRef = db.collection('cpfs').doc(cleanCpf);
            const cpfSnap = await tx.get(cpfRef);
            if (cpfSnap.exists)
            {
                throw new ValidationError('CPF já cadastrado.');
            }

            const userRef = db.collection('users').doc(uid);
            const userSnap = await tx.get(userRef);
            if (userSnap.exists)
            {
                throw new ValidationError('Usuário já cadastrado.');
            }

            const user = {
                'birth_date': parsed.birthDate,
                'cpf': parsed.cpf,
                'created_at': new Date(),
                'email': email,
                'favorite_ids': [],
                'full_name': parsed.fullName,
                'phone': parsed.phone,
                'photo_url': null,
                'status': 'active',
                'totp_secret': null,
                'two_fa_enabled': false,
                'uid': uid,
                'updated_at': null,
            };

            tx.set(userRef, user);
            tx.set(cpfRef, {'created_at': new Date(), 'uid': uid});
            return user;
        });
        logger.info(`User "${uid}" added successfully.`, {data: addedUser});

        // roll back user document if wallet creation fails
        try
        {
            await createWallet(uid);
        }
        catch (walletError)
        {
            logger.error(`Wallet creation failed for "${uid}", rolling back user document.`);
            await deleteUser(uid);
            throw walletError;
        }
        logger.info(`Wallet created for user "${uid}".`);

        // welcome notification (best-effort)
        await createNotification(
            uid,
            'welcome',
            'Bem-vindo ao MesclaInvest!',
            'Faça seu primeiro depósito e comece a investir nas startups do ecossistema.',
        );

        return {
            birthDate: addedUser.birth_date,
            createdAt: addedUser.created_at,
            email: addedUser.email,
            fullName: addedUser.full_name,
            status: addedUser.status,
            uid: addedUser.uid,
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
