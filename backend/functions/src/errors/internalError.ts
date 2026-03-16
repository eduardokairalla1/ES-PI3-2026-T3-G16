/**
 * Internal error.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * CODE
 */

/**
 * I represent an error thrown when an unexpected internal failure occurs.
 */
export class InternalError extends Error
{
    constructor(message: string, cause?: unknown)
    {
        super(message, {cause});
        this.name = 'InternalError';
    }
}
