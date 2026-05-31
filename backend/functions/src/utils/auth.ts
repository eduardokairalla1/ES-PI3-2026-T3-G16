/**
 * Auth verification utility.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {AuthError} from '../errors/authError';
import db from '../configs';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';


/**
 * CODE
 */

const TWO_FA_SESSION_TTL_MS = 12 * 60 * 60 * 1000;

interface VerifyAuthOptions
{
    skipTwoFa?: boolean;
}


function getTwoFASessionId(request: CallableRequest): string
{
    const authTime = request.auth?.token?.auth_time as number | undefined;
    return String(authTime ?? 0);
}


function twoFASessionsCol(uid: string): FirebaseFirestore.CollectionReference
{
    return db.collection('users').doc(uid).collection('two_fa_sessions');
}


/**
 * I mark the current Firebase Auth session as 2FA-verified.
 *
 * @param request callable request
 *
 * @returns void
 */
export async function markTwoFASessionVerified(request: CallableRequest): Promise<void>
{
    if (request.auth === null || request.auth === undefined)
    {
        throw new AuthError('User must be authenticated.');
    }

    const uid = request.auth.uid;
    const sessionId = getTwoFASessionId(request);
    const now = new Date();
    const expiresAt = new Date(now.getTime() + TWO_FA_SESSION_TTL_MS);

    await twoFASessionsCol(uid).doc(sessionId).set({
        'created_at': now,
        'expires_at': expiresAt,
        'session_id': sessionId,
        'uid': uid,
    });
}

/**
 * I verify that the callable request carries an authenticated user and return
 * its uid. Throws AuthError when no auth context is present.
 *
 * @param request callable request
 *
 * @returns the authenticated user's uid
 */
export async function verifyAuth(
    request: CallableRequest,
    options: VerifyAuthOptions = {},
): Promise<string>
{
    if (request.auth === null || request.auth === undefined)
    {
        throw new AuthError('User must be authenticated.');
    }

    const uid = request.auth.uid;

    if (options.skipTwoFa === true)
    {
        return uid;
    }

    const userSnap = await db.collection('users').doc(uid).get();
    const user = userSnap.exists ? userSnap.data() : null;

    if (user?.two_fa_enabled === true)
    {
        const sessionId = getTwoFASessionId(request);
        const sessionSnap = await twoFASessionsCol(uid).doc(sessionId).get();
        const session = sessionSnap.exists ? sessionSnap.data() : null;
        const expiresAt = session?.expires_at;
        const expiresAtDate = expiresAt?.toDate ? expiresAt.toDate() : new Date(expiresAt);

        if (!session || Number.isNaN(expiresAtDate.getTime()) || expiresAtDate.getTime() <= Date.now())
        {
            throw new AuthError('2FA verification required.');
        }
    }

    return uid;
}
