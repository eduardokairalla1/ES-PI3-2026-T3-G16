/**
 * Types for investment callable functions.
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

export const CreateOrderRequest = z.object(
    {
        startupId: z.string().min(1, 'Startup ID is required'),
        quantity:  z.number().int().min(1, 'Quantity must be at least 1'),
        type:      z.enum(['buy', 'sell']),
    },
);

export const GetTokenHistoryRequest = z.object(
    {
        startupId: z.string().min(1, 'Startup ID is required'),
        period:    z.enum(['daily', 'weekly', 'monthly', '6months', 'ytd']),
    },
);


/**
 * EXPORTS
 */
export type CreateOrderRequest    = z.infer<typeof CreateOrderRequest>;
export type GetTokenHistoryRequest = z.infer<typeof GetTokenHistoryRequest>;
