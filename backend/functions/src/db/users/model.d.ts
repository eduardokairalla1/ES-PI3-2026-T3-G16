/**
 * User types and schema.
 *
 * Davi da Cruz Shieh - 24798076
 */


/**
 * TYPES
 */
export interface userDocument {
    birth_date: string;
    created_at: Date;
    cpf: string;
    email: string;
    full_name: string;
    phone: string;
    status: 'active' | 'inactive';
    uid: string;
    updated_at: Date | null;
}
