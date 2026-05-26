// --- Meus investimentos ---
//
// Alex Gabriel Soares Sousa - 24802449
// Lista até três investimentos do usuário na Home com tokens, valor e variação.

library;

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- CONSTANTES ---
final _currencyFmt = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
  decimalDigits: 2,
);

// --- CODE ---

/// Seção principal que lista as startups nas quais o usuário possui tokens.
/// Recebe o [DashboardController] para escutar o estado de exibição de valores (visibilidade/máscara)
/// e recuperar a lista de ativos consolidados do backend.
class MeusInvestimentos extends StatelessWidget {
  // Atributos contendo a lógica de negócios da tela principal
  final DashboardController controller;

  // Construtor padrão exigindo o controller associado
  const MeusInvestimentos({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Obtém a lista de investimentos do resumo do Dashboard, evitando falhas com lista vazia por padrão
    final investimentos = controller.data?.investimentos ?? [];
    final visibleInvestimentos = investimentos.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Cabeçalho da Seção ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meus Investimentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                  letterSpacing: -0.5,
                ),
              ),
              // Botão para ver o portfólio completo (tela dedicada).
              GestureDetector(
                onTap: () => context.push('/carteira/investimentos'),
                child: Row(
                  children: [
                    Text(
                      'Ver todos',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.add, size: 16, color: Colors.blue.shade700),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- Lista de Investimentos ou Estado Vazio ---
        if (investimentos.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: AppColors.textMuted(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Você ainda não possui investimentos.',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleInvestimentos.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return InvestimentoCard(
                investimento: visibleInvestimentos[index],
                exibirValores: controller.exibirValores,
                onReturn: () => controller.loadDashboard(),
              );
            },
          ),

        const SizedBox(height: 40),
      ],
    );
  }
}

/// Widget interno para exibir cada card de investimento na lista.
/// Controla individualmente a formatação, cor da variação de rentabilidade
/// e suporta o modo de ocultação de saldos (modo de privacidade).
class InvestimentoCard extends StatelessWidget {
  // Dados do investimento (Startup, quantidade de tokens, preço atual e variação)
  final InvestimentoResumo investimento;

  // Sinalizador que determina se o saldo e a porcentagem devem ser exibidos ou mascarados com '•••••'
  final bool exibirValores;

  // Callback to execute when returning from the startup detail page
  final VoidCallback? onReturn;

  // Construtor com as propriedades obrigatórias para renderização do card
  const InvestimentoCard({
    super.key,
    required this.investimento,
    required this.exibirValores,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo em tempo real do patrimônio alocado na startup (Preço Unitário Atual * Quantidade de Tokens)
    final valorTotal = investimento.tokenQuantity * investimento.currentPrice;

    // Determina se a variação percentual é positiva (lucro) ou negativa (prejuízo)
    final isPositive = investimento.variation >= 0;

    return GestureDetector(
      // Navegação para o detalhe da startup
      onTap: () async {
        await context.push('/startup/${investimento.startupId}');
        if (context.mounted && onReturn != null) {
          onReturn!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- Logo da Startup ---
            _InvestmentLogo(
              url: investimento.startupLogoUrl,
              name: investimento.startupName,
            ),
            const SizedBox(width: 12),

            // --- Informações da Startup (Nome e Qtd Tokens) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investimento.startupName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${NumberFormat.decimalPattern('pt_BR').format(investimento.tokenQuantity)} STX num. Tokens',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- Valores Financeiros (Saldo e Variação %) ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  exibirValores ? _currencyFmt.format(valorTotal) : 'R\$ •••••',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                if (exibirValores)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.shade700.withValues(alpha: 0.1)
                          : Colors.red.shade700.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${investimento.variation.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPositive
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  )
                else
                  Text(
                    '•••••%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted(context),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 8),
            // Ícone de chevron para indicar navegabilidade
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentLogo extends StatelessWidget {
  final String url;
  final String name;

  const _InvestmentLogo({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceMuted(context),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ClipOval(
        child: url.trim().isEmpty
            ? _fallback(context)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(context),
              ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}
