/**
 * Permission error.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * CODE
 */

/**
 * I represent an error thrown when a request is authenticated but lacks the required permissions.
 */
export class PermissionError extends Error
{
    constructor(message: string, cause?: unknown)
    {
        super(message, {cause});
        this.name = 'PermissionError';
    }
}
