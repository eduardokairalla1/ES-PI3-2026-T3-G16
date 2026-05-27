/**
 * Seed script — populates Firestore emulator with Q&A for all startups.
 * Generates 8–13 questions per startup from multiple different users, with a
 * realistic mix of public/private visibility and answered/unanswered status.
 *
 * Run while the Firebase emulators are running:
 *   npm run seed:questions
 *
 * Idempotent: skips startups that already have at least one question.
 * Requires seed:startups and seed:users to have run first.
 *
 * Eduardo Kairalla - 24024241
 */

process.env.FIRESTORE_EMULATOR_HOST ??= 'localhost:8080';

import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';

import type {QuestionDocument, StartupDocument} from '../src/db/startups/model';


/**
 * TYPES
 */

interface UserInfo
{
    uid: string;
    full_name: string;
}

interface QATemplate
{
    bucketId: number;
    question: string;
    answer: string;
}


/**
 * HELPERS
 */

function hashCode(s: string): number
{
    let h = 0;
    for (let i = 0; i < s.length; i++)
    {
        h = ((h << 5) - h) + s.charCodeAt(i);
        h |= 0;
    }
    return Math.abs(h);
}

/** Deterministic Fisher-Yates shuffle using a LCG seed. */
function seededShuffle<T>(arr: T[], seed: number): T[]
{
    const result = [...arr];
    let s = seed;
    for (let i = result.length - 1; i > 0; i--)
    {
        s = ((s * 1664525) + 1013904223) & 0xFFFFFFFF;
        const j = Math.abs(s) % (i + 1);
        [result[i], result[j]] = [result[j], result[i]];
    }
    return result;
}

function fill(template: string, name: string, token: string): string
{
    return template.replace(/{name}/g, name).replace(/{token}/g, token);
}

function daysAgo(days: number): Date
{
    const d = new Date();
    d.setDate(d.getDate() - Math.max(0, days));
    return d;
}


/**
 * Q&A CONTENT
 * 8 thematic buckets × 7 templates each = 56 answered templates.
 * Plus 15 unanswered-only questions for realism.
 */

// Bucket IDs:
//  0 = Financeiro
//  1 = Produto/Tecnologia
//  2 = Equipe
//  3 = Mercado/Competição
//  4 = Regulatório/Legal
//  5 = Crescimento/Expansão
//  6 = Tokenização/Investimento
//  7 = Operações
//  8 = ESG / Impacto Social
//  9 = Inteligência Artificial e Dados
// 10 = Vendas / Go-to-Market
// 11 = Produto / Experiência do Usuário

