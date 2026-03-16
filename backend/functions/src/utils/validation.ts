/**
 * Validation utilities.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import * as z from 'zod';
import {logger} from './logger';
import {ValidationError} from '../errors/validationError';


/**
 * CODE
 */

/**
 * I parse and validate data against a Zod schema.
 * Throws a ValidationError if validation fails.
 *
 * @param schema Zod schema to validate against
 * @param data   Data to validate
 *
 * @returns parsed and validated data
 */
export function parseRequest<T extends z.ZodTypeAny>(
    schema: T,
    data: unknown,
): z.infer<T>
{
    // attempt to parse and validate data against schema
    try
    {
        return schema.parse(data);
    }

    // validation fails: log details and throw a ValidationError
    catch (error)
    {
        if (error instanceof z.ZodError)
        {
            logger.error(
                'Validation error',
                error,
                {
                    fieldErrors: z.flattenError(error).fieldErrors,
                    formErrors: z.flattenError(error).formErrors,
                },
            );
        }
        throw new ValidationError('Invalid request data.', error);
    }
}
