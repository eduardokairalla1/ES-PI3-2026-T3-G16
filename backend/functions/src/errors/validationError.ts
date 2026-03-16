/**
 * Validation error.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * CODE
 */

/**
 * I represent a validation error thrown when data is invalid.
 */
export class ValidationError extends Error
{
    constructor(message: string, error?: unknown)
    {
        super(message, {cause: error});
        this.name = 'ValidationError';
    }
}
