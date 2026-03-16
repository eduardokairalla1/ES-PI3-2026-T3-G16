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
export const requestSchema = z.object(
    {
        fullName: z.string(),
        cpf: z.string(),
        phone: z.string(),
    },
);

export type OnUserCreatedRequest = z.infer<typeof requestSchema>;
