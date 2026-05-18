/**
 * Entry point for the application.
 * This file imports necessary configurations and exports responders to
 * Firebase Cloud Functions.
 */

/**
 * --- IMPORTS ---
 */
import './configs';


/**
 * --- EXPORTS ---
 */
export {onUserCreated, onGetProfile, onGetWallet, onCreateOrder, onGetPortfolio, onUpdateProfile, onToggle2FA} from './responders/index';
export {onDeposit, onGetTransactions} from './responders/index';
export {onGetStartups, onGetStartup, onSendQuestion, onGetQuestions, onGetTokenHistory} from './responders/index';
export {onGetDashboard, onToggleFavorite} from './responders/index';
export {onCancelOrder, onUpdateOrder, onGetOrderBook, onMatchOrders} from './responders/index';

