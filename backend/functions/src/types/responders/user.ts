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
        fullName: z.string(),
        cpf: z.string(),
        phone: z.string(),
    },
);


/**
 * EXPORTS
 */
export type CreateUserRequest = z.infer<typeof CreateUserRequest>;
