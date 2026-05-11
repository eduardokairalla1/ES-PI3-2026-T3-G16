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
export {
    onUserCreated,
    onGetProfile,
    onUpdateProfile,
    onToggle2FA,
    onDeposit,
    onGetTransactions,
    onGetWallet,
    onCreateOrder,
    onGetPortfolio,
    onGetStartups,
    onGetStartup,
    onSendQuestion,
    onGetQuestions,
    onGetTokenHistory,
    onGetDashboard,
    onToggleFavorite,
} from './responders/index';
