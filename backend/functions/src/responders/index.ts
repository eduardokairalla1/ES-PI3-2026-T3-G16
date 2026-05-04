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
import {handleOnGetDashboard} from '../services/dashboard/onGetDashboard';
import {handleOnToggleFavorite} from '../services/dashboard/onToggleFavorite';


/**
 * CODE
 */

// user functions
export const onUserCreated    = onCall(handleOnUserCreated);
export const onGetProfile     = onCall(handleOnGetProfile);
export const onUpdateProfile  = onCall(handleOnUpdateProfile);
export const onToggle2FA      = onCall(handleOnToggle2FA);

// startup functions
export const onGetStartups   = onCall(handleOnGetStartups);
export const onGetStartup    = onCall(handleOnGetStartup);
export const onSendQuestion  = onCall(handleOnSendQuestion);
export const onGetQuestions  = onCall(handleOnGetQuestions);

// dashboard functions
export const onGetDashboard    = onCall(handleOnGetDashboard);
export const onToggleFavorite  = onCall(handleOnToggleFavorite);
