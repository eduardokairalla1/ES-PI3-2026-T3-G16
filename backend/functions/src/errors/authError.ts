/**
 * Auth error.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * CODE
 */

/**
 * I represent an error thrown when a request fails authentication.
 */
export class AuthError extends Error
{
    constructor(message: string, cause?: unknown)
    {
        super(message, {cause});
        this.name = 'AuthError';
    }
}
