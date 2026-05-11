/**
 * Callable function responders.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {onCall} from 'firebase-functions/v2/https';
import {handleOnCreateOrder} from '../services/user/onCreateOrder';
import {handleOnGetPortfolio} from '../services/user/onGetPortfolio';
import {handleOnGetProfile} from '../services/user/onGetProfile';
import {handleOnGetWallet} from '../services/user/onGetWallet';
import {handleOnUserCreated} from '../services/user/onUserCreated';
import {handleOnToggle2FA} from '../services/user/onToggle2FA';
import {handleOnUpdateProfile} from '../services/user/onUpdateProfile';
import {handleOnDeposit} from '../services/user/onDeposit';
import {handleOnGetTransactions} from '../services/user/onGetTransactions';
import {handleOnGetTokenHistory} from '../services/startup/onGetTokenHistory';
import {handleOnGetStartup} from '../services/startup/onGetStartup';
import {handleOnGetStartups} from '../services/startup/onGetStartups';
import {handleOnSendQuestion} from '../services/startup/onSendQuestion';
import {handleOnGetQuestions} from '../services/startup/onGetQuestions';
import {handleOnGetDashboard} from '../services/dashboard/onGetDashboard';
import {handleOnToggleFavorite} from '../services/dashboard/onToggleFavorite';


/**
 * CODE
 */

// user functions
export const onUserCreated    = onCall({cors: true}, handleOnUserCreated);
export const onGetProfile     = onCall({cors: true}, handleOnGetProfile);
export const onGetWallet      = onCall({cors: true}, handleOnGetWallet);
export const onCreateOrder    = onCall({cors: true}, handleOnCreateOrder);
export const onGetPortfolio   = onCall({cors: true}, handleOnGetPortfolio);
export const onUpdateProfile  = onCall({cors: true}, handleOnUpdateProfile);
export const onToggle2FA      = onCall({cors: true}, handleOnToggle2FA);
export const onDeposit        = onCall({cors: true}, handleOnDeposit);
export const onGetTransactions = onCall({cors: true}, handleOnGetTransactions);


// startup functions
export const onGetStartups   = onCall({cors: true}, handleOnGetStartups);
export const onGetStartup    = onCall({cors: true}, handleOnGetStartup);
export const onSendQuestion  = onCall({cors: true}, handleOnSendQuestion);
export const onGetQuestions  = onCall({cors: true}, handleOnGetQuestions);
export const onGetTokenHistory = onCall({cors: true}, handleOnGetTokenHistory);

// dashboard functions
export const onGetDashboard    = onCall({cors: true}, handleOnGetDashboard);
export const onToggleFavorite  = onCall({cors: true}, handleOnToggleFavorite);
