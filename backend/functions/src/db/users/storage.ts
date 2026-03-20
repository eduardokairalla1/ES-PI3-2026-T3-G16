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
 * I add a user.
 *
 * @param input user input
 *
 * @returns user added
 */
export async function addUser(
    cpf: string,
    email: string,
    full_name: string,
    phone: string,
    uid: string): Promise<userDocument>
{

    // build user document
    const user: userDocument = {
        'created_at': new Date(),
        'cpf': cpf,
        'email': email,
        'full_name': full_name,
        'phone': phone,
        'status': 'active',
        'uid': uid,
        'updated_at': null,
    }

    // persist user to Firestore
    await db.collection('users').add(user);

    // return validated user
    return user;
}
