// --- Investment responder schemas ---
//
// Davi da Cruz Shieh - 24798076
// Zod contracts for investment-related callable functions.

// --- IMPORTS ---
import * as z from 'zod';


// --- TYPES ---

export const CreateOrderRequest = z.object(
    {
        startupId: z.string().min(1, 'Startup ID is required'),
        quantity:  z.number().finite().int().min(1, 'Quantity must be at least 1').max(100000, 'Quantity is too high'),
        type:      z.enum(['buy', 'sell']),
        unitPrice: z.number().finite().positive('Price must be positive').max(100000, 'Price is too high'),
    },
);

export const BuyFromStartupRequest = z.object(
    {
        startupId: z.string().min(1, 'Startup ID is required'),
        quantity:  z.number().finite().int().min(1, 'Quantity must be at least 1').max(100000, 'Quantity is too high'),
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
