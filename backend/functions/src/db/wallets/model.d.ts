/**
 * Wallet types.
 *
 * Davi da Cruz Shieh - 24798076
 */


/**
 * TYPES
 */
export interface walletDocument
{
    uid: string;
    balance: number;
    created_at: Date;
    updated_at: Date | null;
}
