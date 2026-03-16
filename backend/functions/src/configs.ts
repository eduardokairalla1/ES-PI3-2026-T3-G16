/**
 * Firebase configurations.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {logger} from './utils/logger';


/**
 * CODE
 */

// initialize Firebase app
initializeApp();

// log initialization
logger.info('Firebase app initialized');

// export Firestore instance
export default getFirestore();
