/**
 * Order types and schema.
 *
 * Davi da Cruz Shieh - 24798076
 */


/**
 * TYPES
 */

export type OrderType   = 'buy' | 'sell';
export type OrderStatus = 'pending' | 'completed' | 'failed' | 'cancelled';

export interface OrderDocument
{
    id:             string;
    uid:            string;
    startup_id:     string;
    type:           OrderType;
    status:         OrderStatus;
    quantity:       number;
    unit_price:     number;
    total_amount:   number;
    created_at:     Date;
    completed_at:   Date | null;
    failure_reason: string | null;
}
