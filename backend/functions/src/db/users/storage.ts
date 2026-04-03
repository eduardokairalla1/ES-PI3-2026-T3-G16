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
    // query user by uid
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
