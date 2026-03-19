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
const createUserRequest = z.object(
    {
        fullName: z.string(),
        cpf: z.string(),
        phone: z.string(),
    },
);


const updateUserRequest = z.object(
    {
        fullName: z.string(),
        cpf: z.string(),
        phone: z.string(),
    },
);


const patchUserRequest = z.object(
    {
        fullName: z.string(),
        cpf: z.string(),
        phone: z.string(),
    },
);


/**
 * EXPORTS
 */
export type createUserRequest = z.infer<typeof createUserRequest>;
