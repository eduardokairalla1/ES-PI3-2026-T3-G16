/**
 * Script de População (Seed) — Preenche o emulador do Firestore com investimentos de teste.
 * Este script deve ser executado com os emuladores do Firebase ativos na porta local.
 * Ele serve para gerar dados realistas de portfólio para o primeiro usuário cadastrado,
 * permitindo que a interface do aplicativo exiba gráficos e tabelas de investimentos de forma imediata.
 * 
 * Uso:
 *   npm run seed:investments
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';

import type {InvestmentDocument} from '../src/db/investments/model';
import type {StartupDocument} from '../src/db/startups/model';


/**
 * CODE
 */

// Inicializa a aplicação Admin do Firebase conectando-se aos emuladores locais correspondentes ao ID do projeto.
const app = initializeApp({projectId: 'mesclainvest-eda16'});
const db = getFirestore(app);
const auth = getAuth(app);


/**
 * Busca o identificador exclusivo do documento do usuário na coleção 'users' do Firestore
 * através do UID de autenticação do Firebase.
 *
 * @param uid O identificador exclusivo de autenticação do usuário.
 * @returns O Doc ID do Firestore ou null caso não seja localizado.
 */
async function getUserDocId(uid: string): Promise<string | null>
{
    // Realiza uma query buscando na coleção 'users' pelo campo 'uid' correspondente
    const snapshot = await db.collection('users').where('uid', '==', uid).limit(1).get();
    
    // Retorna nulo se o documento não for encontrado
    if (snapshot.empty) return null;
    
    // Retorna o ID de documento do primeiro resultado
    return snapshot.docs[0].id;
}


/**
 * Processa e simula o registro de uma transação de investimento de balcão (P2P).
 * Cria um registro físico na subcoleção de investimentos do usuário no Firestore.
 *
 * @param userDocId ID do documento do usuário no Firestore.
 * @param startup   Dados simplificados da startup emissora (id, name, logo_url).
 * @param quantity  Quantidade de tokens adquiridos.
 * @param price     Preço médio pago por token.
 */
async function processBalcaoTransaction(
    userDocId: string,
    startup: {id: string, name: string, logo_url: string},
    quantity: number,
    price: number,
): Promise<void>
{
    // Aponta para a subcoleção de investimentos pertencente ao usuário específico no Firestore
    const invCol = db.collection('users').doc(userDocId).collection('investments');

    // Prepara a estrutura do documento seguindo o modelo definido pela coleção
    const investment: Omit<InvestmentDocument, 'id'> = {
        'avg_purchase_price': price,
        'created_at': new Date(),
        'startup_id': startup.id,
        'startup_logo_url': startup.logo_url,
        'startup_name': startup.name,
        'token_quantity': quantity,
        'updated_at': null,
    };

    // Adiciona o documento de investimento à subcoleção correspondente
    const ref = await invCol.add(investment);
    console.log(`✓ [Balcão] Registro de ${quantity} tokens da startup "${startup.name}" concluído para o usuário ${userDocId} (Doc ID: ${ref.id})`);
}


/**
 * Função principal (Orquestradora) do Seed.
 * Recupera o primeiro usuário da Auth do Firebase, obtém as startups cadastradas
 * no banco e simula a aquisição de tokens de forma dinâmica para preencher o portfólio.
 */
async function seed(): Promise<void>
{
    console.log('Iniciando população (seed) de investimentos (utilizando a lógica de Balcão)...\n');

    // 1. Localiza a primeira conta criada no emulador de Autenticação do Firebase
    const listResult = await auth.listUsers(1);
    if (listResult.users.length === 0)
    {
        console.error('Nenhum usuário foi localizado no emulador de Auth. Crie um usuário no app primeiro.');
        process.exit(1);
    }

    const uid = listResult.users[0].uid;
    const userDocId = await getUserDocId(uid);

    // Valida se o usuário da Auth já possui um documento correspondente no Firestore
    if (userDocId === null)
    {
        console.error('Documento correspondente do usuário não existe no Firestore. Registre-se primeiro rodando o app.');
        process.exit(1);
    }

    console.log(`Usuário alvo UID: ${uid} (Doc ID: ${userDocId})\n`);

    // 2. Busca todas as startups existentes no Firestore ordenadas por nome
    const startupsSnapshot = await db.collection('startups').orderBy('name').get();
    if (startupsSnapshot.empty)
    {
        console.error('Nenhuma startup encontrada no Firestore. Execute o script seed-startups primeiro.');
        process.exit(1);
    }

    // Mapeia os documentos de startups obtidos para uma lista de objetos estruturados
    const startups = startupsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
    } as StartupDocument));

    // 3. Simula transações de investimentos de balcão de forma dinâmica
    // Limitamos a amostragem a no máximo 3 startups para preencher o portfólio inicial do usuário de teste
    const sampleSize = Math.min(startups.length, 3);

    for (let i = 0; i < sampleSize; i++)
    {
        const startup = startups[i];
        
        // Define valores de volume e preço baseados na ordenação para simular variação
        const quantity = 1000 * (i + 1);
        const price = startup.token_price || 0.5;

        // Executa a inserção do investimento no banco
        await processBalcaoTransaction(userDocId, startup, quantity, price);
    }

    console.log('\nPopulação de investimentos concluída com sucesso.');
}

// Inicializa a execução do fluxo principal capturando eventuais falhas críticas
seed().catch(err =>
{
    console.error('Falha crítica na população (seed):', err);
    process.exit(1);
});
