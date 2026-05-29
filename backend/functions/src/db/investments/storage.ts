/**
 * Operações de banco de dados para investimentos.
 * Este arquivo abstrai o acesso à subcoleção 'investments' sob o documento de cada usuário no Firestore.
 * Ele gerencia a leitura dos investimentos ativos feitos pelos usuários em diferentes startups.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import db from '../../configs';
import {getUserDocId} from '../users/storage';


/**
 * TYPES
 */
import type {InvestmentDocument} from './model';


/**
 * CODE
 */


/**
 * Retorna todos os investimentos ativos de um usuário específico.
 * Os investimentos são buscados da subcoleção interna 'investments' do respectivo documento do usuário
 * e retornados ordenados em ordem alfabética ascendente pelo nome da startup.
 *
 * @param uid Identificador único de autenticação (Firebase Auth UID) do usuário.
 *
 * @returns Lista contendo os documentos de investimento formatados como `InvestmentDocument`.
 * Retorna um array vazio se o usuário não for encontrado no banco de dados.
 */
export async function getUserInvestments(uid: string): Promise<InvestmentDocument[]>
{
    // 1. Obtém o ID interno do documento do usuário no Firestore a partir do UID de autenticação
    const userDocId = await getUserDocId(uid);
    if (userDocId === null) return [];

    // 2. Realiza a consulta na subcoleção de investimentos ordenando alfabeticamente
    const snapshot = await db
        .collection('users')
        .doc(userDocId)
        .collection('investments')
        .orderBy('startup_name')
        .get();

    // 3. Mapeia os documentos brutos retornados pelo Firestore para a tipagem forte do TypeScript
    return snapshot.docs.map(doc => ({id: doc.id, ...doc.data()} as InvestmentDocument));
}


/**
 * Verify if a user is an investor in a specific startup by checking the
 * 'investments' subcollection of the user's document.
 *
 * @param uid ID to check for the user (Firebase Auth UID).
 * @param startupId ID of the startup to check if the user has invested in.
 *
 * @returns `true` if the user is an investor in the startup, `false` otherwise.
 */
export async function isUserInvestorInStartup(uid: string, startupId: string): Promise<boolean>
{

    // get the user's document ID
    const userDocId = await getUserDocId(uid);
    if (userDocId === null) return false;

    // query the 'investments' subcollection for a document with the specified startup ID
    const snapshot = await db
        .collection('users')
        .doc(userDocId)
        .collection('investments')
        .where('startup_id', '==', startupId)
        .limit(1)
        .get();

    // if the snapshot is empty, the user is not an investor in the startup; otherwise, they are
    return !snapshot.empty;
}
