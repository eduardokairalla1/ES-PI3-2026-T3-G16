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
export {onUserCreated} from './responders/index';
