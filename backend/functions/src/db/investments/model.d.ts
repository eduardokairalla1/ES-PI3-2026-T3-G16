/**
 * Investment types and schema.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * TYPES
 */

export interface InvestmentDocument
{
    avg_purchase_price: number;
    created_at: Date;
    id: string;
    startup_id: string;
    startup_logo_url: string;
    startup_name: string;
    token_quantity: number;
    updated_at: Date | null;
}
