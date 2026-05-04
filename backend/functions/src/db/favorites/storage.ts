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
 * I get all favorite startup IDs for a user.
 *
 * @param uid Firebase Auth UID of the user
 *
 * @returns list of favorite documents
 */
export async function getUserFavorites(uid: string): Promise<FavoriteDocument[]>
{
    const snapshot = await db
        .collection('users')
        .doc(uid)
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
    const favCol = db
        .collection('users')
        .doc(uid)
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
