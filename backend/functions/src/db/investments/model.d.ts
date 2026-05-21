/**
 * Modelos de tipo e esquemas para investimentos.
 * Este arquivo define a interface TypeScript correspondente à estrutura dos documentos
 * da subcoleção de investimentos (`users/{userId}/investments/*`) no Firestore.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * TYPES
 */

/**
 * Representa o documento de custódia de investimentos de um investidor em uma startup específica.
 */
export interface InvestmentDocument
{
    /**
     * Preço médio de aquisição pago pelos tokens da startup (calculado ponderadamente).
     */
    avg_purchase_price: number;

    /**
     * Data e hora em que o primeiro investimento (compra de token) nesta startup foi registrado.
     */
    created_at: Date;

    /**
     * Identificador do documento do investimento no Firestore.
     */
    id: string;

    /**
     * Identificador único (document ID) da startup na qual o investimento foi realizado.
     */
    startup_id: string;

    /**
     * URL para a imagem da logo da startup investida.
     */
    startup_logo_url: string;

    /**
     * Nome amigável/comercial da startup investida.
     */
    startup_name: string;

    /**
     * Quantidade total de tokens sob a posse (custódia) do investidor.
     */
    token_quantity: number;

    /**
     * Data e hora da última atualização de custódia (ex: nova compra/venda) realizada.
     * Pode ser nulo se nunca tiver sido atualizado após a criação.
     */
    updated_at: Date | null;
}
