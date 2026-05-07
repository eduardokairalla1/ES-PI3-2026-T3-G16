/**
 * Types for the startup callable functions.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import * as z from 'zod';


/**
 * TYPES
 */

export const GetStartupsRequest = z.object(
    {
        stage: z.enum(['new', 'operating', 'expanding']).optional(),
    },
);

export const GetStartupRequest = z.object(
    {
        id: z.string().min(1, 'Startup ID is required'),
    },
);

export const SendQuestionRequest = z.object(
    {
        isPrivate: z.boolean(),
        startupId: z.string().min(1, 'Startup ID is required'),
        text: z.string().min(1, 'Question text is required').max(1000, 'Question text must be at most 1000 characters'),
    },
);

export const GetQuestionsRequest = z.object(
    {
        startupId: z.string().min(1, 'Startup ID is required'),
    },
);


/**
 * EXPORTS
 */
export type GetStartupsRequest = z.infer<typeof GetStartupsRequest>;
export type GetStartupRequest = z.infer<typeof GetStartupRequest>;
export type SendQuestionRequest = z.infer<typeof SendQuestionRequest>;
export type GetQuestionsRequest = z.infer<typeof GetQuestionsRequest>;
