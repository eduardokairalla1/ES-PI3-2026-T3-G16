/**
 * Esquemas e Definições de Tipos para Transações.
 * Este arquivo define a interface TypeScript correspondente ao modelo de dados de transações.
 * Utilizado para manter a consistência e segurança de tipos (Type Safety) nas consultas ao Firestore.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * TYPES
 */

/**
 * Interface que representa a estrutura de um documento de Transação no Firestore.
 */
export interface TransactionDocument
{
    /**
     * O valor financeiro envolvido na transação (em reais - BRL).
     */
    amount: number;

    /**
     * Data e hora do registro da transação.
     */
    created_at: Date;

    /**
     * Descrição textual legível sobre o motivo/origem da transação (ex: "Depósito PIX Simulado", "Compra de tokens Startup X").
     */
    description: string;

    /**
     * Identificador exclusivo do documento de transação gerado pelo Firestore.
     */
    id: string;

    /**
     * O tipo da movimentação:
     * - `deposit`: entrada de saldo simulado.
     * - `buy`: compra de tokens.
     * - `sell`: venda de tokens.
     * - `withdrawal`: saque de saldo simulado (caso implementado).
     */
    type: 'deposit' | 'buy' | 'sell' | 'withdrawal';

    /**
     * Estado atual do processamento da transação:
     * - `completed`: transação concluída com sucesso.
     * - `pending`: transação aguardando processamento.
     * - `failed`: transação mal-sucedida ou rejeitada.
     */
    status: 'completed' | 'pending' | 'failed';
}
