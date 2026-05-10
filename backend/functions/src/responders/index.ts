/**
 * Callable function responders.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {onCall} from 'firebase-functions/v2/https';
import {handleOnGetProfile} from '../services/user/onGetProfile';
import {handleOnToggle2FA} from '../services/user/onToggle2FA';
import {handleOnUpdateProfile} from '../services/user/onUpdateProfile';
import {handleOnUserCreated} from '../services/user/onUserCreated';
import {handleOnGetQuestions} from '../services/startup/onGetQuestions';
import {handleOnGetStartup} from '../services/startup/onGetStartup';
import {handleOnGetStartups} from '../services/startup/onGetStartups';
import {handleOnSendQuestion} from '../services/startup/onSendQuestion';


/**
 * CODE
 */

// user functions
export const onUserCreated    = onCall({cors: true}, handleOnUserCreated);
export const onGetProfile     = onCall({cors: true}, handleOnGetProfile);
export const onUpdateProfile  = onCall({cors: true}, handleOnUpdateProfile);
export const onToggle2FA      = onCall({cors: true}, handleOnToggle2FA);

// startup functions
export const onGetStartups   = onCall({cors: true}, handleOnGetStartups);
export const onGetStartup    = onCall({cors: true}, handleOnGetStartup);
export const onSendQuestion  = onCall({cors: true}, handleOnSendQuestion);
export const onGetQuestions  = onCall({cors: true}, handleOnGetQuestions);
