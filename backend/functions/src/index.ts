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
export {onUserCreated, onGetProfile, onUpdateProfile, onToggle2FA} from './responders/index';
export {onDeposit, onGetTransactions} from './responders/index';
export {onGetStartups, onGetStartup, onSendQuestion, onGetQuestions} from './responders/index';
export {onGetDashboard, onToggleFavorite} from './responders/index';
