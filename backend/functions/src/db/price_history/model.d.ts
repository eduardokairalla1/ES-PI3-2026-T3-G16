/**
 * Price history types and schema.
 *
 * Davi da Cruz Shieh - 24798076
 */


/**
 * TYPES
 */

export interface PriceSnapshotDocument
{
    id:          string;
    startup_id:  string;
    price:       number;
    tokens_sold: number;
    recorded_at: Date;
}
