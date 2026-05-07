/**
 * Seed script — populates Firestore emulator with sample startups.
 * Run while the Firebase emulator is running:
 *   npm run seed
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';

import type {StartupDocument} from '../src/db/startups/model';


/**
 * CODE
 */

// initialize Firebase Admin pointing at the local emulator
const app = initializeApp({projectId: 'mesclainvest-eda16'});
const db = getFirestore(app);

// startups to seed
const startups: Omit<StartupDocument, 'id'>[] = [
    {
        'advisors': [
            {name: 'Prof. Dr. Ricardo Alves', role: 'Mentor de Negócios'},
        ],
        'capital_raised': 18000,
        'created_at': new Date('2026-01-15'),
        'description': 'A TheraCare é uma plataforma de saúde mental que conecta pacientes a psicólogos credenciados por meio de teleconsultas acessíveis e acompanhamento contínuo. Nossa missão é democratizar o acesso à saúde mental no Brasil, oferecendo atendimento de qualidade a preços acessíveis e com total privacidade.',
        'executive_summary': 'O Brasil possui apenas 3,2 psicólogos por 10.000 habitantes, muito abaixo da média recomendada pela OMS. A TheraCare resolve esse gargalo oferecendo teleconsultas de saúde mental com psicólogos credenciados pelo CFP, a partir de R$ 80 por sessão. Nosso modelo SaaS cobra uma comissão de 20% por sessão realizada, sem mensalidade para os profissionais. Em 3 meses de operação no modo beta fechado, validamos 47 sessões com NPS de 92. Buscamos R$ 200.000 em capital semente para escalar a aquisição de usuários e contratar 2 desenvolvedores.',
        'logo_url': 'https://placehold.co/200x200/4F46E5/FFFFFF?text=TC',
        'name': 'TheraCare',
        'partners': [
            {
                'avatar_url': null,
                'bio': 'Psicóloga formada pela PUC-Campinas, especialista em TCC. Idealizadora da plataforma após identificar a dificuldade de acesso a psicólogos acessíveis durante a pandemia.',
                'equity_pct': 60,
                'name': 'Ana Paula Ferreira',
                'role': 'CEO & Co-fundadora',
            },
            {
                'avatar_url': null,
                'bio': 'Engenheiro de Software pela Unicamp, 4 anos de experiência em desenvolvimento mobile. Responsável pela arquitetura técnica da plataforma.',
                'equity_pct': 40,
                'name': 'Lucas Mendes',
                'role': 'CTO & Co-fundador',
            },
        ],
        'stage': 'new',
        'tagline': 'Saúde mental acessível para todos',
        'token_price': 0.10,
        'total_tokens': 1000000,
        'updated_at': null,
        'video_url': null,
    },
    {
        'advisors': [
            {name: 'Eng. Carlos Souza', role: 'Mentor de Agronegócio'},
            {name: 'Profa. Dra. Mariana Costa', role: 'Mentora de Inovação'},
        ],
        'capital_raised': 215000,
        'created_at': new Date('2025-08-10'),
        'description': 'A AgroLink é um marketplace B2B que conecta pequenos e médios produtores rurais diretamente a fornecedores de insumos agrícolas certificados, eliminando intermediários e reduzindo custos em até 35%. Nossa plataforma também oferece acesso a crédito rural simplificado e assistência técnica digital.',
        'executive_summary': 'O agronegócio brasileiro movimenta R$ 2,4 trilhões por ano, mas pequenos produtores pagam em média 40% a mais em insumos por causa da cadeia de intermediários. A AgroLink conecta produtores diretamente a distribuidores credenciados, com entrega logística integrada. Operamos há 8 meses com 120 produtores ativos em 3 municípios do interior de SP, GMV mensal de R$ 180.000 e margem de 8% sobre transações. Buscamos R$ 500.000 para expandir para mais 10 municípios e desenvolver o módulo de crédito rural.',
        'logo_url': 'https://placehold.co/200x200/16A34A/FFFFFF?text=AL',
        'name': 'AgroLink',
        'partners': [
            {
                'avatar_url': null,
                'bio': 'Engenheiro Agrônomo pela ESALQ-USP, filho de agricultor. Trabalhou 3 anos em uma cooperativa agrícola antes de fundar a AgroLink.',
                'equity_pct': 50,
                'name': 'Rafael Oliveira',
                'role': 'CEO & Co-fundador',
            },
            {
                'avatar_url': null,
                'bio': 'Especialista em logística e supply chain, ex-Ambev. Responsável pelas operações e parcerias com distribuidores.',
                'equity_pct': 30,
                'name': 'Fernanda Lima',
                'role': 'COO & Co-fundadora',
            },
            {
                'avatar_url': null,
                'bio': 'Desenvolvedor full-stack com experiência em marketplaces B2B. Lidera o desenvolvimento da plataforma e integrações com ERPs.',
                'equity_pct': 20,
                'name': 'Matheus Santos',
                'role': 'CTO & Co-fundador',
            },
        ],
        'stage': 'operating',
        'tagline': 'O marketplace que conecta o campo ao futuro',
        'token_price': 0.35,
        'total_tokens': 5000000,
        'updated_at': new Date('2026-03-20'),
        'video_url': null,
    },
    {
        'advisors': [
            {name: 'Dr. Paulo Henrique Ramos', role: 'Mentor de Mobilidade Urbana'},
        ],
        'capital_raised': 1350000,
        'created_at': new Date('2024-11-01'),
        'description': 'A UrbanMob é um super-app de mobilidade urbana sustentável que integra bicicletas elétricas compartilhadas, patinetes e transporte público em uma única plataforma. Premiada pela prefeitura de Campinas como solução de impacto ambiental, já evitou a emissão de 12 toneladas de CO₂ em 2025.',
        'executive_summary': 'Campinas tem 1,2 milhão de habitantes e um dos piores índices de mobilidade urbana do interior paulista. A UrbanMob integra micromobilidade elétrica (bikes e patinetes) com transporte público em um único app, com plano mensal de R$ 49,90. Operamos com frota de 200 bikes e 150 patinetes em 3 zonas da cidade, 8.200 usuários ativos mensais e receita recorrente de R$ 320.000/mês. Estamos expandindo para Sorocaba e São José dos Campos e buscamos R$ 3.000.000 para aquisição de frota e operações nas novas cidades.',
        'logo_url': 'https://placehold.co/200x200/0EA5E9/FFFFFF?text=UM',
        'name': 'UrbanMob',
        'partners': [
            {
                'avatar_url': null,
                'bio': 'Engenheira Civil pela PUC-Campinas com mestrado em Urbanismo. Especialista em mobilidade sustentável e políticas públicas de transporte.',
                'equity_pct': 45,
                'name': 'Camila Rodrigues',
                'role': 'CEO & Co-fundadora',
            },
            {
                'avatar_url': null,
                'bio': 'Ex-engenheiro da Tesla, especialista em veículos elétricos e manutenção de frotas. Responsável pela operação e manutenção da frota.',
                'equity_pct': 35,
                'name': 'Diego Araújo',
                'role': 'COO & Co-fundador',
            },
            {
                'avatar_url': null,
                'bio': 'Designer de produto com experiência em super-apps de mobilidade no sudeste asiático. Lidera UX e expansão de parcerias.',
                'equity_pct': 20,
                'name': 'Julia Nunes',
                'role': 'CPO & Co-fundadora',
            },
        ],
        'stage': 'expanding',
        'tagline': 'Mova-se pela cidade, preserve o planeta',
        'token_price': 0.95,
        'total_tokens': 10000000,
        'updated_at': new Date('2026-04-10'),
        'video_url': null,
    },
];

async function seed(): Promise<void>
{
    console.log('Seeding startups...\n');

    const col = db.collection('startups');

    for (const startup of startups)
    {
        const ref = await col.add(startup);
        console.log(`✓ Created startup "${startup.name}" with ID: ${ref.id}`);
    }

    console.log('\nSeed complete.');
}

seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
