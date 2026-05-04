/**
 * Favorite database operations.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import db from '../../configs';


/**
 * TYPES
 */
import type {FavoriteDocument} from './model';


/**
 * CODE
 */

/**
 * I get the Firestore document ID for a user by their Auth UID.
 *
 * @param uid Firebase Auth UID
 *
 * @returns Firestore document ID, or null if not found
 */
async function getUserDocId(uid: string): Promise<string | null>
{
    const snapshot = await db.collection('users')
        .where('uid', '==', uid)
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    return snapshot.docs[0].id;
}


/**
 * I get all favorite startup IDs for a user.
 *
 * @param uid Firebase Auth UID of the user
 *
 * @returns list of favorite documents
 */
export async function getUserFavorites(uid: string): Promise<FavoriteDocument[]>
{
    const userDocId = await getUserDocId(uid);
    if (userDocId === null) return [];

    const snapshot = await db
        .collection('users')
        .doc(userDocId)
        .collection('favorites')
        .get();

    return snapshot.docs.map(doc => doc.data() as FavoriteDocument);
}


/**
 * I toggle a favorite for a user. If the startup is already favorited,
 * it is removed. Otherwise, it is added.
 *
 * @param uid       Firebase Auth UID of the user
 * @param startupId Firestore document ID of the startup
 *
 * @returns true if the startup is now favorited, false if unfavorited
 */
export async function toggleFavorite(uid: string, startupId: string): Promise<boolean>
{
    const userDocId = await getUserDocId(uid);
    if (userDocId === null)
    {
        throw new Error(`User "${uid}" not found.`);
    }

    const favCol = db
        .collection('users')
        .doc(userDocId)
        .collection('favorites');

    // check if already favorited
    const existing = await favCol
        .where('startup_id', '==', startupId)
        .limit(1)
        .get();

    if (!existing.empty)
    {
        // remove favorite
        await existing.docs[0].ref.delete();
        return false;
    }

    // add favorite
    const favorite: FavoriteDocument = {
        'created_at': new Date(),
        'startup_id': startupId,
    };
    await favCol.add(favorite);
    return true;
}
