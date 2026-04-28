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
            'Birth date must be in YYYY-MM-DD format',
        ),
        cpf: z.string(),
        fullName: z.string(),
        phone: z.string(),
    },
);


export const UpdateProfileRequest = z.object(
    {
        fullName: z.string().min(2).max(100).optional(),
        phone:    z.string().min(6).max(20).optional(),
        photoUrl: z.string().url().nullable().optional(),
    },
);


/**
 * EXPORTS
 */
export type CreateUserRequest    = z.infer<typeof CreateUserRequest>;
export type UpdateProfileRequest = z.infer<typeof UpdateProfileRequest>;
