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
import * as fs from 'fs';
import * as path from 'path';
import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {getStorage} from 'firebase-admin/storage';

import type {StartupDocument} from '../src/db/startups/model';


/**
 * CODE
 */

const PROJECT_ID   = 'mesclainvest-eda16';
const BUCKET       = `${PROJECT_ID}.firebasestorage.app`;
const VIDEOS_DIR   = path.resolve(__dirname, '../../videos');
const STORAGE_HOST = process.env.FIREBASE_STORAGE_EMULATOR_HOST ?? 'localhost:9199';

// startup name → video filename (without extension)
const VIDEO_MAP: Record<string, string> = {
    'TheraCare':      'TheraCare',
    'AgroLink':       'AgroLink',
    'CreditAí':       'creditAi',
    'EduPath':        'EduPath',
    'SecurityShield': 'SecurityShield',
    'UrbanMob':       'UrbanMob',
};

// initialize Firebase Admin pointing at the local emulator
const app     = initializeApp({projectId: PROJECT_ID, storageBucket: BUCKET});
const db      = getFirestore(app);
const storage = getStorage(app);

// startups to seed
type RawStartup = Omit<StartupDocument, 'id' | 'appreciation_factor' | 'available_tokens' | 'base_price'>;

const startups: RawStartup[] = [
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
        'token_name': 'TC',
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
        'token_name': 'AL',
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
        'token_name': 'UM',
        'token_price': 0.95,
        'total_tokens': 10000000,
        'updated_at': new Date('2026-04-10'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Profa. Dra. Beatriz Souza', role: 'Mentora de Educação'}],
        'capital_raised': 95000,
        'created_at': new Date('2026-02-01'),
        'description': 'A EduPath é uma plataforma adaptativa de aprendizado que usa inteligência artificial para personalizar trilhas de estudo para estudantes do ensino médio público, aumentando a taxa de aprovação no ENEM em até 40%.',
        'executive_summary': 'O Brasil tem 8 milhões de alunos no ensino médio público com acesso precário a preparação de qualidade para o ENEM. A EduPath usa IA para gerar planos de estudo personalizados baseados no desempenho individual. Em 4 meses de piloto com 500 alunos em escolas de Fortaleza, a média nas simulações subiu 18%. Modelo freemium: básico gratuito, premium R$29/mês. Buscamos R$300.000 para expansão nacional.',
        'logo_url': 'https://placehold.co/200x200/7C3AED/FFFFFF?text=EP',
        'name': 'EduPath',
        'partners': [
            {'avatar_url': null, 'bio': 'Pedagoga com 10 anos em tecnologia educacional.', 'equity_pct': 55, 'name': 'Isabela Torres', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Cientista de dados especialista em modelos de aprendizado de máquina.', 'equity_pct': 45, 'name': 'Bruno Carvalho', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Aprendizado personalizado para todos os estudantes',
        'token_name': 'EP',
        'token_price': 0.08,
        'total_tokens': 2000000,
        'updated_at': null,
        'video_url': null,
    },
    {
        'advisors': [{name: 'Dr. Fernando Rocha', role: 'Mentor de Fintechs'}],
        'capital_raised': 780000,
        'created_at': new Date('2025-06-15'),
        'description': 'A CreditAí é uma fintech de crédito alternativo que oferece empréstimos pessoais para trabalhadores informais e autônomos usando score comportamental baseado em dados de renda variável e histórico de pagamentos de contas.',
        'executive_summary': '60 milhões de brasileiros são informais e estão excluídos do crédito bancário tradicional. A CreditAí usa open finance e dados alternativos para calcular risco de crédito com mais precisão. Operamos há 10 meses, já concedemos R$4,2M em empréstimos com inadimplência de 3,8% (abaixo da média do setor de 5,2%). Buscamos R$2.000.000 para expandir carteira e obter licença como SCDs.',
        'logo_url': 'https://placehold.co/200x200/059669/FFFFFF?text=CA',
        'name': 'CreditAí',
        'partners': [
            {'avatar_url': null, 'bio': 'Ex-analista de crédito do Itaú, especialista em risco.', 'equity_pct': 50, 'name': 'Thiago Almeida', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Engenheira de dados ex-Nubank com foco em modelos preditivos.', 'equity_pct': 50, 'name': 'Carla Mendes', 'role': 'CTO & Co-fundadora'},
        ],
        'stage': 'operating',
        'tagline': 'Crédito justo para quem trabalha por conta própria',
        'token_name': 'CA',
        'token_price': 0.65,
        'total_tokens': 8000000,
        'updated_at': new Date('2026-04-01'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Chef Marco Bassi', role: 'Mentor de FoodTech'}],
        'capital_raised': 420000,
        'created_at': new Date('2025-09-20'),
        'description': 'A PlantFoods desenvolve proteínas vegetais de alta performance para o mercado B2B de food service, fornecendo ingredientes para restaurantes e redes fast-food que querem oferecer opções plant-based sem abrir mão do sabor.',
        'executive_summary': 'O mercado de proteína vegetal no Brasil cresce 30% ao ano mas ainda depende de importação. A PlantFoods produz localmente com custo 25% menor que os concorrentes importados. Já fornecemos para 3 redes de fast-food com 80 pontos de venda. Receita mensal de R$210.000. Buscamos R$1.200.000 para ampliar capacidade produtiva e fechar contrato com rede nacional de 400 lojas.',
        'logo_url': 'https://placehold.co/200x200/65A30D/FFFFFF?text=PF',
        'name': 'PlantFoods',
        'partners': [
            {'avatar_url': null, 'bio': 'Engenheira de alimentos pela USP, especialista em proteínas vegetais.', 'equity_pct': 60, 'name': 'Mariana Vieira', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Empreendedor serial com duas exits no setor de alimentos.', 'equity_pct': 40, 'name': 'Roberto Farias', 'role': 'CSO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Proteína vegetal brasileira para o food service',
        'token_name': 'PF',
        'token_price': 0.42,
        'total_tokens': 6000000,
        'updated_at': new Date('2026-03-15'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Eng. Paulo Meirelles', role: 'Mentor de Energia'}],
        'capital_raised': 2100000,
        'created_at': new Date('2024-07-01'),
        'description': 'A SolarGrid é uma empresa de energia limpa que instala e gerencia microusinas solares em telhados de condomínios residenciais e comerciais via modelo de assinatura, sem custo inicial para o condomínio e com garantia de redução de 30% na conta de luz.',
        'executive_summary': 'O Brasil tem 500.000 condomínios com alto consumo de energia nas áreas comuns. A SolarGrid financia e instala painéis solares sem custo antecipado, cobrando mensalidade inferior à economia gerada. Portfólio atual: 180 condomínios, 6MW instalados, receita recorrente de R$890.000/mês. Expandindo para 5 novos estados. Buscamos R$8.000.000 para acelerar instalações e fechar pipeline de 400 condomínios.',
        'logo_url': 'https://placehold.co/200x200/F59E0B/FFFFFF?text=SG',
        'name': 'SolarGrid',
        'partners': [
            {'avatar_url': null, 'bio': 'Engenheiro elétrico ex-CPFL com 15 anos em projetos de energia renovável.', 'equity_pct': 45, 'name': 'Eduardo Pinto', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Especialista em financiamento de projetos de infraestrutura.', 'equity_pct': 35, 'name': 'Priscila Gomes', 'role': 'CFO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro de sistemas especialista em IoT para monitoramento energético.', 'equity_pct': 20, 'name': 'André Lima', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'expanding',
        'tagline': 'Energia solar sem investimento para condomínios',
        'token_name': 'SG',
        'token_price': 1.20,
        'total_tokens': 15000000,
        'updated_at': new Date('2026-04-20'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Dra. Renata Campos', role: 'Mentora de HealthTech'}],
        'capital_raised': 310000,
        'created_at': new Date('2025-11-10'),
        'description': 'A MedCheck é um app de triagem médica inteligente que ajuda pacientes a entenderem seus sintomas antes de uma consulta, sugere especialistas adequados e organiza todo o histórico médico digital de forma segura e acessível.',
        'executive_summary': 'Brasileiros perdem em média 4 horas por consulta desnecessária em pronto-socorros. O MedCheck usa IA clínica validada por médicos para triagem de sintomas com precisão de 87%. Em 6 meses, 45.000 usuários ativos, 12.000 consultas redirecionadas de pronto-socorros. Modelo B2C freemium + B2B para planos de saúde. Buscamos R$800.000 para parceria com 3 operadoras de saúde.',
        'logo_url': 'https://placehold.co/200x200/DC2626/FFFFFF?text=MC',
        'name': 'MedCheck',
        'partners': [
            {'avatar_url': null, 'bio': 'Médica emergencista com pós em informática em saúde.', 'equity_pct': 50, 'name': 'Dra. Amanda Castro', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro de IA com foco em NLP para área da saúde.', 'equity_pct': 50, 'name': 'Felipe Ramos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Entenda seus sintomas antes de ir ao médico',
        'token_name': 'MC',
        'token_price': 0.18,
        'total_tokens': 3000000,
        'updated_at': null,
        'video_url': null,
    },
    {
        'advisors': [{name: 'Arq. Sandra Moreira', role: 'Mentora de PropTech'}],
        'capital_raised': 560000,
        'created_at': new Date('2025-07-22'),
        'description': 'A HomeKey é uma proptech que digitaliza e simplifica todo o processo de aluguel residencial, desde a busca e visita virtual até a assinatura do contrato e gestão de pagamentos, eliminando fiança e burocracia com garantidora digital integrada.',
        'executive_summary': 'O mercado de aluguel no Brasil movimenta R$120B/ano, mas o processo é analógico e lento. A HomeKey fecha um aluguel em 72h vs. a média de 30 dias no mercado tradicional. Em operação há 11 meses em São Paulo com 1.200 contratos ativos, taxa de churn de imóveis de apenas 2,1%. Receita de R$380.000/mês entre taxa de intermediação e mensalidade de gestão. Buscamos R$2.500.000 para expansão para RJ, BH e Curitiba.',
        'logo_url': 'https://placehold.co/200x200/2563EB/FFFFFF?text=HK',
        'name': 'HomeKey',
        'partners': [
            {'avatar_url': null, 'bio': 'Ex-corretor com 8 anos de mercado imobiliário e MBA em tecnologia.', 'equity_pct': 40, 'name': 'Guilherme Prado', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Advogada especialista em direito imobiliário e contratos digitais.', 'equity_pct': 30, 'name': 'Natália Costa', 'role': 'CLO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Desenvolvedor full-stack ex-QuintoAndar.', 'equity_pct': 30, 'name': 'Leandro Ferreira', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Alugue seu imóvel em 72 horas, sem fiança',
        'token_name': 'HK',
        'token_price': 0.55,
        'total_tokens': 7000000,
        'updated_at': new Date('2026-03-01'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Dr. Maurício Leal', role: 'Mentor Jurídico'}],
        'capital_raised': 180000,
        'created_at': new Date('2026-01-08'),
        'description': 'A LexAI é uma plataforma de inteligência artificial jurídica que automatiza a análise de contratos, petições e jurisprudência para escritórios de advocacia e departamentos jurídicos, reduzindo em 70% o tempo gasto em tarefas repetitivas.',
        'executive_summary': 'Advogados brasileiros gastam 40% do tempo em tarefas de análise documental que podem ser automatizadas. A LexAI usa LLMs especializados em direito brasileiro para revisar contratos e identificar riscos em minutos. Em 3 meses de beta, 28 escritórios clientes pagando R$1.800/mês cada. ARR atual de R$600.000. Buscamos R$500.000 para escalar vendas e desenvolver módulo de geração automática de documentos.',
        'logo_url': 'https://placehold.co/200x200/1E3A5F/FFFFFF?text=LA',
        'name': 'LexAI',
        'partners': [
            {'avatar_url': null, 'bio': 'Advogado tributarista com experiência em legal tech nos EUA.', 'equity_pct': 55, 'name': 'Henrique Souza', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Pesquisador de NLP com doutorado em linguística computacional.', 'equity_pct': 45, 'name': 'Tatiana Barros', 'role': 'CTO & Co-fundadora'},
        ],
        'stage': 'new',
        'tagline': 'Inteligência artificial para o escritório jurídico moderno',
        'token_name': 'LA',
        'token_price': 0.22,
        'total_tokens': 2500000,
        'updated_at': null,
        'video_url': null,
    },
    {
        'advisors': [{name: 'Eng. Carlos Brito', role: 'Mentor de Logística'}],
        'capital_raised': 1650000,
        'created_at': new Date('2024-09-15'),
        'description': 'A CargoHop é um marketplace de frete fracionado que conecta embarcadores com espaço disponível em caminhões já em rota, otimizando a logística de última milha e reduzindo custos de transporte em até 45% para pequenas e médias empresas.',
        'executive_summary': 'Caminhões brasileiros rodam com apenas 60% da capacidade em média, desperdiçando R$40B/ano em logística. A CargoHop usa algoritmos de roteirização para otimizar cargas compartilhadas em tempo real. Operamos em 12 estados, 3.200 transportadoras cadastradas, 8.500 embarques/mês, take rate de 6%. Receita mensal de R$1.2M. Buscamos R$5.000.000 para tecnologia de rastreamento IoT e expansão para todo o Brasil.',
        'logo_url': 'https://placehold.co/200x200/EA580C/FFFFFF?text=CH',
        'name': 'CargoHop',
        'partners': [
            {'avatar_url': null, 'bio': 'Ex-diretor de logística da Ambev, 12 anos em supply chain.', 'equity_pct': 40, 'name': 'Roberto Mello', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Especialista em algoritmos de otimização logística.', 'equity_pct': 35, 'name': 'Lucas Freitas', 'role': 'CTO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Especialista em expansão comercial B2B no setor de transporte.', 'equity_pct': 25, 'name': 'Juliana Azevedo', 'role': 'CCO & Co-fundadora'},
        ],
        'stage': 'expanding',
        'tagline': 'Frete inteligente que cabe no seu orçamento',
        'token_name': 'CH',
        'token_price': 1.10,
        'total_tokens': 12000000,
        'updated_at': new Date('2026-04-25'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Dra. Patrícia Neves', role: 'Mentora de Varejo'}],
        'capital_raised': 230000,
        'created_at': new Date('2025-10-05'),
        'description': 'A StockSmart é um sistema de gestão de estoque com IA para pequenos varejos, que prevê a demanda com precisão de 91% e automatiza pedidos de reposição, eliminando rupturas e reduzindo estoque parado em até 35%.',
        'executive_summary': 'Pequenos varejos no Brasil perdem R$15B/ano em vendas por ruptura de estoque e têm R$20B parados em excesso. A StockSmart usa IA preditiva integrada ao PDV para automatizar reposição. Em 8 meses, 320 varejos clientes pagando R$299/mês. Churn de apenas 1,8%. Buscamos R$700.000 para integração com principais ERPs do mercado e expansão da equipe comercial.',
        'logo_url': 'https://placehold.co/200x200/0891B2/FFFFFF?text=SS',
        'name': 'StockSmart',
        'partners': [
            {'avatar_url': null, 'bio': 'Engenheira de produção ex-Renner com especialização em supply chain.', 'equity_pct': 50, 'name': 'Viviane Campos', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Cientista de dados especialista em séries temporais e previsão de demanda.', 'equity_pct': 50, 'name': 'Gabriel Martins', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Nunca mais perca uma venda por falta de estoque',
        'token_name': 'SS',
        'token_price': 0.28,
        'total_tokens': 4000000,
        'updated_at': new Date('2026-02-10'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Prof. Dr. Alexandre Nunes', role: 'Mentor de Impacto Social'}],
        'capital_raised': 145000,
        'created_at': new Date('2026-03-01'),
        'description': 'A ReciclaJob conecta catadores de materiais recicláveis a cooperativas e empresas compradoras via app, digitalizando a cadeia de reciclagem informal, aumentando a renda dos catadores em até 60% e garantindo rastreabilidade dos materiais para empresas com metas ESG.',
        'executive_summary': 'O Brasil tem 800.000 catadores informais que ganham em média R$700/mês e perdem 30% de receita por falta de acesso a melhores compradores. A ReciclaJob digitaliza essa cadeia com geolocalização, precificação em tempo real e pagamento instantâneo via Pix. Em 2 meses de piloto em Belo Horizonte, 180 catadores cadastrados com aumento médio de renda de 52%. Buscamos R$350.000 para expansão e desenvolvimento do módulo ESG para empresas.',
        'logo_url': 'https://placehold.co/200x200/15803D/FFFFFF?text=RJ',
        'name': 'ReciclaJob',
        'partners': [
            {'avatar_url': null, 'bio': 'Assistente social com MBA em negócios de impacto social.', 'equity_pct': 60, 'name': 'Simone Barbosa', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Desenvolvedor mobile com experiência em apps para comunidades de baixa renda.', 'equity_pct': 40, 'name': 'Caio Oliveira', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Dignidade e renda para quem sustenta a reciclagem',
        'token_name': 'RJ',
        'token_price': 0.06,
        'total_tokens': 1500000,
        'updated_at': null,
        'video_url': null,
    },
    {
        'advisors': [{name: 'Eng. Roberto Silva', role: 'Mentor de Saneamento'}],
        'capital_raised': 50000,
        'created_at': new Date('2026-02-15'),
        'description': 'A CleanWater desenvolve sistemas inteligentes de purificação e reuso de água cinza para condomínios residenciais e comerciais, promovendo economia de até 40% na conta de água e selo verde ESG.',
        'executive_summary': 'A escassez hídrica é um problema crescente nas metrópoles. A CleanWater instala estações compactas de tratamento de água cinza com IoT integrada. Nosso modelo comercial é a assinatura de manutenção mais uma taxa sobre o volume tratado. Temos 5 projetos pilotos ativos com economia média comprovada de 38% e satisfação total. Buscamos R$ 250.000 para acelerar a produção de novas unidades e expandir time de vendas.',
        'logo_url': 'https://placehold.co/200x200/0284C7/FFFFFF?text=CW',
        'name': 'CleanWater',
        'partners': [
            {'avatar_url': null, 'bio': 'Engenheiro ambiental formado pela Poli-USP com foco em tratamento de efluentes.', 'equity_pct': 70, 'name': 'Guilherme Silva', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Engenheira eletrônica ex-Embraer responsável pelo sistema de controle IoT.', 'equity_pct': 30, 'name': 'Fernanda Souza', 'role': 'CTO & Co-fundadora'},
        ],
        'stage': 'new',
        'tagline': 'Tecnologia inteligente para o reuso de água',
        'token_name': 'CW',
        'token_price': 0.12,
        'total_tokens': 1200000,
        'updated_at': null,
        'video_url': null,
    },
    {
        'advisors': [{name: 'Chef Luiza Trajano', role: 'Mentora de Negócios Gastronômicos'}],
        'capital_raised': 350000,
        'created_at': new Date('2025-09-10'),
        'description': 'A DeliveryGourmet é um SaaS de gestão integrada e marketplace de alta gastronomia para restaurantes premium operarem seus próprios canais de delivery com experiência customizada e frota de entregadores exclusiva.',
        'executive_summary': 'Restaurantes premium se recusam a usar aplicativos de delivery tradicionais devido a altas taxas e falta de controle da experiência de entrega. A DeliveryGourmet oferece uma solução white-label com taxas fixas e logística treinada. Temos 45 restaurantes de alta gastronomia ativos em São Paulo, faturamento mensal recorrente de R$ 120.000 e crescimento de 15% ao mês. Buscamos R$ 1.500.000 para expansão no Rio e Belo Horizonte.',
        'logo_url': 'https://placehold.co/200x200/B45309/FFFFFF?text=DG',
        'name': 'DeliveryGourmet',
        'partners': [
            {'avatar_url': null, 'bio': 'Empreendedor do setor de gastronomia com passagens por grandes redes de hotéis.', 'equity_pct': 50, 'name': 'Marcelo Borges', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Desenvolvedor front-end ex-iFood, especialista em UX de aplicativos.', 'equity_pct': 50, 'name': 'Beatriz Diniz', 'role': 'CTO & Co-fundadora'},
        ],
        'stage': 'operating',
        'tagline': 'A melhor experiência de delivery para restaurantes premium',
        'token_name': 'DG',
        'token_price': 0.40,
        'total_tokens': 5000000,
        'updated_at': new Date('2026-03-10'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Dr. Arthur Mendes', role: 'Mentor Científico'}],
        'capital_raised': 1200000,
        'created_at': new Date('2024-12-01'),
        'description': 'A BioTechBrasil pesquisa e desenvolve implantes ortopédicos biocompatíveis sob medida impressos em 3D, reduzindo o tempo de recuperação cirúrgica e custos de próteses customizadas em até 50%.',
        'executive_summary': 'Próteses customizadas no Brasil são extremamente caras e demoradas para produzir. A BioTechBrasil usa ressonância magnética do paciente para gerar e imprimir próteses cirúrgicas customizadas em menos de 48h. Homologados pela Anvisa para 3 linhas de implantes. Já realizamos 120 cirurgias de sucesso. Receita acumulada de R$ 2.4M no último ano. Buscamos R$ 4.000.000 para expansão da fábrica e exportação para América Latina.',
        'logo_url': 'https://placehold.co/200x200/475569/FFFFFF?text=BT',
        'name': 'BioTechBrasil',
        'partners': [
            {'avatar_url': null, 'bio': 'Doutor em bioengenharia pela Unicamp com 8 anos de pesquisa em novos materiais.', 'equity_pct': 60, 'name': 'Dr. Paulo Nogueira', 'role': 'CEO & Fundador'},
            {'avatar_url': null, 'bio': 'Especialista em manufatura aditiva 3D e otimização de processos industriais.', 'equity_pct': 40, 'name': 'Renato Abreu', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'expanding',
        'tagline': 'Implantes customizados impressos em 3D',
        'token_name': 'BT',
        'token_price': 0.85,
        'total_tokens': 8000000,
        'updated_at': new Date('2026-04-15'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Dra. Márcia Rocha', role: 'Mentora de Segurança da Informação'}],
        'capital_raised': 450000,
        'created_at': new Date('2025-05-18'),
        'description': 'A SecurityShield é uma plataforma de cibersegurança simplificada para pequenas e médias empresas, fornecendo detecção ativa de ameaças, treinamento anti-phishing e conformidade LGPD automatizada.',
        'executive_summary': '80% das PMEs brasileiras sofrem ataques cibernéticos e não possuem equipe de segurança dedicada. A SecurityShield instala um agente inteligente nos endpoints que detecta ameaças em tempo real e simula campanhas de phishing educativas. Temos 280 empresas parceiras ativas, MRR de R$ 95.000 e taxa de retenção de 97%. Buscamos R$ 1.000.000 para ampliar funcionalidades de automação de conformidade.',
        'logo_url': 'https://placehold.co/200x200/1E293B/FFFFFF?text=SS',
        'name': 'SecurityShield',
        'partners': [
            {'avatar_url': null, 'bio': 'Especialista em segurança ofensiva ex-Kryptus e consultor de empresas.', 'equity_pct': 50, 'name': 'Daniel Rocha', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro de computação pelo ITA, ex-desenvolvedor de kernel na Microsoft.', 'equity_pct': 50, 'name': 'Vitor Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Cibersegurança descomplicada para PMEs',
        'token_name': 'SEC',
        'token_price': 0.50,
        'total_tokens': 6500000,
        'updated_at': new Date('2026-02-28'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Dr. Jorge Castro', role: 'Mentor de Logística e Supply Chain'}],
        'capital_raised': 85000,
        'created_at': new Date('2026-01-20'),
        'description': 'A LogiTruck é uma plataforma de logística que conecta transportadores autônomos de caminhão a grandes indústrias, facilitando a negociação de frete direto de forma transparente, ágil e livre de taxas abusivas.',
        'executive_summary': 'O transporte rodoviário de cargas no Brasil sofre com intermediários (agenciadores) que retêm até 30% do valor do frete. A LogiTruck conecta diretamente as partes cobrando uma taxa fixa de apenas 5% do embarcador. Lançada há 3 meses com 350 caminhoneiros cadastrados e R$ 450.000 em fretes intermediados. Buscamos R$ 300.000 para aquisição de usuários e marketing de comunidade.',
        'logo_url': 'https://placehold.co/200x200/B45309/FFFFFF?text=LT',
        'name': 'LogiTruck',
        'partners': [
            {'avatar_url': null, 'bio': 'Formado em administração de empresas, filho de caminhoneiro autônomo.', 'equity_pct': 60, 'name': 'Rodrigo Dias', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Desenvolvedor full-stack especialista em geolocalização e mapas em tempo real.', 'equity_pct': 40, 'name': 'Carlos Lima', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Conectando caminhoneiros e indústrias sem atravessadores',
        'token_name': 'LT',
        'token_price': 0.15,
        'total_tokens': 2000000,
        'updated_at': null,
        'video_url': null,
    },
    {
        'advisors': [{name: 'Dra. Patrícia Diniz', role: 'Mentora de Veterinária e Negócios'}],
        'capital_raised': 300000,
        'created_at': new Date('2025-08-01'),
        'description': 'A PetHealth oferece um plano de saúde pet preventivo baseado em assinatura digital, com rede credenciada de clínicas, reembolso facilitado via aplicativo e telemedicina veterinária 24/7 integrada.',
        'executive_summary': 'O Brasil é o segundo maior mercado pet do mundo, mas menos de 5% dos pets possuem plano de saúde. A PetHealth foca no cuidado preventivo (vacinas, consultas de rotina e exames periódicos), reduzindo custos de tratamentos graves no futuro. Temos 1.800 assinantes ativos e parceria com 80 clínicas veterinárias. MRR de R$ 130.000. Buscamos R$ 800.000 para expansão de vendas corporativas (benefício para colaboradores).',
        'logo_url': 'https://placehold.co/200x200/0D9488/FFFFFF?text=PH',
        'name': 'PetHealth',
        'partners': [
            {'avatar_url': null, 'bio': 'Veterinária e administradora de hospitais pets com 6 anos de experiência.', 'equity_pct': 50, 'name': 'Marina Diniz', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro de software especializado em aplicativos mobile e sistemas de pagamento.', 'equity_pct': 50, 'name': 'Guilherme Ramos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'O melhor plano de saúde preventivo para seu melhor amigo',
        'token_name': 'PH',
        'token_price': 0.30,
        'total_tokens': 4500000,
        'updated_at': new Date('2026-03-05'),
        'video_url': null,
    },
    {
        'advisors': [{name: 'Prof. Marcos Silveira', role: 'Mentor de Inteligência Artificial'}],
        'capital_raised': 2000000,
        'created_at': new Date('2024-10-10'),
        'description': 'A AIContent é uma plataforma SaaS que automatiza a geração de conteúdo de marketing localizado e anúncios inteligentes em redes sociais para pequenos e médios varejistas locais usando modelos de IA adaptativos.',
        'executive_summary': 'Pequenos comércios não têm orçamento para agências de marketing mas precisam de presença digital. A AIContent cria imagens, vídeos curtos e copies de alta conversão adaptados ao perfil do comércio local em segundos. Temos 1.400 clientes SaaS ativos, faturamento recorrente anual (ARR) de R$ 1.8M e crescimento consistente. Buscamos R$ 5.000.000 para desenvolvimento de IA geradora de vídeos hiper-personalizados.',
        'logo_url': 'https://placehold.co/200x200/7C3AED/FFFFFF?text=AC',
        'name': 'AIContent',
        'partners': [
            {'avatar_url': null, 'bio': 'Ex-diretor de marketing de grandes e-commerces, especialista em growth hacking.', 'equity_pct': 45, 'name': 'Julio Silveira', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Pesquisador em aprendizado profundo com foco em processamento de imagens e linguagem natural.', 'equity_pct': 35, 'name': 'Sandra Ramos', 'role': 'CTO & Co-automática'},
            {'avatar_url': null, 'bio': 'Designer com foco em UX e interfaces para ferramentas criativas de IA.', 'equity_pct': 20, 'name': 'Karina Lima', 'role': 'CPO & Co-fundadora'},
        ],
        'stage': 'expanding',
        'tagline': 'Geração de conteúdo inteligente para negócios locais',
        'token_name': 'AC',
        'token_price': 1.05,
        'total_tokens': 12000000,
        'updated_at': new Date('2026-04-20'),
        'video_url': null,
    },
];

const extraStartups: RawStartup[] = [
    // 21
    {
        'advisors': [{name: 'Dr. Fernando Dias', role: 'Mentor de Fitness'}],
        'capital_raised': 45000,
        'created_at': new Date('2026-03-01'),
        'description': 'A FitLife é uma plataforma digital que conecta personal trainers a alunos para treinos personalizados presenciais ou remotos, com gamificação e planos corporativos de saúde.',
        'executive_summary': 'O mercado de saúde pós-pandemia cresceu 40%. A FitLife resolve a falta de engajamento em treinos e a captação de clientes para profissionais. Com 150 personal trainers ativos e 800 alunos, faturamos R$ 45.000 mensais em assinaturas. Buscamos R$ 200.000 para marketing e expansão de vendas B2B.',
        'logo_url': 'https://placehold.co/200x200/F43F5E/FFFFFF?text=FL',
        'name': 'FitLife',
        'partners': [
            {'avatar_url': null, 'bio': 'Educadora física e pós-graduada em gestão esportiva.', 'equity_pct': 60, 'name': 'Renata Albuquerque', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Desenvolvedor mobile e entusiasta de corrida de rua.', 'equity_pct': 40, 'name': 'Eduardo Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Sua saúde e treinos em um só lugar',
        'token_name': 'FIT',
        'token_price': 0.10,
        'total_tokens': 1500000,
        'updated_at': null,
        'video_url': null,
    },
    // 22
    {
        'advisors': [{name: 'Prof. Dr. Marcos Linhares', role: 'Mentor de Criptografia'}],
        'capital_raised': 850000,
        'created_at': new Date('2025-05-15'),
        'description': 'A SafeVault é uma plataforma de custódia e criptografia avançada de ativos digitais e segredos corporativos em nuvem híbrida, garantindo conformidade com rígidos padrões internacionais.',
        'executive_summary': 'Segurança de chaves e dados sensíveis é o maior desafio na nuvem. A SafeVault oferece módulos HSM virtuais e criptografia de chaves. Atendemos 45 empresas de finanças, com receita recorrente mensal de R$ 90.000. Buscamos R$ 2.000.000 para obter certificações internacionais FIPS.',
        'logo_url': 'https://placehold.co/200x200/0F172A/FFFFFF?text=SV',
        'name': 'SafeVault',
        'partners': [
            {'avatar_url': null, 'bio': 'Doutor em segurança de redes ex-militar e consultor de grandes corporações.', 'equity_pct': 50, 'name': 'Daniel Linhares', 'role': 'CEO & Fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro de software e arquiteto de sistemas distribuídos.', 'equity_pct': 50, 'name': 'Rafael Dias', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Custódia de nível institucional para seus segredos',
        'token_name': 'SAFE',
        'token_price': 0.60,
        'total_tokens': 5000000,
        'updated_at': new Date('2026-03-25'),
        'video_url': null,
    },
    // 23
    {
        'advisors': [{name: 'Dra. Luiza Castro', role: 'Mentora de PropTech'}],
        'capital_raised': 1100000,
        'created_at': new Date('2025-02-10'),
        'description': 'A ImobiDigital tokeniza propriedades físicas reais para investimentos fracionados de imóveis no Brasil, democratizando o acesso ao mercado imobiliário com retornos de aluguel em tempo real.',
        'executive_summary': 'Investir em imóveis no Brasil exige alto capital. A ImobiDigital divide prédios residenciais em tokens negociáveis a partir de R$ 100. Temos 8 empreendimentos tokenizados no portfólio e mais de 2.000 investidores ativos. Buscamos R$ 3.000.000 para expandir para imóveis comerciais.',
        'logo_url': 'https://placehold.co/200x200/10B981/FFFFFF?text=ID',
        'name': 'ImobiDigital',
        'partners': [
            {'avatar_url': null, 'bio': 'Especialista em fusões e aquisições com 10 anos de mercado imobiliário.', 'equity_pct': 55, 'name': 'Roberto Castro', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro de blockchain focado em contratos inteligentes.', 'equity_pct': 45, 'name': 'Gabriel Souza', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'expanding',
        'tagline': 'Investimento imobiliário a partir de R$ 100',
        'token_name': 'IMOB',
        'token_price': 0.80,
        'total_tokens': 6000000,
        'updated_at': new Date('2026-04-12'),
        'video_url': null,
    },
    // 24
    {
        'advisors': [{name: 'Eng. Ricardo Silveira', role: 'Mentor de Biocombustíveis'}],
        'capital_raised': 90000,
        'created_at': new Date('2026-01-20'),
        'description': 'A AutoGás é uma cleantech focada na conversão de frotas de veículos pesados comerciais para combustão híbrida com biometano, gerando economia financeira e redução imediata de emissões poluentes.',
        'executive_summary': 'O transporte rodoviário emite milhões de toneladas de CO₂. Nossa conversão reduz os custos com diesel em até 30%. Temos 3 contratos corporativos para converter 45 caminhões e ônibus. Buscamos R$ 400.000 para instalar nosso próprio posto de conversão.',
        'logo_url': 'https://placehold.co/200x200/84CC16/FFFFFF?text=AG',
        'name': 'AutoGás',
        'partners': [
            {'avatar_url': null, 'bio': 'Mestre em engenharia mecânica pela USP, ex-diretor de montadora.', 'equity_pct': 60, 'name': 'Renato Silveira', 'role': 'CEO & Fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro mecânico especializado em adaptação de motores pesados.', 'equity_pct': 40, 'name': 'Hugo Lima', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Conversão inteligente de frotas para biometano',
        'token_name': 'GAS',
        'token_price': 0.15,
        'total_tokens': 2000000,
        'updated_at': null,
        'video_url': null,
    },
    // 25
    {
        'advisors': [{name: 'Marcos Prado', role: 'Mentor de Recursos Humanos'}],
        'capital_raised': 180000,
        'created_at': new Date('2025-11-05'),
        'description': 'A FastWork é um aplicativo de contratação sob demanda de profissionais freelancers qualificados e validados para eventos, hotéis e comércios temporários com seguro integrado.',
        'executive_summary': 'A escassez de mão de obra temporária prejudica o varejo. A FastWork conecta candidatos validados em minutos. Em 6 meses, intermediamos 3.500 contratações com NPS de 88. Modelo de negócios: cobrança de 15% sobre o valor da diária. Buscamos R$ 600.000 para expandir para capitais do Sul.',
        'logo_url': 'https://placehold.co/200x200/4F46E5/FFFFFF?text=FW',
        'name': 'FastWork',
        'partners': [
            {'avatar_url': null, 'bio': 'Especialista em RH com pós-graduação em psicologia organizacional.', 'equity_pct': 50, 'name': 'Simone Prado', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro de software full-stack ex-Loggi.', 'equity_pct': 50, 'name': 'Carlos Abreu', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Contrate freelancers qualificados em minutos',
        'token_name': 'WORK',
        'token_price': 0.25,
        'total_tokens': 3000000,
        'updated_at': new Date('2026-02-15'),
        'video_url': null,
    },
    // 26
    {
        'advisors': [{name: 'Dra. Clara Campos', role: 'Mentora de Veterinária'}],
        'capital_raised': 95000,
        'created_at': new Date('2026-02-05'),
        'description': 'A PetHotel oferece uma rede de hospedagem residencial pet compartilhada baseada em aplicativo, com cuidadores certificados, seguro saúde e monitoramento por câmeras 24 horas.',
        'executive_summary': 'Hotéis para pet tradicionais são frios e caros. A PetHotel conecta tutores a cuidadores que hospedam os animais em casa. Temos 400 cuidadores cadastrados no estado de SP e receita de R$ 30.000 por mês. Buscamos R$ 250.000 para ampliar as campanhas de marketing de confiança.',
        'logo_url': 'https://placehold.co/200x200/06B6D4/FFFFFF?text=PH',
        'name': 'PetHotel',
        'partners': [
            {'avatar_url': null, 'bio': 'Administradora e mãe de 3 pets, ex-gerente comercial.', 'equity_pct': 60, 'name': 'Mariana Campos', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro front-end apaixonado por animais.', 'equity_pct': 40, 'name': 'Victor Prado', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Hospedagem pet afetiva com segurança',
        'token_name': 'PET',
        'token_price': 0.12,
        'total_tokens': 1000000,
        'updated_at': null,
        'video_url': null,
    },
    // 27
    {
        'advisors': [{name: 'Eng. Maurício Santos', role: 'Mentor de Tecnologia de Saneamento'}],
        'capital_raised': 1300000,
        'created_at': new Date('2024-09-01'),
        'description': 'A AquaTech é uma startup que fornece sensores IoT de monitoramento em tempo real da qualidade de rios, lagos e efluentes industriais para governos e indústrias em conformidade ESG.',
        'executive_summary': 'Desastres ambientais causam multas bilionárias. O sensor AquaTech mede pH, turbidez e presença de poluentes, enviando alertas em tempo real. Atendemos 3 governos estaduais e 12 grandes indústrias químicas. Receita anual de R$ 2.1M. Buscamos R$ 4.000.000 para exportação para a Europa.',
        'logo_url': 'https://placehold.co/200x200/0EA5E9/FFFFFF?text=AT',
        'name': 'AquaTech',
        'partners': [
            {'avatar_url': null, 'bio': 'Engenheiro químico ex-Sabesp com MBA na FGV.', 'equity_pct': 50, 'name': 'Paulo Santos', 'role': 'CEO & Fundador'},
            {'avatar_url': null, 'bio': 'Especialista em IoT e comunicações sem fio de longa distância.', 'equity_pct': 50, 'name': 'Luiz Ramos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'expanding',
        'tagline': 'Monitoramento hídrico inteligente e em tempo real',
        'token_name': 'AQUA',
        'token_price': 0.90,
        'total_tokens': 8000000,
        'updated_at': new Date('2026-04-18'),
        'video_url': null,
    },
    // 28
    {
        'advisors': [{name: 'Dra. Patrícia Abreu', role: 'Mentora de Educação'}],
        'capital_raised': 85000,
        'created_at': new Date('2026-01-10'),
        'description': 'A DevAcademy é um bootcamp intensivo em programação com foco em jovens de baixa renda, em modelo ISA (Income Share Agreement) onde os alunos só pagam após estarem empregados.',
        'executive_summary': 'O mercado de TI tem falta de talentos, e cursos particulares são inacessíveis. A DevAcademy forma devs full-stack prontos para o mercado em 6 meses. Primeira turma piloto com 35 alunos atingiu 92% de empregabilidade. Buscamos R$ 300.000 para infraestrutura e contratação de mentores.',
        'logo_url': 'https://placehold.co/200x200/7C3AED/FFFFFF?text=DA',
        'name': 'DevAcademy',
        'partners': [
            {'avatar_url': null, 'bio': 'Pedagogo especializado em metodologias de ensino ativo e tecnologia.', 'equity_pct': 55, 'name': 'Gustavo Abreu', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro de software sênior ex-Stone com foco em mentoria.', 'equity_pct': 45, 'name': 'Renan Barbosa', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Bootcamps de programação sem mensalidade inicial',
        'token_name': 'DEV',
        'token_price': 0.12,
        'total_tokens': 2000000,
        'updated_at': null,
        'video_url': null,
    },
    // 29
    {
        'advisors': [{name: 'Eng. André Azevedo', role: 'Mentor de Mobilidade'}],
        'capital_raised': 950000,
        'created_at': new Date('2025-06-01'),
        'description': 'A CarShare é uma plataforma B2C e B2B de compartilhamento de carros elétricos urbanos por minuto, com frotas distribuídas em pontos estratégicos de São Paulo, integrados com hubs de transporte.',
        'executive_summary': 'Carros particulares passam 95% do tempo estacionados. A CarShare oferece mobilidade sustentável sem a necessidade de posse. Frota atual de 40 veículos elétricos próprios, com taxa de utilização diária de 65%. Faturamento mensal de R$ 140.000. Buscamos R$ 2.500.000 para duplicar a frota.',
        'logo_url': 'https://placehold.co/200x200/10B981/FFFFFF?text=CS',
        'name': 'CarShare',
        'partners': [
            {'avatar_url': null, 'bio': 'Especialista em mobilidade e investimentos corporativos ex-Uber.', 'equity_pct': 50, 'name': 'Juliana Azevedo', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro de controle e automação ex-Embraer.', 'equity_pct': 50, 'name': 'Felipe Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Compartilhamento de carros elétricos urbanos por minuto',
        'token_name': 'CAR',
        'token_price': 0.70,
        'total_tokens': 6000000,
        'updated_at': new Date('2026-03-01'),
        'video_url': null,
    },
    // 30
    {
        'advisors': [{name: 'Chef Henrique Fogaça', role: 'Mentor Gastronômico'}],
        'capital_raised': 110000,
        'created_at': new Date('2025-10-12'),
        'description': 'A FoodSave é um marketplace B2B e B2C que conecta restaurantes, padarias e supermercados diretamente a consumidores interessados em comprar produtos excedentes de qualidade com até 70% de desconto.',
        'executive_summary': '1/3 dos alimentos produtos no mundo são desperdiçados. A FoodSave cria sacolas surpresa com alimentos excedentes que seriam descartados ao fim do dia. Já salvamos mais de 12.000 refeições em 4 meses em SP. Receita mensal de R$ 28.000. Buscamos R$ 400.000 para expandir para Curitiba.',
        'logo_url': 'https://placehold.co/200x200/F59E0B/FFFFFF?text=FS',
        'name': 'FoodSave',
        'partners': [
            {'avatar_url': null, 'bio': 'Empreendedora com foco em sustentabilidade e negócios ESG.', 'equity_pct': 60, 'name': 'Gabriela Barbosa', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Desenvolvedor full-stack focado em mercados e geolocalização.', 'equity_pct': 40, 'name': 'Mateus Souza', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Economize comida, economize seu dinheiro',
        'token_name': 'SAVE',
        'token_price': 0.30,
        'total_tokens': 3000000,
        'updated_at': new Date('2026-01-10'),
        'video_url': null,
    },
    // 31
    {
        'advisors': [{name: 'Dra. Alice Ribeiro', role: 'Mentora de LegalTech'}],
        'capital_raised': 60000,
        'created_at': new Date('2026-02-18'),
        'description': 'A SignDoc permite a assinatura digital de contratos e documentos jurídicos usando contratos inteligentes baseados em rede blockchain privada de baixo custo, garantindo integridade e rastreabilidade total.',
        'executive_summary': 'Fraude documental custa milhões a empresas brasileiras. A SignDoc resolve isso gerando chaves públicas em blockchain. 35 escritórios parceiros integrados com NPS de 90. Buscamos R$ 250.000 para ampliar as integrações com APIs governamentais.',
        'logo_url': 'https://placehold.co/200x200/3B82F6/FFFFFF?text=SD',
        'name': 'SignDoc',
        'partners': [
            {'avatar_url': null, 'bio': 'Advogada e especialista em direito digital e privacidade.', 'equity_pct': 55, 'name': 'Aline Ribeiro', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro de criptografia ex-desenvolvedor de banco de dados.', 'equity_pct': 45, 'name': 'Lucas Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Assinaturas digitais blindadas por blockchain',
        'token_name': 'SIGN',
        'token_price': 0.14,
        'total_tokens': 1500000,
        'updated_at': null,
        'video_url': null,
    },
    // 32
    {
        'advisors': [{name: 'Prof. Fabio Souza', role: 'Mentor de Realidade Virtual'}],
        'capital_raised': 1400000,
        'created_at': new Date('2024-11-15'),
        'description': 'A MetaStore é uma plataforma de e-commerce e customização de ativos 3D e roupas digitais em realidade aumentada para avatares de jogos e metaversos corporativos.',
        'executive_summary': 'O comércio de ativos digitais movimenta bilhões mundialmente. A MetaStore fornece um estúdio de criação para designers independentes e marcas de luxo venderem ativos 3D. 8 grandes marcas parceiras e R$ 180.000 de GMV mensal. Buscamos R$ 4.000.000 para operações nos EUA.',
        'logo_url': 'https://placehold.co/200x200/EC4899/FFFFFF?text=MS',
        'name': 'MetaStore',
        'partners': [
            {'avatar_url': null, 'bio': 'Designer 3D ex-diretor criativo de estúdio de animação.', 'equity_pct': 50, 'name': 'Daniel Souza', 'role': 'CEO & Fundador'},
            {'avatar_url': null, 'bio': 'Especialista em renderização web3 e computação gráfica.', 'equity_pct': 50, 'name': 'Roberto Lima', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'expanding',
        'tagline': 'O futuro do e-commerce digital em 3D',
        'token_name': 'META',
        'token_price': 1.15,
        'total_tokens': 9000000,
        'updated_at': new Date('2026-04-20'),
        'video_url': null,
    },
    // 33
    {
        'advisors': [{name: 'Eng. Fernando Gomes', role: 'Mentor de Engenharia Solar'}],
        'capital_raised': 200000,
        'created_at': new Date('2025-07-20'),
        'description': 'A SolarRoof é uma fintech de financiamento coletivo e parcelamento acessível voltada para viabilizar painéis solares residenciais para famílias de classe média.',
        'executive_summary': 'O custo de instalação de energia solar é o principal obstáculo. Oferecemos crédito flexível em até 60x cobrindo o custo total. 180 casas já instaladas e portfólio de recebíveis com inadimplência zero. Buscamos R$ 1.000.000 para securitizar nossa carteira e ampliar vendas.',
        'logo_url': 'https://placehold.co/200x200/EAB308/FFFFFF?text=SR',
        'name': 'SolarRoof',
        'partners': [
            {'avatar_url': null, 'bio': 'Financista ex-Banco do Brasil especialista em microcrédito.', 'equity_pct': 50, 'name': 'Fernanda Gomes', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro mecânico solar com foco em modelagem financeira de economia de energia.', 'equity_pct': 50, 'name': 'Thiago Souza', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Financiamento simplificado para energia solar residencial',
        'token_name': 'ROOF',
        'token_price': 0.35,
        'total_tokens': 4000000,
        'updated_at': new Date('2026-01-15'),
        'video_url': null,
    },
    // 34
    {
        'advisors': [{name: 'Dra. Carla Ramos', role: 'Mentora de Psicopedagogia'}],
        'capital_raised': 75000,
        'created_at': new Date('2026-02-01'),
        'description': 'A NeuroMind é um ecossistema de acompanhamento multidisciplinar com jogos neurocientíficos e suporte para pessoas com TDAH e dislexia no ambiente escolar.',
        'executive_summary': 'O diagnóstico de transtornos de aprendizado aumentou consideravelmente. Nossos jogos melhoram o foco e o monitoramento escolar. Operamos piloto com 120 crianças com engajamento diário de 82%. Buscamos R$ 300.000 para ampliar as funcionalidades do app para pais.',
        'logo_url': 'https://placehold.co/200x200/8B5CF6/FFFFFF?text=NM',
        'name': 'NeuroMind',
        'partners': [
            {'avatar_url': null, 'bio': 'Psicóloga com especialização em neurociência comportamental.', 'equity_pct': 60, 'name': 'Dra. Amanda Ramos', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Desenvolvedor focado em jogos sérios e gamificação na saúde.', 'equity_pct': 40, 'name': 'Carlos Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Jogos neurocientíficos para focar e evoluir',
        'token_name': 'MIND',
        'token_price': 0.11,
        'total_tokens': 2000000,
        'updated_at': null,
        'video_url': null,
    },
    // 35
    {
        'advisors': [{name: 'Dra. Marina Abreu', role: 'Mentora de Embalagens Sustentáveis'}],
        'capital_raised': 950000,
        'created_at': new Date('2025-04-10'),
        'description': 'A BioPack produz e vende embalagens industriais biodegradáveis feitas de amido de mandioca que se dissolvem na água em segundos, substituindo plásticos descartáveis no e-commerce.',
        'executive_summary': 'O descarte de embalagens plásticas é um pesadelo ambiental. A BioPack fabrica sacolas e envelopes ecológicos resistentes. Atendemos 85 marcas de e-commerce e faturamos R$ 160.000/mês. Buscamos R$ 3.000.000 para construir nossa segunda planta de extrusão de amido.',
        'logo_url': 'https://placehold.co/200x200/10B981/FFFFFF?text=BP',
        'name': 'BioPack',
        'partners': [
            {'avatar_url': null, 'bio': 'Doutor em engenharia de materiais pela USP com patentes na área de bioplásticos.', 'equity_pct': 60, 'name': 'Dr. Marcos Abreu', 'role': 'CEO & Fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro de produção com especialização em automação industrial.', 'equity_pct': 40, 'name': 'Renato Lima', 'role': 'COO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Embalagens ecológicas de mandioca para e-commerce',
        'token_name': 'BIOP',
        'token_price': 0.45,
        'total_tokens': 5000000,
        'updated_at': new Date('2026-03-20'),
        'video_url': null,
    },
    // 36
    {
        'advisors': [{name: 'Dr. Lucas Silveira', role: 'Mentor de Direito Tributário'}],
        'capital_raised': 55000,
        'created_at': new Date('2026-03-10'),
        'description': 'A LegalDrive é uma plataforma SaaS de contabilidade e segurança jurídica para motoristas de aplicativos e entregadores, simplificando emissão de MEI, controle de despesas e benefícios.',
        'executive_summary': 'Motoristas de aplicativos enfrentam burocracia e insegurança financeira. Oferecemos assessoria contábil por R$ 29/mês. 1.200 motoristas ativos em São Paulo. Faturamento mensal de R$ 35.000. Buscamos R$ 200.000 para desenvolver ferramenta de antecipação de diárias.',
        'logo_url': 'https://placehold.co/200x200/1E293B/FFFFFF?text=LD',
        'name': 'LegalDrive',
        'partners': [
            {'avatar_url': null, 'bio': 'Contabilista com pós-graduação em finanças de negócios informais.', 'equity_pct': 60, 'name': 'Lucas Silveira', 'role': 'CEO & Fundador'},
            {'avatar_url': null, 'bio': 'Desenvolvedor front-end com foco em interfaces móveis simples.', 'equity_pct': 40, 'name': 'Rafael Dias', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Sua contabilidade e MEI como motorista simplificados',
        'token_name': 'DRIV',
        'token_price': 0.08,
        'total_tokens': 1500000,
        'updated_at': null,
        'video_url': null,
    },
    // 37
    {
        'advisors': [{name: 'Dr. Thiago Medeiros', role: 'Mentor Tributário'}],
        'capital_raised': 350000,
        'created_at': new Date('2025-08-01'),
        'description': 'A EasyTax é uma plataforma inteligente que automatiza o preenchimento, cálculo e entrega de impostos e obrigações fiscais para micro e pequenas empresas optantes pelo Simples Nacional.',
        'executive_summary': 'O sistema tributário brasileiro é o mais complexo do mundo. O EasyTax integra-se ao emissor de notas fiscais do cliente e gera as guias mensais automaticamente. 450 empresas clientes. Receita recorrente mensal de R$ 75.000. Buscamos R$ 1.200.000 para desenvolver inteligência tributária para lucro presumido.',
        'logo_url': 'https://placehold.co/200x200/64748B/FFFFFF?text=ET',
        'name': 'EasyTax',
        'partners': [
            {'avatar_url': null, 'bio': 'Advogado tributarista com MBA em gestão fiscal de empresas.', 'equity_pct': 50, 'name': 'Thiago Medeiros', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro de dados especializado em integrações governamentais.', 'equity_pct': 50, 'name': 'Felipe Silva', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Automatize o cálculo de impostos do Simples Nacional',
        'token_name': 'TAX',
        'token_price': 0.38,
        'total_tokens': 4500000,
        'updated_at': new Date('2026-03-05'),
        'video_url': null,
    },
    // 38
    {
        'advisors': [{name: 'Profa. Regina Barros', role: 'Mentora de Pedagogia Crítica'}],
        'capital_raised': 1150000,
        'created_at': new Date('2024-10-01'),
        'description': 'A VRClass desenvolve laboratórios de biologia, química e física em realidade virtual imersiva para escolas de ensino fundamental e médio, reduzindo custos de instalação e material.',
        'executive_summary': 'Escolas públicas e particulares raramente possuem laboratórios equipados. O VRClass fornece óculos VR com 45 simulações experimentais alinhadas à BNCC. 42 escolas parceiras e mais de 15.000 alunos impactados. Faturamento anual de R$ 1.8M. Buscamos R$ 3.000.000 para expandir para América Latina.',
        'logo_url': 'https://placehold.co/200x200/A855F7/FFFFFF?text=VR',
        'name': 'VRClass',
        'partners': [
            {'avatar_url': null, 'bio': 'Professor de física e designer educacional com experiência em realidade virtual.', 'equity_pct': 55, 'name': 'Reginaldo Barros', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Desenvolvedor de jogos 3D e mestre em computação gráfica pela Unicamp.', 'equity_pct': 45, 'name': 'Bruno Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'expanding',
        'tagline': 'Laboratórios de ciências virtuais de alto impacto',
        'token_name': 'VRC',
        'token_price': 0.95,
        'total_tokens': 8000000,
        'updated_at': new Date('2026-04-10'),
        'video_url': null,
    },
    // 39
    {
        'advisors': [{name: 'Eng. Ricardo Dias', role: 'Mentor de Portarias Inteligentes'}],
        'capital_raised': 420000,
        'created_at': new Date('2025-07-15'),
        'description': 'A SmartCondo oferece um SaaS de controle de acesso, portaria virtual autônoma com reconhecimento facial e aplicativo de comunicação interna para condomínios residenciais.',
        'executive_summary': 'A portaria consome até 60% do orçamento de um condomínio. A SmartCondo reduz esse custo em 70% com nossa IA de reconhecimento facial e totem inteligente. 110 condomínios ativos no estado de SP. Receita recorrente mensal de R$ 115.000. Buscamos R$ 1.500.000 para escalar produção de totens proprietários.',
        'logo_url': 'https://placehold.co/200x200/F59E0B/FFFFFF?text=SC',
        'name': 'SmartCondo',
        'partners': [
            {'avatar_url': null, 'bio': 'Empreendedor com 8 honors de experiência em segurança privada.', 'equity_pct': 60, 'name': 'Rodrigo Dias', 'role': 'CEO & Fundador'},
            {'avatar_url': null, 'bio': 'Desenvolvedor full-stack especialista em algoritmos de visão computacional.', 'equity_pct': 40, 'name': 'Claudio Abreu', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'SaaS e totens inteligentes de portaria virtual',
        'token_name': 'CONDO',
        'token_price': 0.52,
        'total_tokens': 6000000,
        'updated_at': new Date('2026-02-28'),
        'video_url': null,
    },
    // 40
    {
        'advisors': [{name: 'Dra. Simone Silva', role: 'Mentora de Engenharia Reversa'}],
        'capital_raised': 70000,
        'created_at': new Date('2026-02-10'),
        'description': 'A ReciclaEletro atua na logística reversa e reciclagem especializada de resíduos eletroeletrônicos, coletando materiais e extraindo metais preciosos para venda B2B.',
        'executive_summary': 'O lixo eletrônico cresce 5x mais rápido que outros resíduos. A ReciclaEletro coleta eletrônicos descartados em condomínios e empresas e realiza a triagem e refino. 40 pontos de coleta instalados em BH. Receita mensal de R$ 18.000. Buscamos R$ 300.000 para instalar forno de fundição ecológico.',
        'logo_url': 'https://placehold.co/200x200/10B981/FFFFFF?text=RE',
        'name': 'ReciclaEletro',
        'partners': [
            {'avatar_url': null, 'bio': 'Química ambiental com 5 anos de atuação em engenharia reversa de materiais.', 'equity_pct': 60, 'name': 'Simone Silva', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Especialista em supply chain e logística de resíduos.', 'equity_pct': 40, 'name': 'Marcos Lima', 'role': 'COO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Logística reversa e reciclagem de lixo eletrônico',
        'token_name': 'ELET',
        'token_price': 0.08,
        'total_tokens': 2000000,
        'updated_at': null,
        'video_url': null,
    },
    // 41
    {
        'advisors': [{name: 'Eng. Carlos Ramos', role: 'Mentor de Energias Renováveis'}],
        'capital_raised': 95000,
        'created_at': new Date('2026-01-05'),
        'description': 'A VentoNorte desenvolve e comercializa aerogeradores residenciais e comerciais de eixo vertical compactos e de alta eficiência, ideais para áreas urbanas e propriedades rurais.',
        'executive_summary': 'A energia solar residencial é popular, mas a eólica residencial é um mercado inexplorado. Nossos geradores de eixo vertical geram energia mesmo com ventos fracos de qualquer direção. Lançamos piloto com 15 geradores ativos no Nordeste com ótimos resultados. Buscamos R$ 400.000 para obter certificações nacionais.',
        'logo_url': 'https://placehold.co/200x200/0284C7/FFFFFF?text=VN',
        'name': 'VentoNorte',
        'partners': [
            {'avatar_url': null, 'bio': 'Doutorando em engenharia mecânica especialista em aerodinâmica.', 'equity_pct': 55, 'name': 'Carlos Ramos', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro de manufatura focado em materiais compostos leves.', 'equity_pct': 45, 'name': 'Douglas Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Minigeradores eólicos de eixo vertical para cidades',
        'token_name': 'VEN',
        'token_price': 0.12,
        'total_tokens': 1500000,
        'updated_at': null,
        'video_url': null,
    },
    // 42
    {
        'advisors': [{name: 'Prof. Pedro Diniz', role: 'Mentor de Inteligência Artificial Conversacional'}],
        'capital_raised': 980000,
        'created_at': new Date('2025-05-20'),
        'description': 'A ShopBot desenvolve agentes virtuais de inteligência artificial conversacional inteligentes integrados a canais de e-commerce e WhatsApp para vendas autônomas e suporte complexo.',
        'executive_summary': 'Atendimento no e-commerce perde 40% de conversão por lentidão. O ShopBot integra IA para guiar o cliente até o pagamento direto no WhatsApp. 180 e-commerces clientes no Brasil. MRR de R$ 90.000 e churn de 2%. Buscamos R$ 2.000.000 para integrar com principais gateways e expandir vendas.',
        'logo_url': 'https://placehold.co/200x200/4F46E5/FFFFFF?text=SB',
        'name': 'ShopBot',
        'partners': [
            {'avatar_url': null, 'bio': 'Ex-gerente de produtos de e-commerce com experiência em plataformas globais.', 'equity_pct': 50, 'name': 'Renan Prado', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Desenvolvedor especialista em processamento de linguagem natural e LLMs.', 'equity_pct': 50, 'name': 'Guilherme Ramos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'IA conversacional para automação de vendas no WhatsApp',
        'token_name': 'SHOP',
        'token_price': 0.65,
        'total_tokens': 6000000,
        'updated_at': new Date('2026-03-10'),
        'video_url': null,
    },
    // 43
    {
        'advisors': [{name: 'Dra. Marina Diniz', role: 'Mentora de Políticas de Saúde'}],
        'capital_raised': 12000,
        'created_at': new Date('2025-09-01'),
        'description': 'O MedCard é um cartão de descontos e agendamento de consultas médicas e exames em clínicas populares parceiras, focado na população sem plano de saúde tradicional.',
        'executive_summary': '70% dos brasileiros não possuem plano de saúde. O MedCard cobra uma mensalidade de R$ 19,90 e garante descontos de até 60% em exames e consultas rápidas. 3.200 associados ativos e parceria com 45 clínicas médicas. Buscamos R$ 500.000 para lançar aplicativo de telemedicina própria.',
        'logo_url': 'https://placehold.co/200x200/EF4444/FFFFFF?text=MC',
        'name': 'MedCard',
        'partners': [
            {'avatar_url': null, 'bio': 'Médico cardiologista que atuou 8 anos no SUS e em clínicas populares.', 'equity_pct': 60, 'name': 'Dr. Marcos Diniz', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Administradora de redes de clínicas com experiência em expansão comercial.', 'equity_pct': 40, 'name': 'Karina Ramos', 'role': 'COO & Co-fundadora'},
        ],
        'stage': 'operating',
        'tagline': 'Acesso rápido e econômico a consultas e exames',
        'token_name': 'CARD',
        'token_price': 0.22,
        'total_tokens': 3000000,
        'updated_at': new Date('2026-01-20'),
        'video_url': null,
    },
    // 44
    {
        'advisors': [{name: 'Eng. Paulo Castro', role: 'Mentor de Drones Agrícolas'}],
        'capital_raised': 85000,
        'created_at': new Date('2026-02-01'),
        'description': 'A AgroDrone fornece serviços sob demanda de pulverização e mapeamento de precisão de lavouras utilizando drones agrícolas de grande porte para médios produtores.',
        'executive_summary': 'Pulverização por trator amassa a lavoura, gerando perdas de até 4%. Nossos drones reduzem desperdício de defensivos e evitam perdas. 45 produtores atendidos na safra atual. Faturamento acumulado de R$ 120.000. Buscamos R$ 350.000 para adquirir mais 3 drones pesados e expandir frota.',
        'logo_url': 'https://placehold.co/200x200/16A34A/FFFFFF?text=AD',
        'name': 'AgroDrone',
        'partners': [
            {'avatar_url': null, 'bio': 'Agrônomo com pós-graduação em agricultura digital de precisão.', 'equity_pct': 55, 'name': 'Paulo Castro', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Piloto de testes de drones certificado e engenheiro eletricista.', 'equity_pct': 45, 'name': 'Vitor Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Pulverização e mapeamento agrícola com drones de alta performance',
        'token_name': 'DRON',
        'token_price': 0.15,
        'total_tokens': 2000000,
        'updated_at': null,
        'video_url': null,
    },
    // 45
    {
        'advisors': [{name: 'Dra. Juliana Prado', role: 'Mentora de Negócios Colaborativos'}],
        'capital_raised': 320000,
        'created_at': new Date('2025-07-01'),
        'description': 'A RentEasy é uma plataforma de aluguel por dia de ferramentas elétricas, equipamentos de limpeza, jardinagem e acampamento, baseada no conceito de economia compartilhada.',
        'executive_summary': 'Consumidores gastam fortunas com ferramentas que usam uma vez ao ano. O RentEasy oferece aluguel simples via aplicativo com entrega expressa. 850 locações mensais em SP e faturamento de R$ 55.000. Buscamos R$ 1.000.000 para instalar totens de retirada em shopping centers.',
        'logo_url': 'https://placehold.co/200x200/06B6D4/FFFFFF?text=RE',
        'name': 'RentEasy',
        'partners': [
            {'avatar_url': null, 'bio': 'Administrador com MBA com foco em supply chain e consumo inteligente.', 'equity_pct': 50, 'name': 'Julio Prado', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Desenvolvedor móvel com experiência em sistemas de inventário complexos.', 'equity_pct': 50, 'name': 'Diego Lima', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Aluguel fácil de ferramentas e equipamentos por dia',
        'token_name': 'RENT',
        'token_price': 0.32,
        'total_tokens': 4000000,
        'updated_at': new Date('2026-03-10'),
        'video_url': null,
    },
    // 46
    {
        'advisors': [{name: 'Eng. Ricardo Mello', role: 'Mentor de Logística Portuária'}],
        'capital_raised': 1600000,
        'created_at': new Date('2024-09-01'),
        'description': 'A CargoMap desenvolve sistemas de rastreamento inteligente, segurança e monitoramento de contêineres marítimos e rodoviários utilizando sensores IoT ativos.',
        'executive_summary': 'Roubo de carga e perdas por quebra de temperatura causam prejuízos bilionários à indústria. Nosso dispositivo IoT envia localização e status de temperatura em tempo real. Rastreando mais de 5.000 cargas ativas por mês. Faturamento anual de R$ 2.4M. Buscamos R$ 5.000.000 para expansão global.',
        'logo_url': 'https://placehold.co/200x200/EA580C/FFFFFF?text=CM',
        'name': 'CargoMap',
        'partners': [
            {'avatar_url': null, 'bio': 'Especialista em exportações e comércio exterior com 12 anos de atuação.', 'equity_pct': 45, 'name': 'Roberto Mello', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Engenheiro de IoT e redes de sensores sem fio de longa distância.', 'equity_pct': 35, 'name': 'Claudio Dias', 'role': 'CTO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Diretor de vendas corporativas com passagens por transportadoras.', 'equity_pct': 20, 'name': 'Karina Souza', 'role': 'CSO & Co-fundadora'},
        ],
        'stage': 'expanding',
        'tagline': 'Sensores IoT de rastreamento ativo e temperatura de contêineres',
        'token_name': 'CMAP',
        'token_price': 1.10,
        'total_tokens': 10000000,
        'updated_at': new Date('2026-04-20'),
        'video_url': null,
    },
    // 47
    {
        'advisors': [{name: 'Dr. Fernando Barros', role: 'Mentor de Soluções de Pagamento'}],
        'capital_raised': 350000,
        'created_at': new Date('2025-06-15'),
        'description': 'A PayFacil é uma fintech de pagamentos focada em maquininhas de cartão de baixo custo e aplicativos de gestão de vendas para microempreendedores informais.',
        'executive_summary': 'Milhões de autônomos não aceitam cartão por falta de CPF ativo ou taxas abusivas. O PayFacil libera credenciamento simplificado e repasse no Pix em 5 segundos. 8.500 clientes ativos no Nordeste com volume financeiro expressivo. Buscamos R$ 2.000.000 para securitizar carteira de antecipação.',
        'logo_url': 'https://placehold.co/200x200/10B981/FFFFFF?text=PF',
        'name': 'PayFacil',
        'partners': [
            {'avatar_url': null, 'bio': 'Economista ex-analista de pagamentos de grande banco digital.', 'equity_pct': 50, 'name': 'Fernanda Barros', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheira de dados ex-desenvolvedora de gateways de pagamento.', 'equity_pct': 50, 'name': 'Karla Souza', 'role': 'CTO & Co-fundadora'},
        ],
        'stage': 'operating',
        'tagline': 'A maquininha de cartão simplificada para autônomos',
        'token_name': 'PAY',
        'token_price': 0.40,
        'total_tokens': 5000000,
        'updated_at': new Date('2026-02-10'),
        'video_url': null,
    },
    // 48
    {
        'advisors': [{name: 'Profa. Sofia Ramos', role: 'Mentora de Desenvolvimento Infantil'}],
        'capital_raised': 95000,
        'created_at': new Date('2026-01-10'),
        'description': 'A LearnKids desenvolve e comercializa jogos interativos móveis e físicos voltados para a alfabetização e letramento matemático de crianças de 4 a 8 anos.',
        'executive_summary': 'A alfabetização deficiente afeta milhões de crianças no país. O LearnKids utiliza histórias lúdicas e inteligência adaptativa no app para prender a atenção. Piloto ativo com 800 crianças obteve 40% de melhora no aprendizado. Buscamos R$ 400.000 para expansão de novos módulos educacionais.',
        'logo_url': 'https://placehold.co/200x200/EC4899/FFFFFF?text=LK',
        'name': 'LearnKids',
        'partners': [
            {'avatar_url': null, 'bio': 'Pedagoga e escritora de livros didáticos com mestrado na USP.', 'equity_pct': 60, 'name': 'Sofia Ramos', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Desenvolvedor front-end de jogos educativos móveis.', 'equity_pct': 40, 'name': 'Felipe Lima', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'new',
        'tagline': 'Jogos educativos interativos e eficientes para crianças',
        'token_name': 'KIDS',
        'token_price': 0.12,
        'total_tokens': 2000000,
        'updated_at': null,
        'video_url': null,
    },
    // 49
    {
        'advisors': [{name: 'Dra. Amanda Ramos', role: 'Mentora de Home Care e Enfermagem'}],
        'capital_raised': 280000,
        'created_at': new Date('2025-08-01'),
        'description': 'A HomeCare conecta famílias a profissionais de enfermagem, cuidadores de idosos e fisioterapeutas para atendimento domiciliar com seguro de responsabilidade civil integrado.',
        'executive_summary': 'O envelhecimento da população cria enorme demanda por cuidadores. A HomeCare valida perfis e monitora horários via geolocalização. 1.200 profissionais cadastrados e 4.500 plantões intermediados em SP. Receita recorrente mensal de R$ 60.000. Buscamos R$ 800.000 para expansão de vendas corporativas.',
        'logo_url': 'https://placehold.co/200x200/06B6D4/FFFFFF?text=HC',
        'name': 'HomeCare',
        'partners': [
            {'avatar_url': null, 'bio': 'Enfermeira com especialização em geriatria e MBA em saúde pública.', 'equity_pct': 50, 'name': 'Marina Ramos', 'role': 'CEO & Co-fundadora'},
            {'avatar_url': null, 'bio': 'Engenheiro de software especializado em sistemas de reputação e avaliações.', 'equity_pct': 50, 'name': 'Thiago Santos', 'role': 'CTO & Co-fundador'},
        ],
        'stage': 'operating',
        'tagline': 'Cuidadores de idosos e enfermeiros domiciliares validados',
        'token_name': 'HCARE',
        'token_price': 0.30,
        'total_tokens': 4000000,
        'updated_at': new Date('2026-03-05'),
        'video_url': null,
    },
    // 50
    {
        'advisors': [{name: 'Dr. Thiago Silveira', role: 'Mentor de Projetos de Carbono'}],
        'capital_raised': 1800000,
        'created_at': new Date('2024-10-15'),
        'description': 'A CarbonZero desenvolve uma plataforma para o cálculo automático de pegada de carbono e compra direta de créditos de carbono fracionados certificados voltados para PMEs.',
        'executive_summary': 'Pequenas e médias empresas querem ser carbono neutro mas não sabem como comprar créditos de forma segura. A CarbonZero facilita o processo com nossa API de cálculo integrada ao ERP do cliente. 600 PMEs ativas. GMV anual de R$ 2.8M. Buscamos R$ 5.000.000 para desenvolver inteligência preditiva para frotas.',
        'logo_url': 'https://placehold.co/200x200/10B981/FFFFFF?text=CZ',
        'name': 'CarbonZero',
        'partners': [
            {'avatar_url': null, 'bio': 'Consultor ambiental com 8 anos de experiência em projetos de crédito de carbono.', 'equity_pct': 45, 'name': 'Thiago Silveira', 'role': 'CEO & Co-fundador'},
            {'avatar_url': null, 'bio': 'Pesquisador em ciência computacional focado em modelos climáticos.', 'equity_pct': 35, 'name': 'Sandra Ramos', 'role': 'CTO & Co-fundadoras'},
            {'avatar_url': null, 'bio': 'Designer de UX/UI com foco em ferramentas de transparência de dados.', 'equity_pct': 20, 'name': 'Juliana Lima', 'role': 'CPO & Co-fundadora'},
        ],
        'stage': 'expanding',
        'tagline': 'Compensação fácil de pegada de carbono para PMEs',
        'token_name': 'ZERO',
        'token_price': 1.05,
        'total_tokens': 12000000,
        'updated_at': new Date('2026-04-20'),
        'video_url': null,
    },
];

startups.push(...extraStartups);

async function uploadVideos(): Promise<Record<string, string>> {
    const bucket = storage.bucket();
    const urls: Record<string, string> = {};

    for (const [startupName, fileName] of Object.entries(VIDEO_MAP)) {
        const filePath = path.join(VIDEOS_DIR, `${fileName}.mp4`);
        if (!fs.existsSync(filePath)) {
            console.warn(`  ⚠ Video not found for "${startupName}": ${filePath}`);
            continue;
        }

        const destination = `videos/${fileName}.mp4`;
        await bucket.upload(filePath, {
            destination,
            metadata: {contentType: 'video/mp4'},
        });

        urls[startupName] = destination;
        console.log(`  ✓ Uploaded "${startupName}"`);
    }

    return urls;
}

async function seed(): Promise<void>
{
    console.log('Uploading videos...');
    const videoUrls = await uploadVideos();

    console.log('\nSeeding startups...\n');

    const col = db.collection('startups');

    for (const rawStartup of startups)
    {
        const base_price = rawStartup.token_price;
        const available_tokens = rawStartup.total_tokens;
        // Deterministic appreciation factor based on name length
        const appreciation_factor = Number((0.5 + (rawStartup.name.length % 5) * 0.5).toFixed(1));

        const startup: Omit<StartupDocument, 'id'> = {
            ...rawStartup,
            base_price,
            available_tokens,
            appreciation_factor,
            video_url: videoUrls[rawStartup.name] ?? null,
        };

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
