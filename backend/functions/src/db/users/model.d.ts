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
    birth_date: string;
    created_at: Date;
    cpf: string;
    email: string;
    favorite_ids: string[];
    full_name: string;
    phone: string;
    photo_url: string | null;
    status: 'active' | 'inactive';
    totp_secret: string | null;
    two_fa_enabled: boolean;
    uid: string;
    updated_at: Date | null;
}
