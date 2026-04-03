/**
 * Types for the onUserCreated callable function.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import * as z from 'zod';


/**
 * TYPES
 */
export const CreateUserRequest = z.object(
    {
        birthDate: z.string().regex(
            /^\d{4}-\d{2}-\d{2}$/,
            'Birth date must be in YYYY-MM-DD format'
        ),
        cpf: z.string(),
        fullName: z.string(),
        phone: z.string(),
    },
);


/**
 * EXPORTS
 */
export type CreateUserRequest = z.infer<typeof CreateUserRequest>;
