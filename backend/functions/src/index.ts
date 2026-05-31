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
export {onBuyFromStartup} from './responders/index';
export {onCancelOrder} from './responders/index';
export {onConfirmSetup2FA} from './responders/index';
export {onCreateOrder} from './responders/index';
export {onDeleteAllNotifications} from './responders/index';
export {onDeleteNotification} from './responders/index';
export {onDeposit} from './responders/index';
export {onDisable2FAByPassword} from './responders/index';
export {onGetDashboard} from './responders/index';
export {onGetMyOrders} from './responders/index';
export {onGetNotifications} from './responders/index';
export {onGetPatrimonyHistory} from './responders/index';
export {onGetPortfolio} from './responders/index';
export {onGetProfile} from './responders/index';
export {onGetQuestions} from './responders/index';
export {onGetStartup} from './responders/index';
export {onGetStartupOrderBook} from './responders/index';
export {onGetStartups} from './responders/index';
export {onGetTokenHistory} from './responders/index';
export {onGetTransactions} from './responders/index';
export {onGetWallet} from './responders/index';
export {onSendQuestion} from './responders/index';
export {onSetup2FA} from './responders/index';
export {onToggleFavorite} from './responders/index';
export {onUpdateProfile} from './responders/index';
export {onUserCreated} from './responders/index';
export {onVerify2FA} from './responders/index';
