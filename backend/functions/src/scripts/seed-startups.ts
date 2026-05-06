/**
 * Seed script — populates Firestore emulator with sample startups and
 * simulated price history (bonding curve).
 *
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

import type {StartupDocument} from '../db/startups/model';
import type {PriceSnapshotDocument} from '../db/price_history/model';


/**
 * CODE
 */

// initialize Firebase Admin pointing at the local emulator
const app = initializeApp({projectId: 'demo-mesclainvest'});
const db = getFirestore(app);


// --- HELPERS ---

/** Bonding curve: price = base × (1 + k × sold/total) */
function calcPrice(base: number, total: number, sold: number, k: number): number
{
    return base * (1 + k * (sold / total));
}

/**
 * I generate evenly-spaced Date objects between [from] and [to].
 * The last date is always [to].
 */
function dateRange(from: Date, to: Date, steps: number): Date[]
{
    const result: Date[] = [];
    const delta = (to.getTime() - from.getTime()) / (steps - 1);

    for (let i = 0; i < steps; i++)
    {
        result.push(new Date(from.getTime() + delta * i));
    }

    return result;
}

/**
 * I seed price history snapshots for a startup, simulating [totalSold] tokens
 * being purchased in batches spread from [from] to [to].
 *
 * @returns final { available_tokens, token_price } to update on the startup doc
 */
async function seedPriceHistory(
    startupId: string,
    basePrice: number,
    totalTokens: number,
    totalSold: number,
    appreciationFactor: number,
    from: Date,
    to: Date,
    steps: number,
): Promise<{available_tokens: number; token_price: number}>
{
    const dates    = dateRange(from, to, steps);
    const batchSz  = Math.floor(totalSold / steps);
    const col      = db.collection('price_history').doc(startupId).collection('snapshots');

    let soldSoFar = 0;

    for (const date of dates)
    {
        soldSoFar = Math.min(soldSoFar + batchSz, totalSold);
        const price = calcPrice(basePrice, totalTokens, soldSoFar, appreciationFactor);

        const ref      = col.doc();
        const snapshot: PriceSnapshotDocument = {
            id:          ref.id,
            startup_id:  startupId,
            price,
            tokens_sold: soldSoFar,
            recorded_at: date,
        };

        await ref.set(snapshot);
    }

    const finalPrice = calcPrice(basePrice, totalTokens, totalSold, appreciationFactor);

    console.log(
        `  → ${steps} snapshots | ${totalSold.toLocaleString()} tokens sold` +
        ` | price: R$${basePrice.toFixed(4)} → R$${finalPrice.toFixed(4)}`,
    );

    return {
        available_tokens: totalTokens - totalSold,
        token_price:      finalPrice,
    };
}


// --- STARTUP DEFINITIONS ---

const now       = new Date('2026-05-03T12:00:00Z');
const jan15     = new Date('2026-01-15');
const aug10     = new Date('2025-08-10');
const sixMonths = new Date(now.getTime() - 180 * 24 * 60 * 60 * 1000);

interface StartupSeed extends Omit<StartupDocument, 'id' | 'available_tokens' | 'token_price'>
{
    _historyFrom:  Date;
    _historySteps: number;
    _totalSold:    number;
}

