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
        cpf: z.preprocess(
            val => typeof val === 'string' ? val.replace(/\D/g, '') : val,
            z.string().regex(/^\d{11}$/, 'CPF must contain exactly 11 digits'),
        ),
        fullName: z.string().trim().min(2).max(100),
        phone: z.preprocess(
            val => typeof val === 'string' ? val.replace(/\D/g, '') : val,
            z.string().min(10).max(11),
        ),
    },
);


export const UpdateProfileRequest = z.object(
    {
        fullName: z.string().min(2).max(100).optional(),
        phone:    z.string().min(6).max(20).optional(),
        photoUrl: z.string().url().nullable().optional(),
    },
);


export const TwoFACodeRequest = z.object({
    code: z.string().regex(/^\d{6}$/, 'Code must be exactly 6 digits'),
});


/**
 * EXPORTS
 */
export type CreateUserRequest    = z.infer<typeof CreateUserRequest>;
export type UpdateProfileRequest = z.infer<typeof UpdateProfileRequest>;
export type TwoFACodeRequest     = z.infer<typeof TwoFACodeRequest>;
