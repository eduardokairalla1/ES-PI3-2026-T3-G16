import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';

/// Exibição de patrimônio e rendimento diário.
class CartaoPatrimonio extends StatelessWidget {

  final DashboardController controller;

  const CartaoPatrimonio({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {

    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final data = controller.data;
    final bool visivel = controller.exibirValores;

    if (data == null) return const SizedBox();

    final String valPatrimonio = formatter.format(data.patrimonioTotal);
    final String valLucroSemanal = formatter.format(data.rendimentoSemanalValor);
    final String valLucroPorcentagem = data.rendimentoSemanalPorcentagem.toStringAsFixed(2);
    final bool isPositive = data.rendimentoSemanalValor >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'Valor total estimado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  visivel ? valPatrimonio : '*' * valPatrimonio.length,
                  key: ValueKey<bool>(visivel),
                  style: moneyStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: controller.toggleVisibility,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    visivel ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: visivel ? 1.0 : 0.5,
            child: Row(
              children: [
                Text(
                  visivel ? '${isPositive ? '+' : '-'} $valLucroSemanal' : '*' * (valLucroSemanal.length + 1),
                  style: moneyStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: visivel ? (isPositive ? Colors.green.shade700 : Colors.red.shade700) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  visivel ? '(${isPositive ? '+' : ''}$valLucroPorcentagem%)   7 dias' : '*' * ('($valLucroPorcentagem%)   7 dias'.length + 1),
                  style: moneyStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: visivel ? Colors.grey.shade600 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
