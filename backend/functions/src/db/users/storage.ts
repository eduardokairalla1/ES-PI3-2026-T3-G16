/**
 * User database operations.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import db from '../../configs';


/**
* TYPES
*/
import type {userDocument} from './model';

/**
* CODE
*/

/**
 * I get a user by uid.
 *
 * @param uid the user's Firebase Auth uid
 *
 * @returns the user document, or null if not found
 */
export async function getUser(uid: string): Promise<userDocument | null>
{
    // get user document by uid field
    const doc = await db.collection('users').doc(uid).get();

    // no document found: return null
    if (!doc.exists) return null;

    // return user document data
    return doc.data() as userDocument;
}


/**
 * I get a user by CPF.
 *
 * @param cpf the user's CPF
 *
 * @returns the user document, or null if not found
 */
export async function getUserByCpf(cpf: string): Promise<userDocument | null>
{
    const snapshot = await db.collection('users')
        .where('cpf', '==', cpf)
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    return snapshot.docs[0].data() as userDocument;
}


/**
 * I add a user.
 *
 * @param input user input
 *
 * @returns user added
 */
export async function addUser(
    birth_date: string,
    cpf: string,
    email: string,
    full_name: string,
    phone: string,
    uid: string): Promise<userDocument>
{

    // build user document
    const user: userDocument = {
        'birth_date': birth_date,
        'cpf': cpf,
        'created_at': new Date(),
        'email': email,
        'favorite_ids': [],
        'full_name': full_name,
        'phone': phone,
        'photo_url': null,
        'status': 'active',
        'totp_secret': null,
        'two_fa_enabled': false,
        'uid': uid,
        'updated_at': null,
    };

    // persist user
    await db.collection('users').doc(uid).set(user);

    // return validated user
    return user;
}


/**
 * I delete a user document.
 *
 * @param uid Firebase Auth UID of the user
 */
export async function deleteUser(uid: string): Promise<void>
{
    await db.collection('users').doc(uid).delete();
}


/**
 * I update mutable fields on a user document.
 *
 * @param uid     Firebase Auth UID of the user
 * @param updates fields to update
 */
export async function updateUser(
    uid: string,
    updates: Partial<Pick<userDocument, 'full_name' | 'phone' | 'photo_url'>>,
): Promise<void>
{
    await db.collection('users').doc(uid).update({...updates, 'updated_at': new Date()});
}


/**
 * I save a TOTP secret for a user.
 *
 * @param uid Firebase Auth UID
 * @param secret base32-encoded TOTP secret
 */
export async function setTotpSecret(uid: string, secret: string): Promise<void>
{
    await db.collection('users').doc(uid).update({'totp_secret': secret});
}


/**
 * I enable 2FA for a user after the setup code is confirmed.
 *
 * @param uid Firebase Auth UID
 */
export async function enableTwoFA(uid: string): Promise<void>
{
    await db.collection('users').doc(uid).update({'two_fa_enabled': true});
}


/**
 * I disable 2FA and clear the TOTP secret for a user.
 *
 * @param uid Firebase Auth UID
 */
export async function disableTwoFA(uid: string): Promise<void>
{
    await db.collection('users').doc(uid).update({
        'two_fa_enabled': false,
        'totp_secret': null,
    });
}


/**
 * I toggle the two_fa_enabled flag for a user and return the new state.
 *
 * @param uid Firebase Auth UID of the user
 *
 * @returns the new two_fa_enabled value
 */
export async function toggleUserTwoFA(uid: string): Promise<boolean>
{

    // retrieve user and verify existence
    const user = await getUser(uid);
    if (!user) throw new Error(`User "${uid}" not found.`);

    // toggle two_fa_enabled and return new state
    const next = !(user.two_fa_enabled ?? false);
    await db.collection('users').doc(uid).update({'two_fa_enabled': next, 'updated_at': new Date()});
    return next;
}


/**
 * I get the Firestore document ID for a user by their Auth UID.
 *
 * @param uid Firebase Auth UID
 *
 * @returns Firestore document ID, or null if not found
 */
export async function getUserDocId(uid: string): Promise<string | null>
{
    const snapshot = await db.collection('users')
        .where('uid', '==', uid)
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    return snapshot.docs[0].id;
}


/**
 * I get the total number of users in the system.
 *
 * @returns total user count
 */
export async function getUserCount(): Promise<number>
{
    const snapshot = await db.collection('users').count().get();
    return snapshot.data().count;
}


import {FieldValue} from 'firebase-admin/firestore';


/**
 * I toggle a startup ID in the user's favorite_ids array.
 * Returns true if now favorited, false if removed.
 *
 * @param uid       Firebase Auth UID
 * @param startupId startup document ID
 */
export async function toggleFavoriteId(uid: string, startupId: string): Promise<boolean>
{
    const snapshot = await db.collection('users')
        .where('uid', '==', uid)
        .limit(1)
        .get();

    if (snapshot.empty) throw new Error(`User "${uid}" not found.`);

    const doc = snapshot.docs[0];
    const current = (doc.data() as userDocument).favorite_ids ?? [];
    const isFavorited = current.includes(startupId);

    if (isFavorited)
    {
        await doc.ref.update({
            'favorite_ids': FieldValue.arrayRemove(startupId),
            'updated_at': new Date(),
        });
        return false;
    }

    await doc.ref.update({
        'favorite_ids': FieldValue.arrayUnion(startupId),
        'updated_at': new Date(),
    });
    return true;
}


/**
 * I return the favorite startup IDs for a user.
 *
 * @param uid Firebase Auth UID
 *
 * @returns array of startup IDs
 */
export async function getFavoriteIds(uid: string): Promise<string[]>
{
    const snapshot = await db.collection('users')
        .where('uid', '==', uid)
        .limit(1)
        .get();

    if (snapshot.empty) return [];

    return (snapshot.docs[0].data() as userDocument).favorite_ids ?? [];
}
