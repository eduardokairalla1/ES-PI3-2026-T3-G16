// Eduardo Kairalla - 24024241

// Help & Support screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- DATA ---

/// I represent a help section with a title, icon, and list of FAQ items.
class _Section {
  final String title;
  final IconData icon;
  final List<_Item> items;
  const _Section({required this.title, required this.icon, required this.items});
}

/// I represent a single FAQ question and answer pair.
class _Item {
  final String question;
  final String answer;
  const _Item(this.question, this.answer);
}

const _sections = [
  _Section(
    title: 'Começando',
    icon: Icons.rocket_launch_outlined,
    items: [
      _Item(
        'O que é o Mescla Invest?',
        'O Mescla Invest é uma plataforma de investimento em startups baseada em tokenização. '
        'Cada startup cadastrada emite uma quantidade limitada de tokens que representam uma fração do seu valor. '
        'Você pode comprar tokens diretamente das startups (mercado primário) ou negociá-los com outros investidores no Balcão (mercado secundário).',
      ),
      _Item(
        'Como fazer meu primeiro depósito?',
        'No Dashboard, toque no botão "Depositar". Digite o valor desejado e confirme. '
        'O saldo será creditado imediatamente na sua carteira virtual e estará disponível para investimento.',
      ),
      _Item(
        'Existe valor mínimo para investir?',
        'Sim. O valor mínimo por operação é de R\$ 1,00. Não há valor mínimo para depósito, '
        'mas recomendamos ao menos R\$ 50,00 para conseguir adquirir tokens de forma significativa.',
      ),
    ],
  ),
  _Section(
    title: 'Tokens & Mercado',
    icon: Icons.token_outlined,
    items: [
      _Item(
        'O que são tokens de startup?',
        'Tokens são unidades digitais que representam uma fração do valor de uma startup. '
        'Cada empresa define uma quantidade máxima de tokens ao se cadastrar na plataforma (oferta fixa). '
        'Ao comprar tokens, você se torna um micro-investidor daquela startup e seu patrimônio varia conforme o valor do ativo.',
      ),
      _Item(
        'O que é escassez de tokens?',
        'Cada startup emite um número fixo e imutável de tokens. Conforme investidores compram, '
        'o estoque disponível no mercado primário diminui. '
        'Quando todos os tokens são vendidos, não é mais possível comprar diretamente da startup — '
        'a negociação passa a ocorrer exclusivamente no Balcão, entre investidores. '
        'A escassez tende a valorizar os tokens no mercado secundário.',
      ),
      _Item(
        'Qual a diferença entre mercado primário e Balcão?',
        'Mercado Primário: você compra tokens diretamente da startup ao preço definido pela Bonding Curve. '
        'O dinheiro vai para a startup e o preço sobe a cada compra.\n\n'
        'Balcão (Mercado Secundário): você negocia com outros investidores. '
        'O preço é definido pela oferta e demanda — pode estar acima ou abaixo do preço primário. '
        'Ideal para quem quer comprar tokens de startups com estoque primário esgotado, ou para investidores que desejam realizar lucro.',
      ),
      _Item(
        'Como comprar tokens de uma startup?',
        '1. Acesse a aba "Startups" e escolha uma startup.\n'
        '2. Na tela de detalhes, veja o preço atual e a barra de tokens disponíveis.\n'
        '3. Toque em "Comprar" e informe a quantidade desejada.\n'
        '4. Confirme a operação — o valor será debitado do seu saldo disponível.',
      ),
      _Item(
        'Como vender tokens no Balcão?',
        '1. Acesse a aba "Balcão".\n'
        '2. Selecione a startup cujos tokens deseja vender.\n'
        '3. Crie uma ordem de venda informando quantidade e preço por token.\n'
        '4. Aguarde um comprador aceitar sua ordem. Quando executada, o valor é creditado na sua carteira.',
      ),
      _Item(
        'O que acontece se ninguém comprar minha ordem no Balcão?',
        'Sua ordem permanece ativa até que seja executada ou cancelada por você. '
        'Você pode cancelar uma ordem aberta a qualquer momento pelo Balcão, '
        'e os tokens voltam para a sua carteira imediatamente.',
      ),
    ],
  ),
  _Section(
    title: 'Carteira & Patrimônio',
    icon: Icons.account_balance_wallet_outlined,
    items: [
      _Item(
        'O que é saldo disponível?',
        'É o valor em reais que você tem livre para investir ou sacar. '
        'Aumenta com depósitos e vendas de tokens; diminui com compras de tokens e saques.',
      ),
      _Item(
        'O que é patrimônio total?',
        'É a soma do seu saldo disponível com o valor atual de todos os tokens que você possui. '
        'O valor dos tokens é recalculado em tempo real com base no preço atual de cada startup.',
      ),
      _Item(
        'Como interpretar o gráfico de Evolução do Patrimônio?',
        'O gráfico mostra como seu patrimônio total variou ao longo do período selecionado (7 dias, 1 mês, etc.). '
        'Uma curva verde indica crescimento; vermelha indica queda. '
        'O gráfico reflete tanto movimentações financeiras (depósitos/saques) quanto a valorização ou desvalorização dos seus tokens.',
      ),
      _Item(
        'Como exportar meu extrato?',
        'No Dashboard, toque em "Extrato". Na tela do extrato, toque no ícone de PDF no canto superior direito. '
        'Um arquivo PDF estilizado com todas as transações do mês será gerado e disponibilizado para download ou compartilhamento.',
      ),
    ],
  ),
  _Section(
    title: 'Segurança',
    icon: Icons.security_outlined,
    items: [
      _Item(
        'O que é a autenticação 2FA?',
        'A autenticação de dois fatores (2FA) adiciona uma camada extra de proteção. '
        'Além da senha, você precisará confirmar o login com um código de 6 dígitos gerado por um app autenticador '
        '(Google Authenticator, Authy, etc.). Recomendamos fortemente ativá-la.',
      ),
      _Item(
        'Como ativar o 2FA?',
        '1. Acesse a aba "Perfil".\n'
        '2. No card de Autenticação 2FA, toque no toggle para ativar.\n'
        '3. Escaneie o QR code com seu app autenticador.\n'
        '4. Digite o código de 6 dígitos gerado para confirmar a ativação.',
      ),
      _Item(
        'Minha conta pode ser bloqueada?',
        'Sim. Múltiplas tentativas de login com senha incorreta podem resultar em bloqueio temporário da conta. '
        'Caso isso ocorra, aguarde alguns minutos ou redefina sua senha pelo fluxo de recuperação.',
      ),
    ],
  ),
  _Section(
    title: 'Conta & Perfil',
    icon: Icons.person_outline,
    items: [
      _Item(
        'Como atualizar meus dados?',
        'Acesse "Perfil" → "Configurações". Lá você pode alterar seu nome, telefone e foto de perfil. '
        'CPF e data de nascimento não podem ser alterados após o cadastro.',
      ),
      _Item(
        'Como alterar minha foto de perfil?',
        'Em "Configurações", toque na foto atual (ou no ícone de câmera). '
        'Escolha uma imagem da galeria do seu dispositivo e salve. '
        'A foto é atualizada em todos os lugares da plataforma.',
      ),
      _Item(
        'Posso excluir minha conta?',
        'Para solicitar a exclusão da sua conta e de todos os seus dados, '
        'entre em contato pelo e-mail suporte@mesclainvest.com.br com o assunto "Exclusão de conta". '
        'O processo leva até 30 dias úteis conforme a LGPD.',
      ),
    ],
  ),
  _Section(
    title: 'Perguntas Frequentes',
    icon: Icons.help_outline,
    items: [
      _Item(
        'Os investimentos são reais?',
        'Não. O Mescla Invest é uma plataforma simulada, desenvolvida como projeto acadêmico na PUC-Campinas. '
        'Nenhum valor real é transacionado. Os saldos, tokens e startups são fictícios para fins educacionais.',
      ),
      _Item(
        'Por que o preço do meu token variou?',
        'O preço dos tokens reflete o preço atual de mercado da startup, que sobe conforme novos tokens são vendidos no primário '
        'e flutua no Balcão conforme a oferta e demanda entre investidores. '
        'Variações são normais e esperadas.',
      ),
      _Item(
        'O que significa "+0.00%" na variação do investimento?',
        'Indica que o preço atual do token é igual ao seu preço médio de compra — '
        'você não teve lucro nem prejuízo até o momento.',
      ),
      _Item(
        'Posso ter tokens de mais de uma startup?',
        'Sim. Você pode diversificar seu portfólio investindo em quantas startups quiser, '
        'desde que tenha saldo disponível. Todos os seus ativos aparecem consolidados na aba "Carteira".',
      ),
      _Item(
        'Com que frequência os dados são atualizados?',
        'Os dados do Dashboard e da Carteira são carregados a cada vez que você acessa as telas. '
        'Para forçar uma atualização, puxe a tela para baixo (pull-to-refresh) '
        'ou navegue para outra aba e volte.',
      ),
    ],
  ),
];

