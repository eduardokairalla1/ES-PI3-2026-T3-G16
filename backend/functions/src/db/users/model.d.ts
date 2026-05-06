/**
 * User types and schema.
 *
 * Davi da Cruz Shieh - 24798076
 */


/**
 * TYPES
 */
export interface userDocument
{
    balance: number;
    birth_date: string;

    created_at: Date;
    cpf: string;
    email: string;
    full_name: string;
    phone: string;
    photo_url: string | null;
    status: 'active' | 'inactive';
    two_fa_enabled: boolean;
    uid: string;
    updated_at: Date | null;
}
