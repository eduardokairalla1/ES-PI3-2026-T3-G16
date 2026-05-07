/**
 * Transaction types and schema.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * TYPES
 */

export interface TransactionDocument
{
    amount: number;
    created_at: Date;
    description: string;
    id: string;
    type: 'deposit' | 'buy' | 'sell' | 'withdrawal';
    status: 'completed' | 'pending' | 'failed';
}
