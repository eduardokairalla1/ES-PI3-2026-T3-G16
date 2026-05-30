/*
 * Widget de listagem dos investimentos do usuário (Minha Carteira).
 * Exibe a quantidade de tokens e valorização acumulada por cada startup.
 *
 * Este componente apresenta ao investidor um sumário rápido da sua carteira de ativos
 * (startups investidas) diretamente na Home. Se o usuário possuir ativos, exibe
 * a quantidade de tokens ("STX"), o valor financeiro consolidado e a oscilação percentual.
 * Se não possuir nenhum token comprado, exibe uma mensagem amigável instruindo-o a começar.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

library;

/*
 * IMPORTS
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';

/*
 * CONSTANTES
 */
final _currencyFmt = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
  decimalDigits: 2,
);

/*
 * CODE
 */

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
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: investimentos.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return InvestimentoCard(
                investimento: investimentos[index],
                exibirValores: controller.exibirValores,
                onReturn: () => controller.loadDashboard(),
              );
            },
          ),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _TokenChip extends StatelessWidget {
  final InvestimentoResumo investimento;
  const _TokenChip({required this.investimento});

  @override
  Widget build(BuildContext context) {
    final qty = NumberFormat.decimalPattern('pt_BR').format(investimento.tokenQuantity);
    final ticker = investimento.tokenName.isNotEmpty ? investimento.tokenName : 'tokens';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.toll_outlined, size: 11, color: AppColors.textMuted(context)),
          const SizedBox(width: 4),
          Text(
            '$qty $ticker',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _logoFallback(BuildContext context, String name) {
  return Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'S',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: AppColors.textPrimary(context),
      ),
    ),
  );
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceMuted(context),
              ),
              child: ClipOval(
                child: investimento.startupLogoUrl.isNotEmpty
                    ? Image.network(
                        investimento.startupLogoUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _logoFallback(
                          context,
                          investimento.startupName,
                        ),
                      )
                    : _logoFallback(context, investimento.startupName),
              ),
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
                  const SizedBox(height: 4),
                  _TokenChip(investimento: investimento),
                ],
              ),
            ),

            // --- Valores Financeiros (Saldo e Variação %) ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  exibirValores ? _currencyFmt.format(valorTotal) : 'R\$ •••••',
                  style: moneyStyle(
                    fontSize: 15,
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
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
                  ),
              ],
            ),

            const SizedBox(width: 8),
            // Ícone de chevron para indicar navegabilidade
            Icon(Icons.chevron_right, color: AppColors.textMuted(context), size: 20),
          ],
        ),
      ),
    );
  }
}
