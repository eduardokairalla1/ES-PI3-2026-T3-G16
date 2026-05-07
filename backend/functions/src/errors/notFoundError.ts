/**
 * Not found error.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * CODE
 */

/**
 * I represent an error thrown when a requested resource does not exist.
 */
export class NotFoundError extends Error
{
    constructor(message: string, cause?: unknown)
    {
        super(message, {cause});
        this.name = 'NotFoundError';
    }
}
