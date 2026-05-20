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
        unitPrice: z.number().positive('Price must be positive'),
    },
);

export const BuyFromStartupRequest = z.object(
    {
        startupId: z.string().min(1, 'Startup ID is required'),
        quantity:  z.number().int().min(1, 'Quantity must be at least 1'),
    },
);

export const CancelOrderRequest = z.object(
    {
        orderId: z.string().min(1, 'Order ID is required'),
    },
);

export const GetStartupOrderBookRequest = z.object(
    {
        startupId: z.string().min(1, 'Startup ID is required'),
        depth:     z.number().int().min(1).max(50).optional(),
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
export type CreateOrderRequest          = z.infer<typeof CreateOrderRequest>;
export type BuyFromStartupRequest       = z.infer<typeof BuyFromStartupRequest>;
export type CancelOrderRequest          = z.infer<typeof CancelOrderRequest>;
export type GetStartupOrderBookRequest  = z.infer<typeof GetStartupOrderBookRequest>;
export type GetTokenHistoryRequest      = z.infer<typeof GetTokenHistoryRequest>;