const QA_ANSWERED: QATemplate[] = [

    // -------------------------------------------------------------------------
    // BUCKET 0 — FINANCEIRO
    // -------------------------------------------------------------------------
    {
        bucketId: 0,
        question: 'Qual é o modelo de receita principal da {name} hoje e como vocês planejam diversificá-lo nos próximos 12 meses?',
        answer:   'Nossa principal fonte é a assinatura SaaS mensal, que representa cerca de 80% do faturamento. Para diversificar, lançaremos um plano enterprise com funcionalidades avançadas e um módulo de serviços profissionais de implementação, ambos previstos para o segundo semestre.',
    },
    {
        bucketId: 0,
        question: 'Qual o prazo estimado para a {name} atingir o break-even operacional?',
        answer:   'Com projeções conservadoras, estimamos break-even operacional em 16 a 18 meses após o fechamento desta rodada, mantendo o ritmo de crescimento de MRR que já entregamos nos últimos trimestres.',
    },
    {
        bucketId: 0,
        question: 'Qual é o burn rate mensal da {name} e qual a runway atual com o capital já captado?',
        answer:   'Nosso burn rate mensal gira em torno de R$ 90.000. Com o capital já captado temos runway para 14 meses. A alocação é: 50% em produto/engenharia, 30% em aquisição de clientes e 20% em overhead operacional.',
    },
    {
        bucketId: 0,
        question: 'A {name} tem alguma previsão de distribuição de dividendos ou participação nos lucros para detentores do token {token}?',
        answer:   'Não há previsão de dividendos no horizonte atual — todo resultado operacional positivo será reinvestido em crescimento acelerado. A tese de retorno para o investidor em {token} é primariamente a valorização do ativo ao longo do tempo.',
    },
    {
        bucketId: 0,
        question: 'Qual a margem de contribuição atual dos produtos e serviços da {name}?',
        answer:   'Nossa margem de contribuição está entre 65% e 70%, saudável para o estágio atual. Trabalhamos para chegar a 75%+ até o final do ano via otimizações de custo de infraestrutura e renegociação de contratos com fornecedores.',
    },
    {
        bucketId: 0,
        question: 'A {name} já tem receita recorrente consolidada? Qual o churn rate atual?',
        answer:   'Sim, o MRR tem crescido consistentemente. Nosso churn mensal está em torno de 2%, abaixo da média do setor para negócios B2B. Acompanhamos cohorts de perto e mantemos um time de CS ativo para reduzir ainda mais esse número.',
    },
    {
        bucketId: 0,
        question: 'Quais são os maiores custos operacionais da {name} atualmente?',
        answer:   'Os três maiores são: (1) folha de pagamento — 46% do total, (2) infraestrutura de tecnologia — 22%, e (3) marketing e aquisição de clientes — 19%. O restante cobre despesas administrativas, jurídicas e de escritório.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 1 — PRODUTO/TECNOLOGIA
    // -------------------------------------------------------------------------
    {
        bucketId: 1,
        question: 'Qual stack tecnológico a {name} utiliza? Existe alguma dependência crítica de fornecedores externos?',
        answer:   'Utilizamos uma stack moderna baseada em cloud. Não há dependência de fornecedor único para nenhuma funcionalidade crítica — nossa arquitetura foi desenhada para facilitar a migração entre provedores com esforço gerenciável.',
    },
    {
        bucketId: 1,
        question: 'Como é o roadmap de produto da {name} para os próximos 12 meses?',
        answer:   'Três grandes iniciativas: (1) módulo de analytics avançado no Q3, (2) integração nativa com os principais sistemas do mercado no Q4, e (3) aplicativo mobile nativo no Q1 do próximo ano.',
    },
    {
        bucketId: 1,
        question: 'Como a {name} garante a conformidade com a LGPD no tratamento dos dados dos usuários?',
        answer:   'Temos DPO nomeado, política de privacidade publicada e contratos de processamento de dados com todos os fornecedores. Realizamos auditorias internas de conformidade LGPD trimestralmente e temos processo formal de resposta a incidentes.',
    },
    {
        bucketId: 1,
        question: 'A {name} tem alguma patente ou propriedade intelectual registrada?',
        answer:   'Temos um pedido de patente do nosso algoritmo principal em tramitação no INPI. Toda a PI do código é protegida por contratos de cessão de direitos firmados com todos os colaboradores desde o primeiro dia.',
    },
    {
        bucketId: 1,
        question: 'Qual é o principal diferencial técnico da {name} em relação aos concorrentes?',
        answer:   'Nosso maior diferencial é o modelo de IA proprietário, treinado com dados exclusivos de 18+ meses de operação real. Isso cria uma barreira de entrada significativa — cada mês que operamos, o modelo fica mais preciso e a vantagem aumenta.',
    },
    {
        bucketId: 1,
        question: 'Como a {name} lida com a escalabilidade técnica em momentos de pico de uso?',
        answer:   'Nossa infraestrutura em cloud tem auto-scaling configurado e realizamos load tests mensalmente. Mantemos SLA de 99,9% de disponibilidade. Em picos, o sistema escala automaticamente sem nenhuma intervenção manual.',
    },
    {
        bucketId: 1,
        question: 'Quais métricas de produto a {name} acompanha para medir a satisfação dos usuários?',
        answer:   'Acompanhamos NPS mensal (atualmente em 74), CSAT por jornada, taxa de ativação nos primeiros 14 dias, tempo médio de sessão e taxa de uso das funcionalidades principais. Realizamos entrevistas qualitativas bimestrais com clientes ativos.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 2 — EQUIPE
    // -------------------------------------------------------------------------
    {
        bucketId: 2,
        question: 'Quantas pessoas compõem a equipe da {name} hoje e quais são os planos de contratação com o novo capital?',
        answer:   'Somos 9 pessoas hoje — 4 no time técnico, 2 em vendas/CS, 1 em produto, 1 em marketing e o CEO. Com a nova rodada, planejamos chegar a 18 em 12 meses, priorizando engenheiros sêniores e um Head de Vendas com experiência em B2B.',
    },
    {
        bucketId: 2,
        question: 'Como está estruturado o equity da {name}? O vesting dos fundadores está formalizado em contrato?',
        answer:   'O equity dos fundadores está sujeito a vesting de 4 anos com cliff de 1 ano, formalmente documentado em acordo de sócios. Isso alinha os incentivos de longo prazo. Colaboradores chave também recebem stock options com vesting.',
    },
    {
        bucketId: 2,
        question: 'Os fundadores da {name} têm dedicação integral ao projeto? Algum deles possui atividades paralelas relevantes?',
        answer:   'Todos os fundadores têm dedicação 100% à {name} desde a fundação. Nenhum possui outro emprego ou atividade paralela relevante. Acreditamos que projetos ambiciosos exigem comprometimento total.',
    },
    {
        bucketId: 2,
        question: 'Como a {name} lida com decisões estratégicas em que os sócios têm opiniões divergentes?',
        answer:   'Temos acordo de sócios com papéis e alçadas definidas. Decisões estratégicas seguem: (1) alinhamento de perspectivas, (2) análise de dados e (3) votação com critérios predefinidos. Divergências saudáveis fazem o processo melhor.',
    },
    {
        bucketId: 2,
        question: 'Qual é a cultura organizacional da {name} e como vocês a constroem no dia a dia?',
        answer:   'Nossa cultura se baseia em três pilares: velocidade de aprendizado, honestidade radical e obsessão pelo cliente. Mantemos all-hands quinzenais, 1:1s semanais entre gestores e liderados, e uma pesquisa de clima mensal anônima.',
    },
    {
        bucketId: 2,
        question: 'A {name} tem plano de participação nos resultados ou stock options para colaboradores?',
        answer:   'Sim, temos um ESOP reservando 10% do cap table para distribuição a colaboradores chave ao longo do tempo. Novos contratados sêniores recebem opções como parte da oferta, com vesting de 4 anos.',
    },
    {
        bucketId: 2,
        question: 'Como a {name} está se preparando para eventuais saídas ou substituições de fundadores?',
        answer:   'Temos cláusulas de drag-along, tag-along e um mecanismo de buy-out em caso de saída voluntária documentados no acordo de sócios. As responsabilidades críticas estão documentadas e há cobertura interna para as principais funções de liderança.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 3 — MERCADO/COMPETIÇÃO
    // -------------------------------------------------------------------------
    {
        bucketId: 3,
        question: 'Quem são os principais concorrentes da {name} no Brasil e como vocês se diferenciam deles?',
        answer:   'Competimos com soluções legadas caras e complexas e algumas startups internacionais sem aderência ao mercado local. Nos diferenciamos pelo preço acessível, suporte em português e integrações nativas com os sistemas que as empresas brasileiras já usam.',
    },
    {
        bucketId: 3,
        question: 'Qual é o tamanho do mercado endereçável (TAM/SAM/SOM) que a {name} está mirando?',
        answer:   'Nosso TAM no Brasil é de ~R$ 4 bilhões anuais. O SAM com o produto atual é ~R$ 480 milhões, e o SOM (meta em 3 anos) é ~R$ 48 milhões — menos de 1% do TAM, que é uma meta realista e defensável.',
    },
    {
        bucketId: 3,
        question: 'Como a {name} adquire novos clientes? Qual é o CAC atual e como ele se compara ao LTV?',
        answer:   'Principais canais: indicação orgânica (40%), marketing de conteúdo/SEO (25%), parcerias com associações do setor (20%) e outbound (15%). CAC médio de R$ 420 com LTV/CAC de 11x — unit economics saudável e sustentável.',
    },
    {
        bucketId: 3,
        question: 'Existe risco de que grandes players (bigtech ou fintechs) entrem no mercado da {name} e a tornem obsoleta?',
        answer:   'É um risco que monitoramos. Nossa defesa é especialização profunda no nicho — grandes players priorizam volume e atendem segmentos específicos superficialmente. Os dados proprietários acumulados e o network de clientes também são barreiras de entrada relevantes.',
    },
    {
        bucketId: 3,
        question: 'Como a {name} se posiciona no mercado — líder de preço, de qualidade ou de nicho especializado?',
        answer:   'Somos a melhor relação custo-benefício para o nosso segmento específico. Não somos os mais baratos nem os mais completos, mas somos a melhor opção para o perfil exato de cliente que servimos. Esse foco nos gera NPS alto e churn baixo.',
    },
    {
        bucketId: 3,
        question: 'A {name} tem casos de sucesso de clientes que possam ser compartilhados com potenciais investidores?',
        answer:   'Temos vários cases disponíveis para investidores qualificados! Um destaque: um cliente que aumentou sua conversão em 34% nos primeiros 3 meses de uso. Podemos agendar uma apresentação detalhada com depoimento do próprio cliente para quem tiver interesse.',
    },
    {
        bucketId: 3,
        question: 'Qual foi o principal aprendizado da {name} ao tentar entrar em um segmento de mercado diferente do original?',
        answer:   'Aprendemos que o ICP (Ideal Customer Profile) importa mais que o tamanho do mercado. Quando tentamos expandir para um segmento adjacente sem adaptar o produto, o resultado foi fraco. Voltamos ao foco e o crescimento retomou. Hoje qualquer expansão começa com discovery rigoroso.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 4 — REGULATÓRIO/LEGAL
    // -------------------------------------------------------------------------
    {
        bucketId: 4,
        question: 'A {name} precisa de licença ou autorização regulatória específica para operar? Já obteve todas as necessárias?',
        answer:   'Sim, nosso setor tem requisitos regulatórios. Já obtivemos todas as licenças para operar plenamente e contamos com assessoria jurídica especializada para garantir conformidade contínua, especialmente com novos marcos que estão em discussão.',
    },
    {
        bucketId: 4,
        question: 'Como a {name} está se preparando para eventuais mudanças regulatórias que possam impactar o modelo de negócio?',
        answer:   'Temos um advogado especialista no setor como advisor estratégico e participamos das associações do setor. Mantemos um roadmap regulatório revisado trimestralmente. Nossa arquitetura de produto foi desenhada para ser adaptável a mudanças legais sem grandes refatorações.',
    },
    {
        bucketId: 4,
        question: 'A {name} já realizou due diligence jurídica completa? Existe algum contencioso relevante em aberto?',
        answer:   'Realizamos due diligence jurídica completa antes desta rodada de captação. Não há nenhum contencioso relevante em aberto. Contratos de trabalho, acordos com fornecedores, termos com clientes e a estrutura societária foram todos revisados e estão em conformidade.',
    },
    {
        bucketId: 4,
        question: 'Como os contratos da {name} com clientes são estruturados em termos de SLA e responsabilidade?',
        answer:   'Contratos desenvolvidos com escritório jurídico especializado incluem: SLA com penalidades objetivas, proteção de confidencialidade alinhada à LGPD, limitação de responsabilidade e mecanismo de resolução de disputas. Revisamos os contratos padrão anualmente.',
    },
    {
        bucketId: 4,
        question: 'A {name} tem cobertura de seguro empresarial adequada para os riscos do negócio?',
        answer:   'Temos seguro de responsabilidade civil profissional e D&O (Directors & Officers) vigentes. Estamos contratando também uma apólice de cyber risk para cobrir incidentes de segurança. Nossa corretora revisa as coberturas a cada semestre.',
    },
    {
        bucketId: 4,
        question: 'Como a {name} protege a propriedade intelectual dos seus produtos e soluções contra cópias ou uso indevido?',
        answer:   'PI protegida em múltiplas camadas: (1) contratos de cessão de direitos com todos os colaboradores, (2) NDAs com parceiros e fornecedores, (3) pedidos de patente para as inovações mais relevantes no INPI, e (4) segredos industriais com acesso restrito e auditável.',
    },
    {
        bucketId: 4,
        question: 'A {name} possui política formal de compliance e código de ética para colaboradores e parceiros?',
        answer:   'Sim, temos um código de conduta formal assinado por todos os colaboradores, revisado anualmente. Para parceiros, incluímos cláusulas de compliance nos contratos. Um canal de denúncias anônimas está disponível 24/7.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 5 — CRESCIMENTO/EXPANSÃO
    // -------------------------------------------------------------------------
    {
        bucketId: 5,
        question: 'Qual é a estratégia da {name} para os próximos 2 a 3 anos? Existe plano de internacionalização?',
        answer:   'Nos próximos 2 anos, foco total no Brasil — ainda há enorme espaço de penetração aqui. Internacionalização está no roadmap para 2028, começando por Portugal (idioma e cultura próximos) e depois América Latina (mesmas dores de mercado).',
    },
    {
        bucketId: 5,
        question: 'Quais KPIs a {name} acompanha mensalmente para medir o progresso e a saúde do negócio?',
        answer:   'MRR e sua taxa de crescimento semanal, churn mensal, CAC por canal, LTV médio por cohort, NPS, tempo de ativação de novos clientes e taxa de expansão de receita (upsell/cross-sell). Mensalmente fazemos revisão completa de cohorts com forecast de 90 dias.',
    },
    {
        bucketId: 5,
        question: 'Após esta rodada de captação, quando a {name} pretende levantar a próxima rodada de investimento?',
        answer:   'Esta rodada nos dá runway para 18 meses. Se executarmos o plano, estaremos em posição de levantar uma Série A em 15 a 18 meses, com métricas que suportem um valuation compatível com o crescimento entregue.',
    },
    {
        bucketId: 5,
        question: 'A {name} tem planos de expansão para outros estados ou cidades brasileiras em 2026?',
        answer:   'Rio de Janeiro e Belo Horizonte são as próximas praças, com entrada prevista para o segundo semestre de 2026. Já temos parceiros locais mapeados e uma lista de prospects qualificados. Nosso playbook de entrada em novos mercados está completamente documentado.',
    },
    {
        bucketId: 5,
        question: 'Qual é o principal gargalo de crescimento que a {name} enfrenta hoje?',
        answer:   'Nosso maior limitante é a capacidade de onboarding — cada novo cliente exige atenção intensiva do CS nos primeiros 60 dias. Estamos investindo em automação e autoatendimento para escalar sem crescer o time na mesma proporção. Esse é um dos principais usos do capital desta rodada.',
    },
    {
        bucketId: 5,
        question: 'A {name} está considerando parcerias estratégicas ou M&A com outros players do mercado?',
        answer:   'Estamos em conversas iniciais com dois parceiros complementares para acordos de co-distribuição. M&A não é prioridade agora, mas monitoramos startups menores que poderiam acelerar nossa expansão para novos segmentos. Qualquer movimento desse tipo passaria pela aprovação dos investidores.',
    },
    {
        bucketId: 5,
        question: 'Como a {name} planeja usar especificamente o capital captado nesta rodada?',
        answer:   'A alocação prevista é: 50% em produto e engenharia (contratações + infraestrutura), 30% em marketing e aquisição de clientes, e 20% em estrutura operacional. Relatórios semestrais detalhados de uso de capital serão enviados a todos os investidores.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 6 — TOKENIZAÇÃO/INVESTIMENTO
    // -------------------------------------------------------------------------
    {
        bucketId: 6,
        question: 'Qual é o mecanismo de liquidez do token {token}? Como o investidor realiza o retorno sobre o investimento?',
        answer:   'A liquidez primária é provida pelo orderbook da plataforma MesclaInvest, onde detentores de {token} podem negociar entre si. No médio prazo, buscamos listagem em exchanges especializadas de tokens de startups para ampliar o acesso e a liquidez.',
    },
    {
        bucketId: 6,
        question: 'Existem cláusulas de lock-up para os tokens {token} em posse dos fundadores?',
        answer:   'Sim. Os tokens dos fundadores têm lock-up de 24 meses contados da data de emissão, com desbloqueio gradual de 25% a cada 6 meses após o período inicial. Isso demonstra o alinhamento da equipe com o crescimento de longo prazo.',
    },
    {
        bucketId: 6,
        question: 'Como funciona a precificação do token {token} no orderbook? É formada por oferta e demanda livre?',
        answer:   'Sim, o preço é formado pelo livre jogo de oferta e demanda. O preço base inicial foi estabelecido por avaliação de múltiplos de receita, e o mercado o ajusta continuamente conforme novas informações sobre o desempenho da {name} se tornam disponíveis.',
    },
    {
        bucketId: 6,
        question: 'Qual é a distribuição total dos tokens {token}? Quantos foram reservados para a equipe vs. disponíveis para captação?',
        answer:   'Dos tokens totais emitidos: 20% para a equipe fundadora (vesting de 4 anos), 10% para advisors e parceiros estratégicos (vesting de 2 anos), e 70% disponíveis para captação via plataforma MesclaInvest.',
    },
    {
        bucketId: 6,
        question: 'O token {token} confere algum tipo de direito de voto ou participação na governança da {name}?',
        answer:   'Não. Os tokens {token} são instrumentos de participação econômica, mas não conferem direito de voto ou poder de veto na gestão. As decisões estratégicas permanecem com os fundadores, garantindo agilidade operacional. Investidores recebem relatórios trimestrais de desempenho.',
    },
    {
        bucketId: 6,
        question: 'Quais são os principais riscos de investir no token {token} que um investidor deve considerar antes de comprar?',
        answer:   'Os principais riscos são: (1) risco de execução — a {name} pode não atingir suas metas de crescimento; (2) risco de liquidez — o mercado secundário pode ter volume limitado em determinados momentos; (3) risco regulatório — mudanças no marco legal podem impactar o modelo. Recomendamos diversificação.',
    },
    {
        bucketId: 6,
        question: 'Em quanto tempo a {name} pretende utilizar integralmente o capital captado com a emissão dos tokens {token}?',
        answer:   'O plano é utilizar o capital em 18 meses conforme o orçamento aprovado. Cada real captado tem destino e timeline definidos. Um relatório semestral detalhado de uso de capital é enviado a todos os detentores de {token}.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 7 — OPERAÇÕES
    // -------------------------------------------------------------------------
    {
        bucketId: 7,
        question: 'Como é o processo de suporte ao cliente na {name}? Qual o tempo médio de resposta para tickets?',
        answer:   'Suporte via chat, e-mail e telefone em horário comercial. Tempo médio de primeira resposta de 2 horas para tickets normais e 30 minutos para críticos. Taxa de resolução no primeiro contato de 78%, acima da média do setor.',
    },
    {
        bucketId: 7,
        question: 'Como a {name} garante a qualidade consistente do serviço entregue aos clientes?',
        answer:   'Temos QA com testes automatizados em múltiplas camadas e revisão humana em etapas críticas. Todo novo recurso passa por beta fechado com clientes selecionados antes do lançamento geral, o que nos permite capturar problemas antes de impactar toda a base.',
    },
    {
        bucketId: 7,
        question: 'A {name} tem alguma certificação de qualidade ou conformidade relevante para o seu setor?',
        answer:   'Estamos em processo de obtenção da certificação ISO 27001 (segurança da informação), prevista para o Q4. Já seguimos todos os controles exigidos e estamos na fase de auditoria externa. Para o segmento enterprise, essa certificação é um diferencial competitivo importante.',
    },
    {
        bucketId: 7,
        question: 'Qual é o NPS da {name} junto aos clientes ativos? Quais são os principais drivers de promotores e detratores?',
        answer:   'Nosso NPS atual é 71, medido mensalmente. Os promotores destacam facilidade de uso e qualidade do suporte. Os detratores apontam integrações com sistemas legados como principal ponto de melhoria — item que está no topo do nosso roadmap para o próximo trimestre.',
    },
    {
        bucketId: 7,
        question: 'Como a {name} onboarda novos clientes e qual é o "time to first value" médio?',
        answer:   'O onboarding dura em média 14 dias desde a assinatura do contrato até o cliente estar completamente operacional, com CS dedicado e check-ins semanais no primeiro mês. O time to first value médio (primeiro resultado mensurável) é de 8 dias.',
    },
    {
        bucketId: 7,
        question: 'Como a {name} coleta e incorpora o feedback dos usuários no processo de desenvolvimento do produto?',
        answer:   'Usamos: NPS mensal com perguntas abertas, entrevistas trimestrais com clientes chave, análise sistemática de tickets de suporte e um portal de sugestões interno com votação. O feedback é triado semanalmente pelo time de produto, com itens de maior impacto entrando no backlog priorizado.',
    },

    // =========================================================================
    // BLOCO EXTRA — mais 8 entradas por bucket original (0–7)
    // =========================================================================

    // -------------------------------------------------------------------------
    // BUCKET 0 — FINANCEIRO (extra)
    // -------------------------------------------------------------------------
    {
        bucketId: 0,
        question: 'Como a {name} projeta o crescimento de receita para os próximos 2 anos? Quais são as premissas principais do modelo financeiro?',
        answer:   'Trabalhamos com três cenários: conservador (crescimento de 8% ao mês), base (12%) e otimista (18%). O cenário base assume manutenção do CAC atual, churn abaixo de 2,5% e lançamento do plano enterprise no Q3. Compartilhamos o modelo completo com investidores qualificados em nossa data room.',
    },
    {
        bucketId: 0,
        question: 'Qual é a estratégia de precificação da {name} para diferentes segmentos de clientes? Existe diferenciação por porte ou uso?',
        answer:   'Temos três planos: Starter (pequenos negócios), Growth (médias empresas) e Enterprise (grandes contas com SLA e integrações customizadas). O ticket médio varia de R$ 299/mês no Starter a R$ 3.800/mês no Enterprise. A diferenciação é por volume de uso, número de usuários e nível de suporte.',
    },
    {
        bucketId: 0,
        question: 'A {name} possui alguma dívida, linha de crédito ativa ou passivo relevante que os investidores devem conhecer?',
        answer:   'Não temos dívidas financeiras relevantes. Utilizamos uma linha de capital de giro pré-aprovada com taxa de CDI+2% para eventuais necessidades de caixa de curto prazo, mas raramente a acionamos. O balanço está saudável e sem passivos contingentes significativos.',
    },
    {
        bucketId: 0,
        question: 'Como a {name} gerencia o fluxo de caixa em fases de crescimento acelerado, onde despesas tendem a crescer antes das receitas?',
        answer:   'Fazemos projeção de caixa rolling de 13 semanas, atualizada toda segunda-feira. Temos uma reserva de caixa equivalente a 3 meses de burn como colchão de segurança. Em rodadas de crescimento, antecipamos contratações-chave com até 60 dias de antecedência ao aumento de receita previsto.',
    },
    {
        bucketId: 0,
        question: 'A {name} já conta com auditoria contábil independente? Como são preparadas as demonstrações financeiras?',
        answer:   'Contamos com contador externo especializado em startups que prepara as demonstrações mensais seguindo o padrão BR GAAP. Para esta rodada de captação, contratamos uma auditoria independente das demonstrações dos últimos 18 meses. O relatório está disponível na data room para investidores verificados.',
    },
    {
        bucketId: 0,
        question: 'Qual é o ticket médio atual de um cliente da {name} e como ele evoluiu ao longo dos últimos 12 meses?',
        answer:   'O ticket médio cresceu de R$ 420 para R$ 680 nos últimos 12 meses — um crescimento de 62%. Esse aumento reflete a maturação da base (mais clientes migrando para planos superiores), o lançamento de add-ons e o sucesso da estratégia de upsell realizada pelo CS.',
    },
    {
        bucketId: 0,
        question: 'Como a {name} trata o reconhecimento de receita? Receitas de contratos anuais são reconhecidas no momento do pagamento ou pro rata?',
        answer:   'Seguimos o modelo de reconhecimento pro rata mensalis — contratos anuais pagos à vista geram uma receita diferida que é reconhecida mensalmente ao longo do contrato. Isso garante que nossas métricas de MRR reflitam a receita efetivamente "entregue", não apenas cobrada.',
    },
    {
        bucketId: 0,
        question: 'Qual foi o maior erro financeiro cometido pela {name} até hoje e o que vocês aprenderam com ele?',
        answer:   'Contratamos um time de vendas grande demais cedo demais, antes de ter o processo de vendas bem documentado e escalável. O resultado foi alto CAC e alto turnover nesse time. Aprendemos a investir primeiro em playbook e processo, e só depois em headcount. Hoje temos um ciclo de vendas muito mais eficiente.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 1 — PRODUTO/TECNOLOGIA (extra)
    // -------------------------------------------------------------------------
    {
        bucketId: 1,
        question: 'Como a {name} decide quais funcionalidades entram no produto? Existe algum framework de priorização?',
        answer:   'Usamos uma combinação do framework RICE (Reach, Impact, Confidence, Effort) com input direto de NPS, entrevistas de clientes e análise de uso. O backlog é revisado e repriorizado a cada sprint. Funcionalidades com alto impacto no churn ou no upsell sempre ganham prioridade sobre novas features.',
    },
    {
        bucketId: 1,
        question: 'A {name} usa alguma metodologia de descoberta de produto, como Jobs to be Done ou Design Thinking?',
        answer:   'Sim, somos grandes adeptos de Jobs to be Done (JTBD) para entender por que os clientes "contratam" nosso produto. Cada nova iniciativa começa com um workshop de JTBD com clientes reais. Isso nos ajuda a priorizar o que realmente importa e evitar construir funcionalidades que ninguém usa.',
    },
    {
        bucketId: 1,
        question: 'Como a {name} mede o sucesso de uma funcionalidade após o lançamento? Qual é o critério de "sucesso"?',
        answer:   'Definimos métricas de sucesso antes de construir qualquer funcionalidade — seguindo o princípio de "working backwards". As métricas típicas são: taxa de adoção (% da base usando), impacto no NPS dos usuários que adotaram e impacto no churn. Avaliamos 30 e 90 dias após o lançamento.',
    },
    {
        bucketId: 1,
        question: 'Com que frequência a {name} lança atualizações no produto? Qual é o ciclo de release?',
        answer:   'Trabalhamos com deploys contínuos para o backend (múltiplos por dia em ambiente de produção com feature flags). Para o frontend, fazemos releases quinzenais com changelog publicado. Grandes funcionalidades passam por um período de soft-launch para 10% da base antes do rollout completo.',
    },
    {
        bucketId: 1,
        question: 'A {name} realiza testes A/B para decisões de produto e design? Quais foram os aprendizados mais relevantes?',
        answer:   'Sim, realizamos em média 3 a 5 experimentos simultâneos. O aprendizado mais valioso foi que simplificar o onboarding (removendo etapas, não adicionando) aumentou nossa taxa de ativação em 28%. Hoje toda mudança em jornada crítica passa por A/B antes de ir para 100% da base.',
    },
    {
        bucketId: 1,
        question: 'Como a {name} lida com o acúmulo de débito técnico sem comprometer a velocidade de entrega?',
        answer:   'Reservamos 20% de cada sprint para trabalho de débito técnico e refatoração. Isso não é negociável — aprendemos da pior forma que ignorar débito técnico desacelera muito a entrega no médio prazo. Além disso, fazemos uma "tech debt week" trimestral focada exclusivamente em melhorias de arquitetura.',
    },
    {
        bucketId: 1,
        question: 'Qual é a arquitetura de dados da {name}? Como os dados gerados pelo produto alimentam a tomada de decisão interna?',
        answer:   'Temos um data warehouse centralizado no BigQuery alimentado por eventos em tempo real via Segment. Todo o time (não só os engenheiros) tem acesso a dashboards no Metabase. Decisões de produto, vendas e CS são baseadas em dados. Nosso Chief of Staff dedica 30% do tempo a análises baseadas nesses dados.',
    },
    {
        bucketId: 1,
        question: 'A {name} tem plano para garantir a experiência do usuário em dispositivos de baixo desempenho ou com conexão de internet instável?',
        answer:   'Sim. Nosso produto foi projetado com progressive enhancement — funciona mesmo com conexão instável graças ao suporte offline parcial e sincronização em segundo plano. Testamos ativamente em dispositivos de entrada, pois boa parte dos nossos clientes acessa de smartphones com 4G inconsistente.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 2 — EQUIPE (extra)
    // -------------------------------------------------------------------------
    {
        bucketId: 2,
        question: 'Como é o processo seletivo da {name} para novas contratações? O que vocês priorizam além do currículo?',
        answer:   'Nosso processo tem 4 etapas: triagem de currículo, entrevista de valores culturais, case técnico ou prático e entrevista com o time que vai trabalhar junto. Priorizamos muito o fit cultural — habilidades técnicas ensinam-se, valores são muito mais difíceis de mudar.',
    },
    {
        bucketId: 2,
        question: 'Como a {name} equilibra salários competitivos com a restrição de caixa típica de startups early stage?',
        answer:   'Pagamos salários levemente abaixo do top de mercado em dinheiro, mas compensamos com stock options acima da média, flexibilidade de horário, trabalho remoto e uma cultura de crescimento rápido de carreira. Para talentos seniores que acreditam no projeto, esse pacote total é muito atrativo.',
    },
    {
        bucketId: 2,
        question: 'A {name} opera em modelo remoto, presencial ou híbrido? Como isso impacta a cultura e a velocidade de execução?',
        answer:   'Operamos em modelo híbrido: presencial às terças e quartas para trabalho colaborativo e tomada de decisão, remoto nos demais dias. A combinação mantém a cultura de colaboração sem abrir mão da flexibilidade que atrai talentos. Nosso time está concentrado em São Paulo, com 2 colaboradores fora do estado.',
    },
    {
        bucketId: 2,
        question: 'Como é o processo de onboarding de novos colaboradores na {name}? Quanto tempo leva para uma nova contratação estar 100% produtiva?',
        answer:   'Temos um onboarding de 30 dias estruturado: semana 1 de imersão cultural e produto, semana 2 de shadowing na área, semanas 3 e 4 de primeiras entregas guiadas. Um buddy interno acompanha cada novo contratado. Em média, os colaboradores estão plenamente produtivos no dia 35.',
    },
    {
        bucketId: 2,
        question: 'Quais são os principais benefícios que a {name} oferece aos colaboradores além do salário?',
        answer:   'Oferecemos: plano de saúde Bradesco (sem coparticipação), vale-refeição/alimentação, auxílio home office de R$ 200/mês, plano de saúde mental (sessões de psicoterapia cobertas), day off no aniversário e budget anual de R$ 1.500 para desenvolvimento profissional (cursos, livros, conferências).',
    },
    {
        bucketId: 2,
        question: 'A {name} tem plano formal de desenvolvimento e progressão de carreira para os colaboradores?',
        answer:   'Sim. Temos trilhas de carreira mapeadas para cada função — técnica e de gestão. As promoções seguem um ciclo semestral com avaliação 360°. O budget de desenvolvimento individual garante que cada pessoa avance nas habilidades que precisa para o próximo nível. 80% das promoções são internas.',
    },
    {
        bucketId: 2,
        question: 'Como a {name} mantém a cultura organizacional coesa enquanto o time cresce rapidamente?',
        answer:   'Três mecanismos principais: (1) rituais semanais de alinhamento (all-hands + 1:1s), (2) processo de onboarding que transmite explicitamente os valores desde o primeiro dia, e (3) colaboradores mais antigos atuam como guardiões da cultura em cada novo processo de contratação.',
    },
    {
        bucketId: 2,
        question: 'Qual é o perfil dos advisors da {name} e como eles contribuem de forma prática para o crescimento da empresa?',
        answer:   'Nossos advisors foram selecionados por complementaridade — cada um supre uma lacuna específica do time fundador. Um contribui com conexões enterprise, outro com know-how regulatório e o terceiro com experiência de escala em SaaS B2B. Cada um dedica 4 horas mensais estruturadas e está disponível para consultas pontuais.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 3 — MERCADO/COMPETIÇÃO (extra)
    // -------------------------------------------------------------------------
    {
        bucketId: 3,
        question: 'Como a {name} acompanha as tendências e movimentos do mercado em que atua? Existe algum processo de inteligência competitiva?',
        answer:   'Temos uma rotina mensal de análise competitiva: monitoramos lançamentos e precificação de concorrentes, lemos relatórios de setor (Gartner, CB Insights), participamos das principais conferências e mantemos conversas regulares com analistas do setor. Esse processo gera um relatório mensal compartilhado com todo o time.',
    },
    {
        bucketId: 3,
        question: 'Como a {name} se posiciona em termos de preço versus os principais concorrentes? Vocês competem no preço ou no valor?',
        answer:   'Competimos primariamente em valor, não em preço. Nosso produto é ~30% mais barato que as soluções enterprise legadas e ~20% mais caro que as soluções mais simples de entrada. Esse posicionamento de "meio-termo premium" é intencional — atende quem superou as soluções simples mas não quer pagar pelo excesso de features das legadas.',
    },
    {
        bucketId: 3,
        question: 'Qual é a taxa de conversão da {name} em cada etapa do funil de vendas, do lead ao cliente ativo?',
        answer:   'Nosso funil atual: lead → MQL: 22%, MQL → SQL: 35%, SQL → proposta: 58%, proposta → fechamento: 41%. A taxa de lead-to-close é de ~1,8%, que é saudável para nosso segmento. O maior gargalo está na qualificação de MQLs — investimento prioritário no próximo trimestre.',
    },
    {
        bucketId: 3,
        question: 'A {name} tem ou considera adotar uma estratégia de Product Led Growth (PLG), onde o produto em si é o principal motor de aquisição?',
        answer:   'Estamos em transição para PLG. Lançaremos um plano freemium no Q3 que permite uso limitado sem cartão de crédito. A hipótese é que usuários individuais adotem o produto e levem ele para dentro das empresas (bottom-up). Essa estratégia deve reduzir o CAC médio em 40% ao longo de 12 meses.',
    },
    {
        bucketId: 3,
        question: 'Como a {name} identifica e prioriza novos segmentos de mercado para expansão?',
        answer:   'Analisamos quais clientes atuais têm maior LTV, menor churn e maiores NPS scores — e buscamos segmentos com perfil similar. Adicionalmente, monitoramos sinais de demanda inbound (de onde vêm os leads não qualificados que descartamos hoje) como indicadores de segmentos com pull natural para o nosso produto.',
    },
    {
        bucketId: 3,
        question: 'Qual é a estimativa da {name} para sua participação de mercado atual e qual é a meta para os próximos 3 anos?',
        answer:   'Estimamos ter ~0,4% do nosso SAM atualmente. A meta para 3 anos é chegar a 5-6%, o que representaria uma multiplicação de ~13x da receita atual. Esse crescimento virá de expansão geográfica (capitais do Sul e Nordeste), novos segmentos verticais e o lançamento do plano enterprise.',
    },
    {
        bucketId: 3,
        question: 'Como a {name} monitora de forma proativa a saúde dos clientes para antecipar riscos de churn?',
        answer:   'Temos um health score automatizado que combina: frequência de login, uso das features principais, volume de transações e abertura de tickets de suporte. Clientes com health score caindo recebem contato proativo do CS em até 48 horas. Esse processo reduziu nosso churn involuntário em 35% nos últimos 6 meses.',
    },
    {
        bucketId: 3,
        question: 'Qual é o win rate da {name} em processos competitivos (quando o cliente está avaliando mais de um fornecedor)?',
        answer:   'Nosso win rate em processos competitivos formais é de 62%, que consideramos excelente para o nosso estágio. As razões mais citadas pelos clientes que nos escolheram são: velocidade de implementação, qualidade do suporte e custo-benefício. Quando perdemos, o principal motivo é preço (cliente escolheu solução mais barata).',
    },

    // -------------------------------------------------------------------------
    // BUCKET 4 — REGULATÓRIO/LEGAL (extra)
    // -------------------------------------------------------------------------
    {
        bucketId: 4,
        question: 'Como a {name} se prepara para eventuais inspeções ou auditorias de órgãos reguladores?',
        answer:   'Temos uma "regulatory readiness checklist" atualizada trimestralmente. Toda a documentação exigida por reguladores (contratos, políticas, registros de operação) é mantida organizada e auditável em nosso sistema de gestão documental. Simulamos auditorias internas anualmente com nosso advogado especialista.',
    },
    {
        bucketId: 4,
        question: 'Quais marcos regulatórios específicos do setor a {name} monitora mais de perto neste momento?',
        answer:   'No nosso setor, as principais discussões em curso são: atualização do marco regulatório de proteção de dados (reforço da LGPD), regulamentação de IA pelo governo federal e, no caso específico de produtos financeiros, as circulares do BACEN sobre open finance. Participamos de consultas públicas sobre todos esses temas.',
    },
    {
        bucketId: 4,
        question: 'Como a {name} lida com solicitações de exclusão ou portabilidade de dados por parte dos usuários (direitos LGPD)?',
        answer:   'Temos um processo automatizado via portal de privacidade que permite ao usuário solicitar exclusão, portabilidade ou retificação de dados com SLA de 15 dias úteis — bem abaixo do prazo legal de 15 dias corridos. Todos os pedidos são registrados em log auditável e respondem com confirmação automática.',
    },
    {
        bucketId: 4,
        question: 'A {name} tem política específica de proteção de dados de usuários menores de 18 anos?',
        answer:   'Sim. Nossa política proíbe explicitamente o cadastro de menores sem consentimento verificável dos pais ou responsáveis. Temos filtro de data de nascimento na coleta e processo de verificação adicional para perfis suspeitos. O tratamento de dados de menores segue o Estatuto da Criança e Adolescente além da LGPD.',
    },
    {
        bucketId: 4,
        question: 'Qual é a posição da {name} sobre a regulamentação de tokens e ativos digitais que está sendo discutida no Brasil e no mundo?',
        answer:   'Acompanhamos de perto as discussões do Banco Central e da CVM sobre o assunto. Nossa operação já foi estruturada de forma conservadora para se enquadrar nos cenários regulatórios mais restritivos que podem surgir. Acreditamos que regulamentação clara é benéfica para o mercado — traz legitimidade e proteção para investidores.',
    },
    {
        bucketId: 4,
        question: 'A {name} realiza análise formal de risco regulatório antes de entrar em um novo mercado ou lançar um novo produto?',
        answer:   'Sim, toda expansão de produto ou geográfica passa por uma análise de "regulatory fit" antes da decisão. Avaliamos: licenças necessárias, restrições setoriais, requisitos de localização de dados e riscos de compliance. Esse processo nos custou atrasos em duas ocasiões, mas nos poupou de problemas muito mais sérios.',
    },
    {
        bucketId: 4,
        question: 'Como a {name} trata a responsabilidade civil por erros ou falhas do produto que causem prejuízo ao cliente?',
        answer:   'Nossos contratos estabelecem responsabilidade limitada ao valor pago nos últimos 12 meses, exceto em casos de dolo ou negligência grave. Temos seguro de responsabilidade civil profissional que cobre esses cenários. Em casos de falha reconhecida, nossa política é de crédito pro rata — mantemos a relação com o cliente.',
    },
    {
        bucketId: 4,
        question: 'A {name} já enfrentou algum questionamento de concorrente sobre propriedade intelectual ou uso indevido de tecnologia?',
        answer:   'Não recebemos nenhuma notificação ou questionamento de PI até hoje. Nossa estratégia de desenvolvimento sempre priorizou construir do zero ou usar componentes open source com licenças compatíveis. Todos os colaboradores assinam clausulas de não-concorrência e não-solicitação alinhadas à legislação trabalhista vigente.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 5 — CRESCIMENTO/EXPANSÃO (extra)
    // -------------------------------------------------------------------------
    {
        bucketId: 5,
        question: 'Como a {name} define e mede se já atingiu o Product Market Fit?',
        answer:   'Usamos três sinais: (1) a pergunta de Sean Ellis — mais de 40% dos nossos usuários dizem que ficariam "muito desapontados" se o produto deixasse de existir (hoje estamos em 58%), (2) NPS consistentemente acima de 50, e (3) churn mensal abaixo de 2%. Os três indicadores estão no verde — acreditamos que temos PMF sólido no nosso ICP principal.',
    },
    {
        bucketId: 5,
        question: 'Qual foi o crescimento de MRR da {name} nos últimos 6 meses? Existe sazonalidade relevante?',
        answer:   'Crescemos a uma média de 14% ao mês nos últimos 6 meses, o que é acima da nossa meta de 10%. Existe leve sazonalidade no Q1 (janeiro e fevereiro são mais lentos por decisões de budget dos clientes) e pico no Q4. Nossa taxa de crescimento net (descontando o churn) foi de 11% ao mês no período.',
    },
    {
        bucketId: 5,
        question: 'Qual é a estratégia de customer success da {name} para reduzir o churn de clientes que já passaram dos 12 meses de contrato?',
        answer:   'Para clientes "maduros" (12+ meses), nosso foco muda de onboarding para expansão e renovação antecipada. Fazemos QBRs (Quarterly Business Reviews) para demonstrar o ROI entregue e identificar oportunidades de upsell. Contratos de 24 meses com desconto têm sido muito bem recebidos — hoje 38% da nossa base tem contrato plurianual.',
    },
    {
        bucketId: 5,
        question: 'Quais são as verticais de mercado que a {name} planeja atacar nos próximos 18 meses além do segmento atual?',
        answer:   'Identificamos duas verticais adjacentes com alto potencial: (1) empresas de médio porte no setor de serviços profissionais (advocacia, contabilidade, consultorias) e (2) redes de franquias com gestão descentralizada. Ambas têm as mesmas dores que nosso ICP atual e nosso produto requer adaptações menores para atendê-las.',
    },
    {
        bucketId: 5,
        question: 'A {name} prefere crescimento orgânico ou considera ativamente o crescimento inorgânico via aquisições?',
        answer:   'No estágio atual, crescimento orgânico é a prioridade absoluta — ainda temos muita runway no mercado que já conhecemos. Inorgânico pode entrar no horizonte em 3 a 4 anos, quando estivermos com caixa positivo e buscando acelerar a entrada em novos mercados. Monitoramos o ecossistema, mas sem urgência de agir.',
    },
    {
        bucketId: 5,
        question: 'Quais empresas a {name} usa como benchmarks de crescimento e por quê?',
        answer:   'Acompanhamos de perto a trajetória de Totvs (crescimento sustentável em SaaS B2B no Brasil), Loft (expansão geográfica agressiva mas com unit economics sólido) e Zendesk nos primeiros anos (excelência em CS e NPS alto como diferencial competitivo). Cada uma nos ensina algo diferente sobre como crescer com qualidade.',
    },
    {
        bucketId: 5,
        question: 'Como a {name} equilibra a velocidade de crescimento com a solidez operacional para não criar problemas à medida que escala?',
        answer:   'Seguimos a filosofia de "build the runway before you need it" — contratamos líderes de área com 6 meses de antecedência às necessidades previstas, documentamos processos enquanto são pequenos e não depois, e investimos em automação antes de sentir a dor. É mais lento no início mas evita crises custosas de crescimento desordenado.',
    },
    {
        bucketId: 5,
        question: 'Qual é o plano de contingência da {name} caso as metas de crescimento dos próximos 12 meses não sejam atingidas?',
        answer:   'Temos um "plan B" com cortes de custo identificados que reduziriam o burn rate em 40% sem comprometer as funções essenciais do negócio, estendendo a runway em mais 8 meses. Além disso, já temos relacionamento com três fundos para uma bridge round emergencial se necessário. Não esperamos precisar, mas estar preparado é parte de uma gestão responsável.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 6 — TOKENIZAÇÃO/INVESTIMENTO (extra)
    // -------------------------------------------------------------------------
    {
        bucketId: 6,
        question: 'Como os tokens {token} são emitidos tecnicamente? Existe um smart contract ou o processo é centralizado na plataforma?',
        answer:   'A emissão é gerenciada pela plataforma MesclaInvest em um registro centralizado e auditável. Optamos por essa abordagem para garantir conformidade com o marco regulatório vigente no Brasil e facilitar o processo de KYC/AML. A migração para um modelo on-chain é algo que avaliamos para o futuro, conforme o ambiente regulatório evolua.',
    },
    {
        bucketId: 6,
        question: 'Existe algum programa de benefícios ou bônus para investidores que mantiverem os tokens {token} por períodos mais longos?',
        answer:   'Estamos desenhando um programa de "loyalty tiers" para detentores de {token} de longo prazo, com benefícios como acesso antecipado a novas funcionalidades, participação em calls exclusivas com os fundadores e desconto em planos da {name}. Detalhes serão comunicados aos atuais investidores antes do lançamento.',
    },
    {
        bucketId: 6,
        question: 'Como a {name} pretende comunicar eventos relevantes (novos contratos, expansões, resultados) aos detentores do token {token}?',
        answer:   'Publicamos relatórios mensais de desempenho na plataforma MesclaInvest, acessíveis a todos os detentores de {token}. Eventos materiais (contratos relevantes, mudanças de liderança, marcos de crescimento) são comunicados via push notification e e-mail em até 48 horas do evento. Realizamos também calls trimestrais de resultados abertas a todos os investidores.',
    },
    {
        bucketId: 6,
        question: 'Qual é a política da {name} para emissão de novos tokens {token} no futuro? Existe risco de diluição dos atuais detentores?',
        answer:   'O total de tokens {token} é fixo e está definido no prospecto desta captação — não haverá emissões adicionais. Qualquer captação futura utilizará uma nova classe de tokens com estrutura própria, preservando integralmente a posição dos atuais detentores. Esse compromisso está documentado em nosso acordo de emissão.',
    },
    {
        bucketId: 6,
        question: 'Como os detentores do token {token} acompanham o desempenho financeiro e operacional da {name} ao longo do tempo?',
        answer:   'Todo detentor verificado de {token} tem acesso ao dashboard de investidor na plataforma MesclaInvest, que exibe: MRR atualizado mensalmente, número de clientes ativos, churn rate e os principais KPIs do negócio. Relatórios anuais auditados são disponibilizados no primeiro trimestre de cada ano.',
    },
    {
        bucketId: 6,
        question: 'A {name} está negociando parceria com alguma exchange ou plataforma de negociação para ampliar a liquidez do token {token}?',
        answer:   'Estamos em conversas preliminares com duas plataformas de tokens de equity no Brasil. Qualquer acordo desse tipo passará por análise jurídica e compliance cuidadosos, pois o ambiente regulatório ainda está em formação. Priorizamos fazer isso de forma correta, mesmo que isso signifique esperar o momento regulatório adequado.',
    },
    {
        bucketId: 6,
        question: 'Como o processo de KYC e AML funciona para investidores que querem adquirir tokens {token} na plataforma?',
        answer:   'A plataforma MesclaInvest realiza o processo de KYC/AML de todos os investidores antes de permitir a compra de qualquer token. O processo inclui verificação de identidade, origem de fundos para investimentos acima de determinado valor e checagem em listas de sanções internacionais. Todo o processo segue as diretrizes do COAF.',
    },
    {
        bucketId: 6,
        question: 'Caso a {name} seja adquirida por outra empresa no futuro, o que acontece com os detentores do token {token}?',
        answer:   'Em caso de M&A, o acordo de emissão do token {token} prevê que os detentores tenham direito a receber a sua proporção do valor de aquisição, calculada com base no valuation implícito do token na data do evento de liquidez. Os detalhes estão especificados no prospecto de emissão disponível na data room.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 7 — OPERAÇÕES (extra)
    // -------------------------------------------------------------------------
    {
        bucketId: 7,
        question: 'Como a {name} estrutura o processo de renovação de contratos com clientes existentes? Existe automação?',
        answer:   'Iniciamos o processo de renovação 90 dias antes do vencimento. O CS envia um relatório de valor entregue e abre negociação 60 dias antes. Temos 87% de taxa de renovação. Para contratos anuais, oferecemos condições especiais para upgrade de plano na renovação — isso gerou 23% de expansão de receita nas renovações do último trimestre.',
    },
    {
        bucketId: 7,
        question: 'Qual é a política de SLA da {name} para diferentes perfis de clientes (pequenas empresas vs. enterprise)?',
        answer:   'Para clientes Starter: suporte em horário comercial com SLA de 8 horas para incidentes normais e 4 horas para críticos. Para clientes Growth: SLA de 4 horas e 2 horas respectivamente. Para Enterprise: suporte 24/7 com SLA de 1 hora para incidentes críticos e um gerente de conta dedicado. Penalidades de SLA estão previstas nos contratos Enterprise.',
    },
    {
        bucketId: 7,
        question: 'A {name} tem um processo de "save" para clientes que pedem cancelamento? Qual é a taxa de salvamento?',
        answer:   'Sim, todo pedido de cancelamento aciona automaticamente uma reunião de "save" com um especialista sênior em CS dentro de 24 horas. Descobrimos que 65% dos cancelamentos são por problemas resolvíveis (falta de uso de alguma feature, mudança de interlocutor, problema pontual de budget). Nossa taxa de salvamento está em 42% — algo que nos orgulhamos muito.',
    },
    {
        bucketId: 7,
        question: 'Como a {name} estrutura a cobrança dos seus serviços — mensal, anual ou por volume de uso?',
        answer:   'Oferecemos as três modalidades. A maioria dos clientes começa com mensal e migra para anual após 3 a 4 meses — oferecemos 15% de desconto para contratos anuais pagos à vista. Estamos lançando um modelo pay-per-use para clientes com demanda muito irregular, o que deve ampliar nosso mercado endereçável.',
    },
    {
        bucketId: 7,
        question: 'Como a {name} gerencia a dependência de fornecedores críticos para a operação? Existe plano de contingência?',
        answer:   'Para cada fornecedor crítico (provedores de cloud, gateway de pagamento, plataforma de e-mail), temos um fornecedor alternativo homologado e um runbook de migração testado anualmente. Adicionalmente, priorizamos fornecedores com SLA enterprise e suporte 24/7 para minimizar o risco de impacto na nossa operação.',
    },
    {
        bucketId: 7,
        question: 'Os processos operacionais críticos da {name} estão documentados? Como vocês garantem que o conhecimento não fique "na cabeça" de uma pessoa?',
        answer:   'Utilizamos Notion como base de conhecimento centralizada, com playbooks documentados para todos os processos críticos — vendas, CS, engenharia, financeiro e jurídico. Todo processo novo só se torna oficial quando está documentado no Notion. Isso foi especialmente valioso em duas saídas de colaboradores importantes sem impacto operacional.',
    },
    {
        bucketId: 7,
        question: 'Qual é o processo de escalada da {name} quando um cliente enfrenta um incidente crítico fora do horário comercial?',
        answer:   'Para clientes Enterprise, temos plantão de incidentes 24/7 com um engenheiro de guardia que responde em até 15 minutos. Para os demais, temos uma página de status pública e um canal de emergência que é monitorado a cada 2 horas fora do horário comercial. Incidentes críticos têm postmortem público em até 72 horas da resolução.',
    },
    {
        bucketId: 7,
        question: 'Quais são os KPIs específicos que a {name} usa para avaliar a performance do time de customer success?',
        answer:   'Os principais KPIs do time de CS são: Net Revenue Retention (NRR), taxa de renovação, health score médio da carteira, tempo médio de resposta a alertas de risco de churn e Net Promoter Score dos clientes ativos. Esses indicadores são revisados em weekly do time e impactam diretamente na remuneração variável do CS.',
    },

    // =========================================================================
    // NOVOS BUCKETS (8–11)
    // =========================================================================

    // -------------------------------------------------------------------------
    // BUCKET 8 — ESG / IMPACTO SOCIAL
    // -------------------------------------------------------------------------
    {
        bucketId: 8,
        question: 'Qual é o impacto social positivo que a {name} gera com sua operação? Como vocês quantificam esse impacto?',
        answer:   'Medimos nosso impacto através de indicadores específicos: número de pessoas impactadas positivamente, redução de custo ou tempo para os usuários e indicadores de inclusão. Publicamos um relatório de impacto anual com metodologia auditável. Acreditamos que empresas que não medem impacto não conseguem maximizá-lo.',
    },
    {
        bucketId: 8,
        question: 'A {name} tem metas formais de ESG (Environmental, Social, Governance)? Como elas são integradas à estratégia do negócio?',
        answer:   'Sim, integramos ESG à nossa estratégia operacional, não tratamos como um "departamento de marketing verde". No eixo Social: metas de diversidade e inclusão na equipe. No Ambiental: operação cloud-native com neutralização de carbono. No Governance: estrutura transparente de reporting para investidores.',
    },
    {
        bucketId: 8,
        question: 'Como a {name} mede e compensa sua pegada de carbono nas operações?',
        answer:   'Calculamos nossa pegada de carbono anualmente considerando: consumo de energia dos escritórios, viagens corporativas e emissões indiretas da nossa infraestrutura de cloud (Scope 1, 2 e 3). Compensamos 100% via compra de créditos de carbono certificados de projetos nacionais de reflorestamento.',
    },
    {
        bucketId: 8,
        question: 'A {name} tem políticas formais de diversidade, equidade e inclusão para a composição da equipe e processos seletivos?',
        answer:   'Adotamos recrutamento às cegas para os processos seletivos (sem foto, nome ou escola na triagem inicial), metas de representação de gênero e raça nos cargos de liderança e programas de mentoria interna para grupos sub-representados. Hoje 44% do time são mulheres e 38% são pessoas pretas ou pardas — acima da média do setor de tecnologia.',
    },
    {
        bucketId: 8,
        question: 'Como a {name} contribui para os Objetivos de Desenvolvimento Sustentável (ODS) da ONU mais relevantes para o seu negócio?',
        answer:   'Mapeamos nossa contribuição para quatro ODS principais: ODS 8 (Trabalho decente e crescimento econômico), ODS 9 (Indústria, inovação e infraestrutura), ODS 10 (Redução das desigualdades) e ODS 17 (Parcerias). Relatamos nosso progresso nesses ODS no relatório de impacto anual.',
    },
    {
        bucketId: 8,
        question: 'Existe algum programa da {name} voltado especificamente para comunidades locais ou grupos vulneráveis?',
        answer:   'Sim, reservamos 5% do nosso plano Starter para organizações do terceiro setor com preço social (70% de desconto). Adicionalmente, temos um programa de estágio voltado para jovens de escolas públicas que quer inserir talentos de baixa renda no mercado de tecnologia. São 4 vagas por semestre com bolsa acima do mercado.',
    },
    {
        bucketId: 8,
        question: 'A {name} possui alguma certificação de impacto social, como B Corp ou similar? Existe interesse em buscá-la?',
        answer:   'Iniciamos o processo de certificação B Corp em 2025 e estamos na fase de avaliação de impacto (BIA). Esperamos concluir o processo e receber a certificação ainda este ano. A certificação B Corp é relevante para nós tanto como validação externa do nosso compromisso com impacto quanto para atrair clientes e colaboradores alinhados a esse propósito.',
    },
    {
        bucketId: 8,
        question: 'A {name} já recebeu algum reconhecimento, prêmio ou menção em mídia relevante pela sua atuação de impacto social ou ambiental?',
        answer:   'Fomos selecionados para o programa de startups de impacto da Endeavor no último ciclo e recebemos menção honrosa no prêmio FIESP de Inovação Sustentável. Essas reconhecimentos validam nossa abordagem e abrem portas importantes para novos clientes, parceiros e investidores alinhados com o propósito da {name}.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 9 — INTELIGÊNCIA ARTIFICIAL E DADOS
    // -------------------------------------------------------------------------
    {
        bucketId: 9,
        question: 'Como a {name} utiliza inteligência artificial ou machine learning no produto? Quais problemas específicos a IA resolve?',
        answer:   'Usamos ML em três frentes: (1) recomendação personalizada de conteúdo/ações para cada usuário, (2) detecção de anomalias para alertas proativos e (3) predição de churn para acionar o CS com antecedência. Esses modelos foram desenvolvidos internamente com dados proprietários, o que torna a {name} difícil de replicar.',
    },
    {
        bucketId: 9,
        question: 'Os dados gerados pela operação da {name} são um diferencial competitivo? Como vocês protegem esse ativo?',
        answer:   'Os dados são nosso maior moat. Acumulamos mais de 18 meses de dados comportamentais proprietários que nossos modelos usam para gerar insights cada vez mais precisos. Protegemos esse ativo com: anonimização, controles de acesso granulares, contratos com cláusulas rígidas de uso de dados e uma política de data governance interna.',
    },
    {
        bucketId: 9,
        question: 'Como a {name} garante a qualidade e a integridade dos dados usados para treinar os modelos de IA?',
        answer:   'Temos um pipeline de dados com validações automáticas em cada etapa de ingestão — dados fora de padrão são sinalizados para revisão antes de entrar nos datasets de treinamento. Realizamos auditorias periódicas de qualidade de dados e temos uma equipe dedicada de Data Engineering que mantém esse pipeline.',
    },
    {
        bucketId: 9,
        question: 'A {name} usa modelos de IA de terceiros (como APIs da OpenAI ou Google) ou desenvolve modelos proprietários?',
        answer:   'Usamos uma abordagem híbrida: modelos de fundação de terceiros (como GPT e Gemini) para tarefas de linguagem natural, fine-tunados com dados nossos para especialização no domínio. Para os modelos preditivos core do produto (recomendação, previsão de churn), desenvolvemos e treinamos internamente — são esses que geram a vantagem competitiva.',
    },
    {
        bucketId: 9,
        question: 'Como a {name} lida com o risco de viés (bias) nos modelos de IA, especialmente em decisões que afetam os usuários?',
        answer:   'Realizamos auditorias de bias em todos os modelos antes do deploy e trimestralmente em produção. Para qualquer modelo que impacta decisões relevantes para o usuário, exigimos que ele passe pelo nosso "fairness checklist", que avalia performance por grupos demográficos. Temos uma política de model cards pública para transparência.',
    },
    {
        bucketId: 9,
        question: 'Qual é a política da {name} sobre o uso de dados de clientes para treinamento de modelos de IA?',
        answer:   'Somente usamos dados de clientes para treinamento de modelos com consentimento explícito, conforme nossos termos de serviço. Os dados são sempre anonimizados antes do treinamento e nunca expostos em outputs do modelo. Clientes que não desejam contribuir podem optar por isso nas configurações de privacidade.',
    },
    {
        bucketId: 9,
        question: 'Como a {name} monitora e melhora a performance dos seus modelos de IA após o deploy em produção?',
        answer:   'Temos um sistema de MLOps com monitoramento contínuo de métricas de performance dos modelos (acurácia, recall, drift de dados). Quando um modelo começa a degradar, o sistema alerta automaticamente o time de ML. Realizamos retraining automático a cada 30 dias e retraining manual em caso de drift significativo.',
    },
    {
        bucketId: 9,
        question: 'A {name} tem capacidade de explicar as decisões geradas pelos seus modelos de IA para os usuários (explainable AI)?',
        answer:   'Sim, implementamos explainability em todos os modelos que geram recomendações ou alertas para os usuários. Por exemplo, quando o sistema sugere uma ação, exibe os fatores principais que levaram a essa sugestão. Isso aumenta a confiança do usuário no produto e reduz o fenômeno de "black box" que afasta adoção de IA.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 10 — VENDAS / GO-TO-MARKET
    // -------------------------------------------------------------------------
    {
        bucketId: 10,
        question: 'Qual é o ciclo médio de vendas da {name}, do primeiro contato ao contrato assinado?',
        answer:   'Para clientes SMB, o ciclo médio é de 18 dias. Para médias empresas, 35 dias. Para enterprise, 75 dias. O maior tempo de ciclo no enterprise se deve ao processo de procurement e aprovação jurídica, não à avaliação técnica — nosso produto passa nas provas de conceito com facilidade.',
    },
    {
        bucketId: 10,
        question: 'A {name} tem time de vendas próprio ou depende de canais indiretos (revendas, integradores, parceiros)?',
        answer:   'Temos um time de vendas direto (3 AEs e 2 SDRs) que responde pela maior parte da receita. Paralelamente, construímos um canal indireto com 5 parceiros integradores homologados que hoje representa 22% da receita nova. A meta é chegar a 40% de receita via parceiros até o final de 2026.',
    },
    {
        bucketId: 10,
        question: 'Como a {name} estrutura sua estratégia de go-to-market ao entrar em uma nova cidade ou segmento vertical?',
        answer:   'Nosso playbook de entrada tem 4 fases: (1) hunting — identificação dos 50 melhores prospects locais via dados, (2) seed — fecha os primeiros 3 a 5 clientes âncora com muito suporte, (3) land and expand — usa os cases locais para gerar indicações e credibilidade, (4) scale — replica com time comercial dedicado após validação.',
    },
    {
        bucketId: 10,
        question: 'Como a {name} qualifica leads no topo do funil? Quais critérios definem um MQL (Marketing Qualified Lead)?',
        answer:   'Um MQL na {name} precisa atender: porte de empresa (5 a 500 funcionários), setor elegível, cargo de decisão ou influência, e algum sinal de intenção (visita a página de pricing, download de case, solicitação de demo). Leads que atendem esses critérios passam para o time de vendas com um score de prioridade calculado automaticamente.',
    },
    {
        bucketId: 10,
        question: 'A {name} tem uma estratégia de upsell e cross-sell estruturada para clientes existentes? Qual é o impacto no NRR?',
        answer:   'Sim, upsell e cross-sell são parte central do nosso modelo de crescimento. Identificamos clientes com potencial de expansão via health score e "expansion signals" (uso próximo ao limite do plano, novas contratações no cliente, feedback positivo). Nossa taxa de expansão mensal é de 3,2%, o que leva o NRR para 118%.',
    },
    {
        bucketId: 10,
        question: 'Como a {name} usa marketing digital (SEO, paid, social) para geração de demanda? Quais canais têm melhor retorno?',
        answer:   'SEO e conteúdo são nossa base (40% dos leads inbound) — investimos há 18 meses e agora colhemos resultados com baixo custo marginal. Paid search é o segundo canal (25% dos leads), com ROAS positivo a partir do primeiro mês. LinkedIn Ads funciona bem para enterprise. TikTok e Instagram não geraram ROI relevante para o nosso ICP B2B.',
    },
    {
        bucketId: 10,
        question: 'Qual é a diferença na abordagem de vendas da {name} para clientes enterprise versus pequenas e médias empresas?',
        answer:   'Para SMB: ciclo curto, self-service, trial, demo automatizada, foco em rapidez e simplicidade. Para enterprise: ciclo longo, consultivo, prova de conceito, envolvimento de múltiplos stakeholders, customizações contratuais e SLA dedicado. Temos equipes e playbooks completamente diferentes para cada segmento.',
    },
    {
        bucketId: 10,
        question: 'Como a {name} estrutura as metas e os incentivos do time de vendas?',
        answer:   'Nosso time de vendas tem base fixa competitiva (70% da remuneração) e variável agressiva (30% em quota atingida, com acelerador de 1,5x acima de 110% da meta). As metas são mensais com revisão trimestral. Além do volume de receita nova, avaliamos qualidade da venda — contratos renovados no prazo contam como fator multiplicador.',
    },

    // -------------------------------------------------------------------------
    // BUCKET 11 — PRODUTO / EXPERIÊNCIA DO USUÁRIO
    // -------------------------------------------------------------------------
    {
        bucketId: 11,
        question: 'Como a {name} pesquisa as necessidades dos usuários antes de começar a desenvolver novas funcionalidades?',
        answer:   'Seguimos um processo estruturado de discovery: entrevistas com 5 a 8 usuários representativos por iniciativa, análise de dados de uso para validar hipóteses, e revisão de tickets de suporte e NPS detractors. Só levamos uma iniciativa para desenvolvimento quando temos evidências de 3 fontes independentes confirmando a dor.',
    },
    {
        bucketId: 11,
        question: 'A {name} tem um Design System estabelecido? Como ele é mantido e evoluído?',
        answer:   'Sim, temos um Design System documentado no Figma com componentes padronizados para todas as interfaces. Ele é mantido pelo time de design com contribuições dos engenheiros frontend. Toda nova funcionalidade usa os componentes do DS primeiro — custom só quando absolutamente necessário. Isso reduziu o tempo de design e desenvolvimento em 35%.',
    },
    {
        bucketId: 11,
        question: 'Como a {name} garante a acessibilidade do produto para usuários com deficiência visual, motora ou cognitiva?',
        answer:   'Seguimos as diretrizes WCAG 2.1 nível AA como padrão mínimo. Realizamos testes de acessibilidade com usuários reais com deficiência a cada ciclo major de produto. O produto suporta leitores de tela (NVDA, VoiceOver), navegação por teclado e não depende exclusivamente de cor para transmitir informações.',
    },
    {
        bucketId: 11,
        question: 'A {name} oferece versão gratuita, trial ou freemium do produto? Como essa estratégia se conecta à aquisição de clientes?',
        answer:   'Oferecemos trial gratuito de 14 dias sem cartão de crédito para todos os planos. Nossa taxa de conversão trial-to-paid é de 31%, acima da média do setor (18-22%). O trial é fundamentalmente parte da nossa estratégia de PLG — queremos que o usuário experimente o valor antes de qualquer conversa com vendas.',
    },
    {
        bucketId: 11,
        question: 'Como a {name} lida com a complexidade de atender múltiplos perfis de usuário (admin, operador, visualizador) no mesmo produto?',
        answer:   'Desenvolvemos um sistema de papéis e permissões granular que permite configurar exatamente o que cada perfil pode ver e fazer. A interface adapta-se ao contexto do usuário logado, mostrando apenas o que é relevante para o seu papel. Isso reduziu a curva de aprendizado e os erros operacionais dos nossos clientes.',
    },
    {
        bucketId: 11,
        question: 'Qual é a estratégia da {name} para reduzir a fricção no processo de cadastro e primeiros passos do usuário?',
        answer:   'Implementamos um onboarding progressivo: o usuário começa a usar o produto com o mínimo de configuração e vai desbloqueando funcionalidades conforme avança. Usamos tooltips contextuais, checklists de ativação e e-mails de nurturing comportamentais. Esse redesign do onboarding aumentou nossa taxa de ativação em 42% nos primeiros 30 dias.',
    },
    {
        bucketId: 11,
        question: 'Como a {name} adapta o produto para as especificidades regionais do Brasil (diferenças culturais, regulatórias e de infraestrutura)?',
        answer:   'O Brasil é diverso demais para ser tratado como um mercado único. Temos configurações regionais para impostos estaduais, adaptações de linguagem para diferentes regiões e otimizações de performance para regiões com conectividade mais instável. Nosso time de produto inclui pessoas de fora do eixo SP-RJ justamente para garantir essa sensibilidade regional.',
    },
    {
        bucketId: 11,
        question: 'A {name} tem uma comunidade de usuários ou programa de co-criação onde clientes participam do desenvolvimento do produto?',
        answer:   'Sim, temos um programa "Power Users" com 45 clientes selecionados que testam funcionalidades em preview exclusivo e participam mensalmente de workshops de produto. Esses clientes ajudaram a moldar 60% das funcionalidades lançadas no último ano. A comunidade também serve como rede de indicação — 30% das nossas indicações vêm de Power Users.',
    },
];

// Questions that are always unanswered — simulating perguntas aguardando resposta dos fundadores
const UNANSWERED_QUESTIONS: string[] = [
    'Quando a {name} pretende lançar um aplicativo mobile nativo para iOS e Android?',
    'Quais integrações com sistemas de terceiros a {name} está priorizando para os próximos meses?',
    'A {name} considera abrir o capital (IPO) no Brasil ou no exterior em algum horizonte de tempo?',
    'Como a {name} planeja lidar com a entrada de plataformas internacionais no mercado brasileiro?',
    'A {name} tem estratégia de conteúdo ou inbound marketing sendo desenvolvida para 2026?',
    'Existe algum plano de franchising ou licenciamento do modelo da {name} para outros operadores?',
    'Como a {name} mensura e reporta formalmente o seu impacto social ou ambiental?',
    'A {name} tem ou planeja lançar um programa de indicações ou afiliados para aquisição de clientes?',
    'Quais são as funcionalidades que os clientes da {name} mais pedem e ainda não estão no produto?',
    'A {name} já participou de alguma aceleradora ou programa de open innovation? Há planos para isso?',
    'Como a {name} está se posicionando para capturar o crescimento gerado pela IA generativa no setor?',
    'Qual é a política de retenção de talentos da {name}? Como vocês evitam o turnover no time técnico?',
    'A {name} tem parceria com alguma universidade ou instituto de pesquisa para desenvolvimento tecnológico?',
    'Existe algum plano B para a {name} caso o crescimento esperado não se concretize nos próximos 12 meses?',
    'Como a {name} está preparada para um cenário de recessão econômica que possa reduzir o poder de compra dos clientes?',
    'Quando a {name} vai disponibilizar uma API pública para que desenvolvedores e parceiros possam integrar ao produto?',
    'A {name} tem planos de lançar um programa de certificação oficial para usuários avançados ou parceiros implementadores?',
    'Qual é o roadmap de acessibilidade da {name} para garantir que pessoas com deficiência possam usar o produto sem barreiras?',
    'A {name} já considerou um modelo de assinatura anual com desconto expressivo para aumentar o LTV e reduzir churn?',
    'Qual é a estratégia da {name} diante de um cenário de alta de juros que encarece o capital de giro para clientes?',
    'Como a {name} planeja usar os dados coletados dos usuários para criar novos produtos ou linhas de receita complementares?',
    'Existe alguma funcionalidade que a {name} desenvolveu mas decidiu não lançar? Qual foi o aprendizado desse processo?',
    'Como a {name} se posiciona sobre privacidade dos dados dos usuários frente ao avanço da IA generativa no setor?',
    'A {name} tem planos de criar uma fundação, instituto ou braço de impacto social associado ao crescimento do negócio?',
    'Qual é a visão de longo prazo dos fundadores da {name} — exit via M&A, IPO ou construção de uma empresa de geração de caixa?',
    'A {name} já mapeou formalmente os riscos de concentração de receita em poucos grandes clientes?',
    'Como a {name} pretende garantir a continuidade operacional em caso de ausência prolongada de um dos fundadores?',
    'Quais parcerias com universidades ou institutos de P&D a {name} está negociando para os próximos 12 meses?',
    'A {name} tem ou planeja ter um conselho de administração formal com membros externos independentes?',
    'Como a {name} avalia o risco de que uma das big techs (Google, Microsoft, Meta) lance um produto concorrente gratuito?',
    'Quais são as três maiores apostas de produto que a {name} está fazendo para os próximos 24 meses?',
    'Como a {name} pretende usar inteligência artificial generativa para melhorar a experiência do produto nos próximos meses?',
    'A {name} já considerou uma estratégia de marketplace — permitir que terceiros construam integrações e extensões no produto?',
    'Como o time da {name} se mantém atualizado sobre as tendências tecnológicas e de negócio mais relevantes para o setor?',
];


/**
 * SEED
 */

async function seed(): Promise<void>
{
    const app = initializeApp({projectId: 'mesclainvest-eda16'});
    const db  = getFirestore(app);

    console.log('Seeding Q&A for all startups...');
    console.log(`  Firestore: ${process.env.FIRESTORE_EMULATOR_HOST}\n`);

    // 1. fetch all startups
    const startupsSnapshot = await db.collection('startups').orderBy('name').get();
    if (startupsSnapshot.empty)
    {
        console.error('No startups found in Firestore. Run seed:startups first.');
        process.exit(1);
    }
    const startups = startupsSnapshot.docs.map(doc => ({id: doc.id, ...doc.data()} as StartupDocument));

    // 2. fetch all users
    const usersSnapshot = await db.collection('users').get();
    if (usersSnapshot.empty)
    {
        console.error('No users found in Firestore. Run seed:users first.');
        process.exit(1);
    }
    const users: UserInfo[] = usersSnapshot.docs
        .map(doc => ({uid: doc.data().uid as string, full_name: doc.data().full_name as string}))
        .filter(u => u.uid && u.full_name);

    console.log(`Found ${startups.length} startups and ${users.length} users.\n`);

    // 3. build the combined template pool once
    //    each entry: { text, potentialAnswer (null = always unanswered) }
    const templatePool: {text: string; potentialAnswer: string | null}[] = [
        ...QA_ANSWERED.map(t => ({text: t.question, potentialAnswer: t.answer})),
        ...UNANSWERED_QUESTIONS.map(q => ({text: q, potentialAnswer: null})),
    ];

    let totalCreated = 0;
    let totalSkipped = 0;

    for (const startup of startups)
    {
        const qCol = db
            .collection('startups')
            .doc(startup.id)
            .collection('questions');

        // idempotency: skip startups that already have questions
        const existing = await qCol.limit(1).get();
        if (!existing.empty)
        {
            console.log(`  - Skip "${startup.name}" (already has questions)`);
            totalSkipped++;
            continue;
        }

        const h = hashCode(startup.id);

        // 8–13 questions per startup, deterministic per startup
        const numQuestions = 8 + (h % 6);

        // deterministically shuffle the template pool for this startup
        const shuffled = seededShuffle(templatePool, h);
        const selected = shuffled.slice(0, numQuestions);

        let questionsCreated = 0;

        for (let qi = 0; qi < selected.length; qi++)
        {
            const template  = selected[qi];
            const slotHash  = hashCode(`${startup.id}-q${qi}`);

            const questionText = fill(template.text, startup.name, startup.token_name);

            // decide if this question actually gets an answer
            // always-unanswered templates: never answered
            // answered templates: 75% chance of having the answer included, 25% left pending
            const hasAnswer = template.potentialAnswer !== null && (slotHash % 4 !== 0);
            const answerText = hasAnswer
                ? fill(template.potentialAnswer!, startup.name, startup.token_name)
                : null;

            // is_private: ~22% of questions are private (only for questions that have answers,
            // since unanswered public questions are more common in real platforms)
            const isPrivate = hasAnswer && (slotHash % 9 < 2);

            // pick a different user per slot, spread evenly across the user pool
            const userIdx = (h + qi * 13) % users.length;
            const user    = users[userIdx];

            // timestamps — questions spread over the past 5–120 days
            const questionDaysAgo  = 5 + (slotHash % 116);
            const createdAt        = daysAgo(questionDaysAgo);
            // answer comes 1–5 days after the question
            const answerDelayDays  = 1 + (slotHash % 5);
            const answeredDaysAgo  = Math.max(0, questionDaysAgo - answerDelayDays);
            const answeredAt       = hasAnswer ? daysAgo(answeredDaysAgo) : null;

            const question: Omit<QuestionDocument, 'id'> = {
                'answer':      answerText,
                'answered_at': answeredAt,
                'author_name': user.full_name,
                'author_uid':  user.uid,
                'created_at':  createdAt,
                'is_private':  isPrivate,
                'startup_id':  startup.id,
                'text':        questionText,
            };

            await qCol.add(question);
            questionsCreated++;
            totalCreated++;
        }

        const answeredCount = selected.filter((t, qi) =>
        {
            const sh = hashCode(`${startup.id}-q${qi}`);
            return t.potentialAnswer !== null && (sh % 4 !== 0);
        }).length;
        const privateCount = selected.filter((t, qi) =>
        {
            const sh = hashCode(`${startup.id}-q${qi}`);
            const ha = t.potentialAnswer !== null && (sh % 4 !== 0);
            return ha && (sh % 9 < 2);
        }).length;

        console.log(
            `✓ "${startup.name.padEnd(20)}" — ` +
            `${questionsCreated} perguntas  ` +
            `(${answeredCount} respondidas, ${questionsCreated - answeredCount} pendentes, ` +
            `${privateCount} privadas)`,
        );
    }

    console.log(`\nSeed complete.`);
    console.log(`  Total questions created : ${totalCreated}`);
    console.log(`  Startups seeded         : ${startups.length - totalSkipped}`);
    console.log(`  Startups skipped        : ${totalSkipped}`);
}


seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
