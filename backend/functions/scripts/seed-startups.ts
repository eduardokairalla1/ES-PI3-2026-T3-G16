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
        'token_price': 0.06,
        'total_tokens': 1500000,
        'updated_at': null,
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
