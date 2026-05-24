/**
 * Function callable onToggleFavorite.
 * Serviço encarregado de alternar (adicionar ou remover) o status de "favorita"
 * de uma determinada startup no perfil do usuário autenticado.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {toggleFavorite} from '../../db/favorites/storage';
import {getStartup} from '../../db/startups/storage';
import {logger} from '../../utils/logger';
import {verifyAuth} from '../../utils/auth';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {NotFoundError} from '../../errors/notFoundError';
import {ValidationError} from '../../errors/validationError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';
import {ToggleFavoriteRequest} from '../../types/responders/dashboard';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * Manipula a requisição da Cloud Function Callable 'onToggleFavorite'.
 * Alterna o status de favorito da startup especificada para o usuário autenticado.
 *
 * @param request Objeto da requisição contendo o ID da startup no corpo (data.startupId) e o contexto de autenticação.
 * @returns Um objeto descrevendo o novo estado da relação (se está favoritado e o respectivo ID da startup).
 */
export async function handleOnToggleFavorite(request: CallableRequest)
{
    try
    {
        // 1. Valida se a requisição provém de um usuário devidamente autenticado
        const uid = verifyAuth(request);

        // 2. Valida os parâmetros de entrada utilizando o esquema Zod (ToggleFavoriteRequest)
        const parsed = parseRequest(ToggleFavoriteRequest, request.data);

        // 3. Verifica se a startup em questão de fato existe no Firestore
        const startup = await getStartup(parsed.startupId);
        if (startup === null)
        {
            throw new NotFoundError(`A startup com ID "${parsed.startupId}" não foi localizada.`);
        }

        // 4. Executa a alternância do status de favorito no banco de dados (relação muitos-para-muitos)
        logger.info(`Alternando favorito do usuário "${uid}" para a startup "${parsed.startupId}"...`);
        const isFavorited = await toggleFavorite(uid, parsed.startupId);
        logger.info(`Startup "${parsed.startupId}" agora está ${isFavorited ? 'favoritada' : 'removida dos favoritos'} pelo usuário "${uid}".`);

        // Retorna o resultado atualizado para persistência e sincronização otimista no front-end
        return {
            isFavorited,
            startupId: parsed.startupId,
        };
    }

    // Tratamento estruturado de exceções
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(`Erro de autenticação ao favoritar: ${error.message}`);
            throw new HttpsError('unauthenticated', error.message);
        }
        if (error instanceof NotFoundError)
        {
            logger.error(`Startup não encontrada: ${error.message}`);
            throw new HttpsError('not-found', error.message);
        }
        if (error instanceof ValidationError)
        {
            logger.error(`Erro de validação de argumentos: ${error.message}`);
            throw new HttpsError('invalid-argument', error.message);
        }

        const internal = new InternalError('Falha interna ao alternar status de favorita da startup.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
