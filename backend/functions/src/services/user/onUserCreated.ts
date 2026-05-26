// --- Function callable onUserCreated ---
//
// Davi da Cruz Shieh - 24798076
// Creates the user profile and wallet after Firebase Auth registration.

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import {parseRequest} from '../../utils/validation';
import db from '../../configs';
import type {userDocument} from '../../db/users/model';


// --- ERRORS ---
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {ValidationError} from '../../errors/validationError';


// --- TYPES ---
import type {CallableRequest} from 'firebase-functions/v2/https';
import {CreateUserRequest} from '../../types/responders/user';


// --- CODE ---

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
        const uid   = verifyAuth(request);
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

        // reject duplicates and create user + wallet atomically
        logger.info(`Checking duplicates and creating user/wallet for "${uid}" atomically...`);
        const addedUser = await db.runTransaction(async (tx) =>
        {
            const userRef = db.collection('users').doc(uid);
            const userSnap = await tx.get(userRef);
            if (userSnap.exists)
            {
                throw new ValidationError('Usuário já cadastrado.');
            }

            const cpfQuery = db.collection('users').where('cpf', '==', parsed.cpf).limit(1);
            const cpfSnap = await tx.get(cpfQuery);
            if (!cpfSnap.empty)
            {
                throw new ValidationError('CPF já cadastrado.');
            }

            // build user document
            const user: userDocument = {
                'birth_date': parsed.birthDate,
                'cpf': parsed.cpf,
                'created_at': new Date(),
                'email': email,
                'favorite_ids': [],
                'full_name': parsed.fullName,
                'phone': parsed.phone,
                'photo_url': null,
                'status': 'active',
                'two_fa_enabled': false,
                'uid': uid,
                'updated_at': null,
            };

            // build wallet document
            const walletRef = db.collection('wallets').doc(uid);
            const wallet = {
                uid,
                balance:    0,
                created_at: new Date(),
                updated_at: null,
            };

            tx.set(userRef, user);
            tx.set(walletRef, wallet);

            return user;
        });

        logger.info(`User "${uid}" and wallet added successfully.`);

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
