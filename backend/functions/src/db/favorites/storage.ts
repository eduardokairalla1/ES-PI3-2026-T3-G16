/**
 * Operações do Banco de Dados para Favoritos.
 * Este arquivo atua como uma camada de abstração para gerenciar as startups favoritas dos usuários.
 * Internamente, ele delega as operações de persistência e consulta para o campo `favorite_ids`
 * contido no documento de cada usuário na coleção `users`.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

import {toggleFavoriteId, getFavoriteIds} from '../users/storage';


/**
 * Alterna a marcação de favorito de uma startup para o usuário informado.
 * Adiciona o ID da startup à lista se não existir, ou remove caso já esteja favoritado.
 *
 * @param uid       Identificador de autenticação (Firebase Auth UID) do usuário.
 * @param startupId Identificador exclusivo do documento da startup no Firestore.
 *
 * @returns Retorna true se a startup foi favoritada, ou false se foi removida dos favoritos.
 */
export async function toggleFavorite(uid: string, startupId: string): Promise<boolean>
{
    // Delegação para a rotina especializada de atualização no documento do usuário
    return toggleFavoriteId(uid, startupId);
}


/**
 * Recupera todos os IDs de startups marcadas como favoritas por um determinado usuário.
 *
 * @param uid Identificador de autenticação (Firebase Auth UID) do usuário.
 *
 * @returns Uma lista contendo os IDs das startups favoritas do usuário (como strings).
 */
export async function getUserFavoriteIds(uid: string): Promise<string[]>
{
    // Delegação para a rotina de busca de ID no documento do usuário
    return getFavoriteIds(uid);
}
