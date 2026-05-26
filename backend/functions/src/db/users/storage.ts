// --- User database operations ---
//
// Davi da Cruz Shieh - 24798076
// Firestore helpers for reading and updating user documents.

// --- IMPORTS ---
import db from '../../configs';


// --- TYPES ---
import type {userDocument} from './model';

// --- CODE ---

/**
 * I get a user by uid.
 *
 * @param uid the user's Firebase Auth uid
 *
 * @returns the user document, or null if not found
 */
export async function getUser(uid: string): Promise<userDocument | null>
{
    const snap = await db.collection('users').doc(uid).get();
    if (snap.exists) return snap.data() as userDocument;

    // query user by uid (backwards compatibility)
    const user = await db.collection('users')
        .where('uid', '==', uid)
        .limit(1)
        .get();

    // user not found: return null
    if (user.empty) return null;

    // return user document
    return user.docs[0].data() as userDocument;
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
        'two_fa_enabled': false,
        'uid': uid,
        'updated_at': null,
    };

    // persist user to Firestore using UID as document ID
    await db.collection('users').doc(uid).set(user);

    // return validated user
    return user;
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
    const userDocId = await getUserDocId(uid);
    if (!userDocId) throw new Error(`User "${uid}" not found.`);

    await db.collection('users').doc(userDocId).update({...updates, 'updated_at': new Date()});
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
    const userDocId = await getUserDocId(uid);
    if (!userDocId) throw new Error(`User "${uid}" not found.`);

    const userRef = db.collection('users').doc(userDocId);
    const snap = await userRef.get();
    const next = !((snap.data() as userDocument).two_fa_enabled ?? false);

    await userRef.update({'two_fa_enabled': next, 'updated_at': new Date()});

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
    const docSnap = await db.collection('users').doc(uid).get();
    if (docSnap.exists) return uid;

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
    const userDocId = await getUserDocId(uid);
    if (!userDocId) throw new Error(`User "${uid}" not found.`);

    const docRef = db.collection('users').doc(userDocId);
    const docSnap = await docRef.get();
    const current = (docSnap.data() as userDocument).favorite_ids ?? [];
    const isFavorited = current.includes(startupId);

    if (isFavorited)
    {
        await docRef.update({
            'favorite_ids': FieldValue.arrayRemove(startupId),
            'updated_at': new Date(),
        });
        return false;
    }

    await docRef.update({
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
    const userDocId = await getUserDocId(uid);
    if (!userDocId) return [];

    const snap = await db.collection('users').doc(userDocId).get();
    return (snap.data() as userDocument).favorite_ids ?? [];
}
