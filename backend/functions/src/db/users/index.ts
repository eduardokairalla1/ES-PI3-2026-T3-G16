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
import {userSchema} from './types';
import type {User} from './types';

/**
* CODE
*/

/**
 * I add a user.
 *
 * @param input user input
 *
 * @returns user added
 */
export async function addUser(input: User): Promise<User>
{

    // validate input against schema
    const validated = userSchema.parse(input);

    // persist user to Firestore
    await db.collection('users').add(validated);

    // return validated user
    return validated;
}
