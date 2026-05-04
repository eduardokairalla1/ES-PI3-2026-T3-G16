/// Seção de ativos na carteira do usuário.
/// Exibe valorização e quantidade de tokens por startup.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';

final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

class MeusInvestimentos extends StatelessWidget {
  final DashboardController controller;

  const MeusInvestimentos({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final investimentos = controller.data?.investimentos ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Cabeçalho ---
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
              GestureDetector(
                onTap: () {
                  // TODO: Implementar tela de portfólio completo futuramente
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
        if (investimentos.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Você ainda não possui investimentos.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
              );
            },
          ),
          
        const SizedBox(height: 40),
      ],
    );
  }
}

class InvestimentoCard extends StatelessWidget {
  final InvestimentoResumo investimento;
  final bool exibirValores;

  const InvestimentoCard({
    super.key,
    required this.investimento,
    required this.exibirValores,
  });

  @override
  Widget build(BuildContext context) {
    final valorTotal = investimento.tokenQuantity * investimento.currentPrice;
    final isPositive = investimento.variation >= 0;
    
    return GestureDetector(
      onTap: () => context.push('/startup/${investimento.startupId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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
            // --- Logo ---
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
            
            // --- Info Central ---
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
                    '${NumberFormat.decimalPattern('pt_BR').format(investimento.tokenQuantity)} STX num. Tokens',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // --- Valores ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  exibirValores ? _currencyFmt.format(valorTotal) : 'R\$ •••••',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                if (exibirValores)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${investimento.variation.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  )
                else
                  Text(
                    '•••••%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
