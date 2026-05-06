/**
 * Widget de listagem dos investimentos do usuário (Minha Carteira).
 * Exibe a quantidade de tokens e valorização acumulada por cada startup.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * IMPORTS
 */
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';


/**
 * CONSTANTES
 */
final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);


/**
 * CODE
 */

/// Seção principal que lista as startups nas quais o usuário possui tokens.
class MeusInvestimentos extends StatelessWidget {

  // Atributos
  final DashboardController controller;

  // Construtor
  const MeusInvestimentos({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final investimentos = controller.data?.investimentos ?? [];

    if (investimentos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // --- Cabeçalho da Seção ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meus Investimentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              // Botão para ver o portfólio completo (Em desenvolvimento)
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Portfólio completo em breve!'),
                      backgroundColor: Colors.black,
                    ),
                  );
                },
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

        // --- Lista de Investimentos ---
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: investimentos.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return InvestimentoCard(
              investimento: investimentos[index],
              exibirValores: controller.exibirValores,
            );
          },
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}


/// Widget interno para exibir cada card de investimento na lista.
class InvestimentoCard extends StatelessWidget {

  // Atributos
  final InvestimentoResumo investimento;
  final bool exibirValores;

  // Construtor
  const InvestimentoCard({
    super.key,
    required this.investimento,
    required this.exibirValores,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculos de valorização e saldo
    final valorTotal = investimento.tokenQuantity * investimento.currentPrice;
    final isPositive = investimento.variation >= 0;

    return GestureDetector(
      // Navegação para o detalhe da startup
      onTap: () => context.push('/startup/${investimento.startupId}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                color: Colors.grey.shade100,
                image: investimento.startupLogoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(investimento.startupLogoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: investimento.startupLogoUrl.isEmpty
                  ? Center(
                      child: Text(
                        investimento.startupName.isNotEmpty ? investimento.startupName[0].toUpperCase() : 'S',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // --- Informações da Startup (Nome e Qtd Tokens) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investimento.startupName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${NumberFormat.decimalPattern('pt_BR').format(investimento.tokenQuantity)} tokens',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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
                  exibirValores ? _currencyFmt.format(valorTotal) : 'R\$ ****',
                  style: moneyStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${isPositive ? '+' : ''}${investimento.variation.toStringAsFixed(2)}%',
                  style: moneyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            // Ícone de chevron para indicar navegabilidade
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),

          ],
        ),
      ),
    );
  }
}