// --- PAGE ---

/// I display the Help & Support screen with categorised FAQ sections and contact cards.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go('/profile'),
          child: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
        ),
        centerTitle: true,
        title: Text(
          'Ajuda & Suporte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border(context)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [

          // intro banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textPrimary(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.support_agent, color: AppColors.surfaceColor(context), size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Como podemos ajudar?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceColor(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Encontre respostas nas seções abaixo ou fale com a equipe.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.surfaceColor(context).withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // sections
          for (final section in _sections) ...[
            _SectionBlock(section: section),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 8),

          // contact cards
          Text(
            'Fale com a equipe',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted(context),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          _contactCard(
            context,
            icon: Icons.email_outlined,
            title: 'E-mail',
            subtitle: 'suporte@mesclainvest.com.br',
            detail: 'Resposta em até 2 dias úteis',
          ),
          const SizedBox(height: 10),
          _contactCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chat ao vivo',
            subtitle: 'Disponível seg–sex, 9h–18h',
            detail: 'Tempo médio de espera: 5 min',
          ),
          const SizedBox(height: 10),
          _contactCard(
            context,
            icon: Icons.menu_book_outlined,
            title: 'Central de Ajuda',
            subtitle: 'ajuda.mesclainvest.com.br',
            detail: 'Artigos, tutoriais e guias',
          ),

          const SizedBox(height: 28),

          Center(
            child: Text(
              'Mescla Invest — Projeto PUC-Campinas',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// I build a contact channel card with an icon, title, subtitle, and detail text.
  Widget _contactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                ),
                Text(
                  detail,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }
}

// --- SECTION BLOCK ---

/// I render a collapsible FAQ section block with a title and list of expandable tiles.
class _SectionBlock extends StatelessWidget {
  final _Section section;
  const _SectionBlock({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(section.icon, size: 16, color: AppColors.textMuted(context)),
            const SizedBox(width: 6),
            Text(
              section.title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted(context),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < section.items.length; i++) ...[
                _FaqTile(item: section.items[i]),
                if (i < section.items.length - 1)
                  Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.borderSoft(context)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// --- FAQ TILE ---

/// I display a single FAQ tile that expands to reveal the answer when tapped.
class _FaqTile extends StatefulWidget {
  final _Item item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

/// State for _FaqTile.
class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.item.answer,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                          height: 1.55,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
