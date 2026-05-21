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
 * EXPORTS
 */

/**
 * Tipo TypeScript gerado a partir do esquema Zod para a requisição de alternar favorito.
 */
export type ToggleFavoriteRequest = z.infer<typeof ToggleFavoriteRequest>;
