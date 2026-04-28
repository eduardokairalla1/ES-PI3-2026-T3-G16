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
import {handleOnGetProfile} from '../services/user/onGetProfile';



/**
 * CODE
 */

// export the callable functions
export const onUserCreated = onCall(handleOnUserCreated);
export const onGetProfile  = onCall(handleOnGetProfile);
