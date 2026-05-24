/**
 * Esquemas e Definições de Tipos para Favoritos.
 * Este arquivo define a interface TypeScript correspondente ao modelo de dados de favoritos.
 * Utilizado para manter a consistência e segurança de tipos (Type Safety) nas consultas ao Firestore.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * TYPES
 */

/**
 * Interface que representa a estrutura de um documento de Favorito.
 */
export interface FavoriteDocument
{
    /**
     * Data e hora em que a startup foi adicionada aos favoritos pelo usuário.
     */
    created_at: Date;

    /**
     * Identificador exclusivo da startup favoritada.
     */
    startup_id: string;
}
