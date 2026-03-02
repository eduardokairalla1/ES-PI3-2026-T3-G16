/**
 * Custom logger wrapper
 * 
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import * as firebaseLogger from 'firebase-functions/logger';
import {LogData} from './logger.types';


/**
 * CONSTANTS & DEFINITIONS
 */

// get emulator status
const IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === 'true';

// set ANSII color codes for console output
const RESET = '\x1b[0m';  // Reset all attributes
const DIM = '\x1b[2m';    // Dim text
const WHITE = '\x1b[97m'; // Bright white text

// set ANSII color codes for log levels
const LEVEL_COLOR: Record<string, string> = {
  DEBUG: '\x1b[36m',    // Cyan
  INFO: '\x1b[32m',     // Green
  WARNING: '\x1b[33m',  // Yellow
  ERROR: '\x1b[31m',    // Red
};

// set log level names
const LEVEL_NAME: Record<string, string> = {
  DEBUG: 'DEBUG   ',
  INFO: 'INFO    ',
  WARNING: 'WARNING ',
  ERROR: 'ERROR   ',
};


/**
 * CODE
 */

/**
 * Get current timestamp in YYYY-MM-DD HH:MM:SS format
 * 
 * :returns: Formatted timestamp string
 */
function timestamp(): string {

  // instantiate date object
  const date = new Date();

  // helper function to pad single digit numbers with leading zero
  const pad = (n: number) => String(n).padStart(2, '0');

  // return formatted timestamp
  return (
    `${date.getFullYear()}-${pad(date.getMonth() + 1)}-` +
    `${pad(date.getDate())} ${pad(date.getHours())}:` +
    `${pad(date.getMinutes())}:${pad(date.getSeconds())}`
  );
}


/**
 * Build log message
 * 
 * :param level: Log level (DEBUG, INFO, WARNING, ERROR)
 * :param message: Log message
 * 
 * :returns: Formatted log message string
 */
function buildMessage(level: string, message: string): string {

  // get level name and timestamp
  const name = LEVEL_NAME[level];
  const ts = timestamp();

  // running in emulator: add color codes to message
  if (IS_EMULATOR === true) {
    
    // get color code for level
    const color = LEVEL_COLOR[level];
    
    // return formatted message with color codes
    return (
      `${color}[${name}]${RESET} ${DIM}${ts}${RESET} ${WHITE}${message}${RESET}`
    );
  }

  return `[${name}] ${ts} ${message}`;
}


/**
 * EXPORTS
 */
export const logger = {

  /**
   * Log debug message
   * 
   * :param message: Log message
   * :param data: Optional structured data to include in log
   * 
   * :returns: void
   */
  debug: (message: string, data?: LogData) => {

    // build log message
    const msg = buildMessage('DEBUG', message);

    // running in emulator: log to console with color codes
    if (IS_EMULATOR === true) {
      console.debug(msg, data ?? '');
      return;
    } 

    // production: log using Firebase logger
    return firebaseLogger.debug(msg, {structuredData: true, ...data});
  },


  /**
   * Log info message
   * 
   * :param message: Log message
   * :param data: Optional structured data to include in log
   * 
   * :returns: void
   */
  info: (message: string, data?: LogData) => {

    // build log message
    const msg = buildMessage('INFO', message);

    // running in emulator: log to console with color codes
    if (IS_EMULATOR === true) {
      console.info(msg, data ?? '');
      return;
    } 

    // production: log using Firebase logger
    return firebaseLogger.info(msg, {structuredData: true, ...data});
  },


  /**
   * Log warning message
   * 
   * :param message: Log message
   * :param data: Optional structured data to include in log
   * 
   * :returns: void
   */
  warning: (message: string, data?: LogData) => {

    // build log message
    const msg = buildMessage('WARNING', message);

    // running in emulator: log to console with color codes
    if (IS_EMULATOR === true) {
      console.warn(msg, data ?? '');
      return;
    } 

    // production: log using Firebase logger
    return firebaseLogger.warn(msg, {structuredData: true, ...data});
  },


  /**
   * Log error message
   * 
   * :param message: Log message
   * :param error: Optional error object or message to include in log
   * :param data: Optional structured data to include in log
   * 
   * :returns: void
   */
  error: (message: string, error?: unknown, data?: LogData) => {

    // build log message
    const msg = buildMessage('ERROR', message);

    // extract error message and stack trace if error is an Error object
    const errorData = error instanceof Error
      ? {errorMessage: error.message, stack: error.stack}
      : error !== undefined ? {errorMessage: String(error)} : {};

    // running in emulator: log to console with color codes
    if (IS_EMULATOR === true) {
      console.error(msg, {...errorData, ...data});
      return;
    }

    // production: log using Firebase logger
    return firebaseLogger.error(
      msg,
      {structuredData: true, ...errorData, ...data}
    );
  },
};
