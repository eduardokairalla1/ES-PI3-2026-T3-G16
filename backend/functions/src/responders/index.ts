/**
 * Function callable onUserCreated.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {onCall} from 'firebase-functions/v2/https';
import {handleOnUserCreated} from '../services/user/onUserCreated';



/**
 * CODE
 */

// export the callable function
export const onUserCreated = onCall(handleOnUserCreated);
