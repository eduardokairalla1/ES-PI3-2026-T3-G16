/**
 * Types for the dashboard callable functions.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import * as z from 'zod';


/**
 * TYPES
 */

export const ToggleFavoriteRequest = z.object(
    {
        startupId: z.string().min(1, 'Startup ID is required'),
    },
);


/**
 * EXPORTS
 */
export type ToggleFavoriteRequest = z.infer<typeof ToggleFavoriteRequest>;
