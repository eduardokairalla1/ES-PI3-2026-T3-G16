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
import {handleOnBuyFromStartup} from '../services/user/onBuyFromStartup';
import {handleOnCancelOrder} from '../services/user/onCancelOrder';
import {handleOnGetMyOrders} from '../services/user/onGetMyOrders';
import {handleOnGetPortfolio} from '../services/user/onGetPortfolio';
import {handleOnGetProfile} from '../services/user/onGetProfile';
import {handleOnGetWallet} from '../services/user/onGetWallet';
import {handleOnToggle2FA} from '../services/user/onToggle2FA';
import {handleOnUpdateProfile} from '../services/user/onUpdateProfile';
import {handleOnUserCreated} from '../services/user/onUserCreated';
import {handleOnDeposit} from '../services/user/onDeposit';
import {handleOnGetTransactions} from '../services/user/onGetTransactions';

import {handleOnGetQuestions} from '../services/startup/onGetQuestions';
import {handleOnGetStartup} from '../services/startup/onGetStartup';
import {handleOnGetStartups} from '../services/startup/onGetStartups';
import {handleOnGetStartupOrderBook} from '../services/startup/onGetStartupOrderBook';
import {handleOnGetTokenHistory} from '../services/startup/onGetTokenHistory';
import {handleOnSendQuestion} from '../services/startup/onSendQuestion';
import {handleOnGetDashboard} from '../services/dashboard/onGetDashboard';
import {handleOnToggleFavorite} from '../services/dashboard/onToggleFavorite';
import {handleOnGetPatrimonyHistory} from '../services/dashboard/onGetPatrimonyHistory';


/**
 * CODE
 */

// user functions
export const onUserCreated     = onCall({cors: true}, handleOnUserCreated);
export const onGetProfile      = onCall({cors: true}, handleOnGetProfile);
export const onGetWallet       = onCall({cors: true}, handleOnGetWallet);
export const onCreateOrder     = onCall({cors: true}, handleOnCreateOrder);
export const onBuyFromStartup  = onCall({cors: true}, handleOnBuyFromStartup);
export const onCancelOrder     = onCall({cors: true}, handleOnCancelOrder);
export const onGetMyOrders     = onCall({cors: true}, handleOnGetMyOrders);
export const onGetPortfolio    = onCall({cors: true}, handleOnGetPortfolio);
export const onUpdateProfile   = onCall({cors: true}, handleOnUpdateProfile);
export const onToggle2FA       = onCall({cors: true}, handleOnToggle2FA);
export const onDeposit         = onCall({cors: true}, handleOnDeposit);
export const onGetTransactions = onCall({cors: true}, handleOnGetTransactions);


// startup functions
export const onGetStartups         = onCall({cors: true}, handleOnGetStartups);
export const onGetStartup          = onCall({cors: true}, handleOnGetStartup);
export const onGetStartupOrderBook = onCall({cors: true}, handleOnGetStartupOrderBook);
export const onSendQuestion        = onCall({cors: true}, handleOnSendQuestion);
export const onGetQuestions        = onCall({cors: true}, handleOnGetQuestions);
export const onGetTokenHistory     = onCall({cors: true}, handleOnGetTokenHistory);

// dashboard functions
export const onGetDashboard        = onCall({cors: true}, handleOnGetDashboard);
export const onToggleFavorite      = onCall({cors: true}, handleOnToggleFavorite);
export const onGetPatrimonyHistory = onCall({cors: true}, handleOnGetPatrimonyHistory);
