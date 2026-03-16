/**
 * User types and schema.
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
export const userSchema = z.object(
    {
        created_at: z.iso.datetime(),
        cpf: z.string().length(11),
        email: z.email(),
        full_name: z.string(),
        phone: z.string(),
        status: z.enum(['active', 'inactive']),
        uid: z.string(),
        updated_at: z.nullable(z.iso.datetime()),
    },
);

export type User = z.infer<typeof userSchema>;
