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
    // O documento do usuário sempre tem o mesmo ID que seu Firebase Auth UID
    // (ver addUser em users/storage.ts: db.collection('users').doc(uid).set(...))
    const snapshot = await db
        .collection('users')
        .doc(uid)
        .collection('investments')
        .orderBy('startup_name')
        .get();

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
    // O documento do usuário sempre tem o mesmo ID que seu Firebase Auth UID
    const doc = await db
        .collection('users')
        .doc(uid)
        .collection('investments')
        .doc(startupId)
        .get();

    return doc.exists;
}
