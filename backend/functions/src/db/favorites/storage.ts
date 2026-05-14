/**
 * Favorite database operations.
 * Delegates to the user document's favorite_ids field.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

import {toggleFavoriteId, getFavoriteIds} from '../users/storage';


/**
 * I toggle a favorite for a user.
 *
 * @param uid       Firebase Auth UID
 * @param startupId Firestore document ID of the startup
 *
 * @returns true if now favorited, false if removed
 */
export async function toggleFavorite(uid: string, startupId: string): Promise<boolean>
{
    return toggleFavoriteId(uid, startupId);
}


/**
 * I get all favorite startup IDs for a user as plain strings.
 *
 * @param uid Firebase Auth UID
 *
 * @returns array of startup IDs
 */
export async function getUserFavoriteIds(uid: string): Promise<string[]>
{
    return getFavoriteIds(uid);
}