const startupSeeds: StartupSeed[] = [
    {
        advisors: [{name: 'Prof. Dr. Ricardo Alves', role: 'Mentor de Negócios'}],
        appreciation_factor: 2.0,
        base_price:          0.10,
        capital_raised:      18000,
        created_at:          jan15,
        description: 'A TheraCare é uma plataforma de saúde mental que conecta pacientes a psicólogos credenciados por meio de teleconsultas acessíveis e acompanhamento contínuo. Nossa missão é democratizar o acesso à saúde mental no Brasil, oferecendo atendimento de qualidade a preços acessíveis e com total privacidade.',
        executive_summary: 'O Brasil possui apenas 3,2 psicólogos por 10.000 habitantes, muito abaixo da média recomendada pela OMS. A TheraCare resolve esse gargalo oferecendo teleconsultas de saúde mental com psicólogos credenciados pelo CFP, a partir de R$ 80 por sessão. Nosso modelo SaaS cobra uma comissão de 20% por sessão realizada, sem mensalidade para os profissionais. Em 3 meses de operação no modo beta fechado, validamos 47 sessões com NPS de 92. Buscamos R$ 200.000 em capital semente para escalar a aquisição de usuários e contratar 2 desenvolvedores.',
        logo_url: 'https://placehold.co/200x200/4F46E5/FFFFFF?text=TC',
        name: 'TheraCare',
        partners: [
            {avatar_url: null, bio: 'Psicóloga formada pela PUC-Campinas, especialista em TCC. Idealizadora da plataforma após identificar a dificuldade de acesso a psicólogos acessíveis durante a pandemia.', equity_pct: 60, name: 'Ana Paula Ferreira', role: 'CEO & Co-fundadora'},
            {avatar_url: null, bio: 'Engenheiro de Software pela Unicamp, 4 anos de experiência em desenvolvimento mobile. Responsável pela arquitetura técnica da plataforma.', equity_pct: 40, name: 'Lucas Mendes', role: 'CTO & Co-fundador'},
        ],
        stage:       'new',
        tagline:     'Saúde mental acessível para todos',
        total_tokens: 1_000_000,
        updated_at:  null,
        video_url:   null,
        // history: 108 days (Jan 15 → May 3), 27 steps, 150k tokens sold (15%)
        _historyFrom:  jan15,
        _historySteps: 27,
        _totalSold:    150_000,
    },
    {
        advisors: [
            {name: 'Eng. Carlos Souza', role: 'Mentor de Agronegócio'},
            {name: 'Profa. Dra. Mariana Costa', role: 'Mentora de Inovação'},
        ],
        appreciation_factor: 1.0,
        base_price:          0.35,
        capital_raised:      215000,
        created_at:          aug10,
        description: 'A AgroLink é um marketplace B2B que conecta pequenos e médios produtores rurais diretamente a fornecedores de insumos agrícolas certificados, eliminando intermediários e reduzindo custos em até 35%. Nossa plataforma também oferece acesso a crédito rural simplificado e assistência técnica digital.',
        executive_summary: 'O agronegócio brasileiro movimenta R$ 2,4 trilhões por ano, mas pequenos produtores pagam em média 40% a mais em insumos por causa da cadeia de intermediários. A AgroLink conecta produtores diretamente a distribuidores credenciados, com entrega logística integrada. Operamos há 8 meses com 120 produtores ativos em 3 municípios do interior de SP, GMV mensal de R$ 180.000 e margem de 8% sobre transações. Buscamos R$ 500.000 para expandir para mais 10 municípios e desenvolver o módulo de crédito rural.',
        logo_url: 'https://placehold.co/200x200/16A34A/FFFFFF?text=AL',
        name: 'AgroLink',
        partners: [
            {avatar_url: null, bio: 'Engenheiro Agrônomo pela ESALQ-USP, filho de agricultor. Trabalhou 3 anos em uma cooperativa agrícola antes de fundar a AgroLink.', equity_pct: 50, name: 'Rafael Oliveira', role: 'CEO & Co-fundadora'},
            {avatar_url: null, bio: 'Especialista em logística e supply chain, ex-Ambev. Responsável pelas operações e parcerias com distribuidores.', equity_pct: 30, name: 'Fernanda Lima', role: 'COO & Co-fundadora'},
            {avatar_url: null, bio: 'Desenvolvedor full-stack com experiência em marketplaces B2B. Lidera o desenvolvimento da plataforma e integrações com ERPs.', equity_pct: 20, name: 'Matheus Santos', role: 'CTO & Co-fundador'},
        ],
        stage:        'operating',
        tagline:      'O marketplace que conecta o campo ao futuro',
        total_tokens: 5_000_000,
        updated_at:   new Date('2026-03-20'),
        video_url:    null,
        // history: last 6 months (30 steps), 1.5M tokens sold (30%)
        _historyFrom:  sixMonths,
        _historySteps: 30,
        _totalSold:    1_500_000,
    },
    {
        advisors: [{name: 'Dr. Paulo Henrique Ramos', role: 'Mentor de Mobilidade Urbana'}],
        appreciation_factor: 0.5,
        base_price:          0.95,
        capital_raised:      1350000,
        created_at:          new Date('2024-11-01'),
        description: 'A UrbanMob é um super-app de mobilidade urbana sustentável que integra bicicletas elétricas compartilhadas, patinetes e transporte público em uma única plataforma. Premiada pela prefeitura de Campinas como solução de impacto ambiental, já evitou a emissão de 12 toneladas de CO₂ em 2025.',
        executive_summary: 'Campinas tem 1,2 milhão de habitantes e um dos piores índices de mobilidade urbana do interior paulista. A UrbanMob integra micromobilidade elétrica (bikes e patinetes) com transporte público em um único app, com plano mensal de R$ 49,90. Operamos com frota de 200 bikes e 150 patinetes em 3 zonas da cidade, 8.200 usuários ativos mensais e receita recorrente de R$ 320.000/mês. Estamos expandindo para Sorocaba e São José dos Campos e buscamos R$ 3.000.000 para aquisição de frota e operações nas novas cidades.',
        logo_url: 'https://placehold.co/200x200/0EA5E9/FFFFFF?text=UM',
        name: 'UrbanMob',
        partners: [
            {avatar_url: null, bio: 'Engenheira Civil pela PUC-Campinas com mestrado em Urbanismo. Especialista em mobilidade sustentável e políticas públicas de transporte.', equity_pct: 45, name: 'Camila Rodrigues', role: 'CEO & Co-fundadora'},
            {avatar_url: null, bio: 'Ex-engenheiro da Tesla, especialista em veículos elétricos e manutenção de frotas. Responsável pela operação e manutenção da frota.', equity_pct: 35, name: 'Diego Araújo', role: 'COO & Co-fundador'},
            {avatar_url: null, bio: 'Designer de produto com experiência em super-apps de mobilidade no sudeste asiático. Lidera UX e expansão de parcerias.', equity_pct: 20, name: 'Julia Nunes', role: 'CPO & Co-fundadora'},
        ],
        stage:        'expanding',
        tagline:      'Mova-se pela cidade, preserve o planeta',
        total_tokens: 10_000_000,
        updated_at:   new Date('2026-04-10'),
        video_url:    null,
        // history: last 6 months (30 steps), 4M tokens sold (40%)
        _historyFrom:  sixMonths,
        _historySteps: 30,
        _totalSold:    4_000_000,
    },
    {
        advisors: [{name: 'Prof. Dr. Henrique Tavares', role: 'Mentor de Educação'}],
        appreciation_factor: 1.5,
        base_price:          0.20,
        capital_raised:      85000,
        created_at:          new Date('2026-02-10'),
        description: 'A EduMais é uma plataforma de educação adaptativa que usa inteligência artificial para personalizar o aprendizado de estudantes do ensino médio público. O sistema identifica lacunas de conhecimento e gera trilhas de estudo individualizadas, conectando alunos a tutores voluntários universitários.',
        executive_summary: 'Apenas 27% dos alunos do ensino médio público brasileiro atingem nível adequado em matemática. A EduMais usa IA para mapear o nível de cada aluno e gerar planos de estudo personalizados, com tutoria humana sob demanda. Em 4 meses de piloto em 3 escolas de Campinas, aumentamos a nota média em 18% e retemos 74% dos alunos ativos. O modelo B2G cobra R$ 12/aluno/mês das prefeituras. Buscamos R$ 300.000 para escalar para 20 escolas e desenvolver o módulo de preparação para o ENEM.',
        logo_url: 'https://placehold.co/200x200/F59E0B/FFFFFF?text=EM',
        name: 'EduMais',
        partners: [
            {avatar_url: null, bio: 'Pedagoga com doutorado em Tecnologia Educacional pela Unicamp. 6 anos de experiência em políticas públicas de educação.', equity_pct: 55, name: 'Beatriz Carvalho', role: 'CEO & Co-fundadora'},
            {avatar_url: null, bio: 'Engenheiro de ML pela USP, especialista em sistemas de recomendação e NLP aplicado à educação.', equity_pct: 45, name: 'André Figueiredo', role: 'CTO & Co-fundador'},
        ],
        stage:        'new',
        tagline:      'Aprendizado personalizado para cada aluno',
        total_tokens: 2_000_000,
        updated_at:   null,
        video_url:    null,
        // history: 82 days (Feb 10 → May 3), 20 steps, 300k tokens sold (15%)
        _historyFrom:  new Date('2026-02-10'),
        _historySteps: 20,
        _totalSold:    300_000,
    },
    {
        advisors: [
            {name: 'Dra. Silvia Monteiro', role: 'Mentora de Saúde Digital'},
            {name: 'Dr. Roberto Faria', role: 'Mentor de Logística'},
        ],
        appreciation_factor: 0.8,
        base_price:          0.60,
        capital_raised:      720000,
        created_at:          new Date('2025-06-01'),
        description: 'A MediLog é uma plataforma SaaS de gestão logística para distribuidoras de medicamentos e clínicas de médio porte. Automatiza o controle de estoque, rastreabilidade por lote, vencimentos e pedidos automáticos, reduzindo desperdício em até 42% e tempo de gestão em 60%.',
        executive_summary: 'O Brasil desperdiça R$ 1,2 bilhão em medicamentos vencidos por ano, principalmente em distribuidoras e clínicas que ainda usam planilhas. A MediLog resolve esse problema com rastreabilidade em tempo real, alertas de vencimento e reposição automática integrada aos principais ERPs do setor. Temos 38 clientes pagantes com ticket médio de R$ 1.800/mês e churn mensal de apenas 1,2%. Buscamos R$ 1.500.000 para expandir o time de vendas e lançar integrações com planos de saúde.',
        logo_url: 'https://placehold.co/200x200/6D28D9/FFFFFF?text=ML',
        name: 'MediLog',
        partners: [
            {avatar_url: null, bio: 'Farmacêutica com MBA em Gestão da Saúde. Trabalhou 5 anos em uma distribuidora farmacêutica antes de identificar as ineficiências que a MediLog resolve.', equity_pct: 50, name: 'Priscila Borges', role: 'CEO & Co-fundadora'},
            {avatar_url: null, bio: 'Especialista em supply chain e sistemas ERP, ex-TOTVS. Responsável pelas integrações e arquitetura do produto.', equity_pct: 30, name: 'Thiago Vieira', role: 'CTO & Co-fundador'},
            {avatar_url: null, bio: 'Especialista em vendas B2B para o setor de saúde, com carteira de 50+ clínicas e distribuidoras.', equity_pct: 20, name: 'Gustavo Prado', role: 'CSO & Co-fundador'},
        ],
        stage:        'operating',
        tagline:      'Gestão inteligente de medicamentos sem desperdício',
        total_tokens: 8_000_000,
        updated_at:   new Date('2026-04-15'),
        video_url:    null,
        // history: last 6 months (30 steps), 2.4M tokens sold (30%)
        _historyFrom:  sixMonths,
        _historySteps: 30,
        _totalSold:    2_400_000,
    },
    {
        advisors: [{name: 'Dr. Felipe Andrade', role: 'Mentor de Energia Renovável'}],
        appreciation_factor: 1.2,
        base_price:          0.45,
        capital_raised:      310000,
        created_at:          new Date('2025-10-15'),
        description: 'A SolarGrid é uma fintech de energia que viabiliza a instalação de painéis solares em residências de baixa renda por meio de um modelo de assinatura sem entrada. O cliente paga mensalmente um valor inferior à sua conta de luz atual e se torna proprietário do sistema após 5 anos.',
        executive_summary: 'Mais de 30 milhões de brasileiros vivem em moradias próprias mas não têm acesso ao crédito para instalar energia solar. A SolarGrid resolve isso com um modelo de assinatura: instalamos sem custo inicial, o cliente paga R$ 89/mês (abaixo da conta atual) e recebe o sistema quitado após 60 meses. Temos 210 instalações ativas em Campinas e Ribeirão Preto, receita recorrente de R$ 18.690/mês e payback médio de 38 meses. Buscamos R$ 800.000 para financiar 500 novas instalações e expandir para o Nordeste.',
        logo_url: 'https://placehold.co/200x200/D97706/FFFFFF?text=SG',
        name: 'SolarGrid',
        partners: [
            {avatar_url: null, bio: 'Engenheiro Elétrico pela Poli-USP com especialização em energias renováveis. Liderou projetos de energia solar em 3 países antes de fundar a SolarGrid.', equity_pct: 50, name: 'Leonardo Braga', role: 'CEO & Co-fundador'},
            {avatar_url: null, bio: 'Economista com experiência em crédito popular no Banco do Nordeste. Estruturou o modelo financeiro de assinatura da empresa.', equity_pct: 30, name: 'Natália Queiroz', role: 'CFO & Co-fundadora'},
            {avatar_url: null, bio: 'Técnico em energia solar com 8 anos de experiência em instalação e manutenção de sistemas fotovoltaicos.', equity_pct: 20, name: 'Henrique Souza', role: 'COO & Co-fundador'},
        ],
        stage:        'operating',
        tagline:      'Energia solar para quem mais precisa, sem entrada',
        total_tokens: 6_000_000,
        updated_at:   new Date('2026-03-01'),
        video_url:    null,
        _historyFrom:  new Date('2025-10-15'),
        _historySteps: 28,
        _totalSold:    1_800_000,
    },
    {
        advisors: [
            {name: 'Profa. Dra. Carla Mendonça', role: 'Mentora de FoodTech'},
            {name: 'Chef Rodrigo Olivetti', role: 'Consultor Gastronômico'},
        ],
        appreciation_factor: 2.5,
        base_price:          0.08,
        capital_raised:      42000,
        created_at:          new Date('2026-03-01'),
        description: 'A NutriBox é um serviço de assinatura de refeições plant-based congeladas desenvolvidas por nutricionistas e chefs, entregues semanalmente em embalagens 100% compostáveis. Cada refeição é formulada para atender às necessidades nutricionais completas com ingredientes de pequenos produtores locais.',
        executive_summary: 'O mercado de alimentação saudável no Brasil cresceu 35% em 2025, mas falta conveniência: preparar refeições balanceadas consome 1h30 por dia. A NutriBox entrega 5 refeições plant-based por semana por R$ 149,90, com cardápio rotativo aprovado por nutricionistas. Em 2 meses de operação em Campinas, temos 180 assinantes ativos, churn de 4% e NPS de 87. Buscamos R$ 150.000 para escalar a produção e expandir para São Paulo.',
        logo_url: 'https://placehold.co/200x200/059669/FFFFFF?text=NB',
        name: 'NutriBox',
        partners: [
            {avatar_url: null, bio: 'Nutricionista formada pela PUC-Campinas, apaixonada por culinária plant-based. Desenvolveu todos os cardápios da NutriBox.', equity_pct: 60, name: 'Isabela Ramos', role: 'CEO & Co-fundadora'},
            {avatar_url: null, bio: 'Administrador com experiência em operações de foodservice. Responsável pela logística e relacionamento com fornecedores.', equity_pct: 40, name: 'Caio Ferreira', role: 'COO & Co-fundador'},
        ],
        stage:        'new',
        tagline:      'Refeições plant-based que cabem na sua rotina',
        total_tokens: 1_500_000,
        updated_at:   null,
        video_url:    null,
        _historyFrom:  new Date('2026-03-01'),
        _historySteps: 15,
        _totalSold:    120_000,
    },
    {
        advisors: [
            {name: 'Dr. Marcos Leal', role: 'Mentor de Logística Urbana'},
        ],
        appreciation_factor: 0.6,
        base_price:          1.20,
        capital_raised:      2800000,
        created_at:          new Date('2024-05-20'),
        description: 'A FleetOn é um sistema de gestão de frotas corporativas com rastreamento em tempo real, manutenção preditiva por IA e controle de consumo de combustível. Atende empresas com frotas de 10 a 500 veículos, reduzindo custos operacionais em até 28% no primeiro ano.',
        executive_summary: 'Empresas com frotas corporativas perdem em média 22% do orçamento com manutenções corretivas e uso ineficiente de combustível. A FleetOn monitora cada veículo em tempo real, antecipa falhas mecânicas com IA e otimiza rotas automaticamente. Temos 85 clientes corporativos com ticket médio de R$ 3.200/mês, ARR de R$ 3.264.000 e NRR de 118%. Crescemos 12% ao mês nos últimos 6 meses. Buscamos R$ 5.000.000 para dobrar o time comercial e lançar o módulo de frotas elétricas.',
        logo_url: 'https://placehold.co/200x200/1E40AF/FFFFFF?text=FO',
        name: 'FleetOn',
        partners: [
            {avatar_url: null, bio: 'Engenheiro de Computação pela ITA, ex-engenheiro de produto no iFood. Especialista em sistemas de rastreamento e otimização de rotas.', equity_pct: 40, name: 'Victor Castelo', role: 'CEO & Co-fundador'},
            {avatar_url: null, bio: 'Cientista de dados pela USP com foco em manutenção preditiva industrial. Desenvolveu o motor de IA da FleetOn.', equity_pct: 35, name: 'Amanda Lopes', role: 'CTO & Co-fundadora'},
            {avatar_url: null, bio: 'Especialista em vendas enterprise com 10 anos de experiência no setor de frotas corporativas.', equity_pct: 25, name: 'Ricardo Monteiro', role: 'VP de Vendas & Co-fundador'},
        ],
        stage:        'expanding',
        tagline:      'Sua frota mais inteligente, seus custos mais baixos',
        total_tokens: 15_000_000,
        updated_at:   new Date('2026-04-28'),
        video_url:    null,
        _historyFrom:  new Date('2024-05-20'),
        _historySteps: 35,
        _totalSold:    9_000_000,
    },
];


// --- SEED ---

async function seed(): Promise<void>
{
    console.log('Seeding startups + price history...\n');

    for (const {_historyFrom, _historySteps, _totalSold, ...startup} of startupSeeds)
    {
        // create startup doc (token_price and available_tokens set after history)
        const ref = await db.collection('startups').add({
            ...startup,
            token_price:      startup.base_price,
            available_tokens: startup.total_tokens,
        });

        console.log(`✓ Created startup "${startup.name}" (${ref.id})`);

        // seed simulated price history
        const {available_tokens, token_price} = await seedPriceHistory(
            ref.id,
            startup.base_price,
            startup.total_tokens,
            _totalSold,
            startup.appreciation_factor,
            _historyFrom,
            now,
            _historySteps,
        );

        // update startup with final price and available tokens
        await ref.update({available_tokens, token_price});
        console.log(`  → Startup updated: available=${available_tokens.toLocaleString()}, price=R$${token_price.toFixed(4)}\n`);
    }

    console.log('Seed complete.');
}

seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
