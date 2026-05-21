/**
 * Types for the dashboard callable functions.
 * Este arquivo define as validações de dados e os esquemas de entrada para
 * as funções Cloud Callable relacionadas ao Dashboard. Ele utiliza a biblioteca
 * Zod para garantir que os dados recebidos no corpo das requisições estejam
 * no formato e tipo esperados antes de processá-los na camada de serviço.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import * as z from 'zod';


/**
 * TYPES
 */

/**
 * Esquema de validação Zod para a requisição de alternar o status de favorita de uma startup.
 * Garante que o identificador da startup esteja presente e não seja vazio.
 */
export const ToggleFavoriteRequest = z.object(
    {
        /**
         * Identificador único (Firestore Doc ID) da startup a ser marcada/desmarcada como favorita.
         */
        startupId: z.string().min(1, 'Startup ID is required'),
    },
);

/**
 * Esquema de validação Zod para a requisição de histórico de evolução patrimonial.
 * Garante que o período fornecido esteja em conformidade com as opções suportadas.
 */
export const GetPatrimonyHistoryRequest = z.object(
    {
        /**
         * Janela de período selecionada (d7, m1, m3, m6 ou y1).
         */
        period: z.enum(['d7', 'm1', 'm3', 'm6', 'y1']),
    },
);


/**
 * EXPORTS
 */

/**
 * Tipo TypeScript gerado a partir do esquema Zod para a requisição de alternar favorito.
 */
export type ToggleFavoriteRequest = z.infer<typeof ToggleFavoriteRequest>;

/**
 * Tipo TypeScript gerado para a requisição de histórico patrimonial.
 */
export type GetPatrimonyHistoryRequest = z.infer<typeof GetPatrimonyHistoryRequest>;
