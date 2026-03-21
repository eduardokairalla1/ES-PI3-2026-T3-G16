import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:intl/intl.dart';

/// Exibição de patrimônio e rendimento diário.
class CartaoPatrimonio extends StatelessWidget {
  
  final DashboardController controller;
  
  // construtor
  const CartaoPatrimonio({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // extração dos dados formatados e estados lidos do controller global
    final data = controller.data;
    final bool visivel = controller.exibirValores;
    
    // proteção para quando data ainda não existir (caso não lidemos no pai)
    if (data == null) return const SizedBox(); 
    
    final String valPatrimonio = formatter.format(data.patrimonioTotal);
    final String valLucroDiario = formatter.format(data.rentabilidadeDiariaValor);
    final String valLucroPorcentagem = data.rentabilidadeDiariaPercentual.toStringAsFixed(2);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // item: título da seção
          Text(
            'MEU PATRIMÔNIO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Saldo e controle de visibilidade.
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  visivel ? valPatrimonio : 'R\$ *********',
                  key: ValueKey<bool>(visivel),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: controller.toggleVisibility, // O toggle manda para Controller
                child: Tooltip(
                  message:
                      visivel ? 'Ocultar saldo' : 'Mostrar saldo',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      visivel
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // rentabilidade diária (suave com AnimatedOpacity)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: visivel ? 1.0 : 0.5,
            child: Row(
              children: [
                Icon(
                  data.rentabilidadeDiariaValor >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: visivel ? (data.rentabilidadeDiariaValor >= 0 ? Colors.green : Colors.red) : Colors.grey.shade300,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  visivel ? '${data.rentabilidadeDiariaValor >= 0 ? '+' : ''}$valLucroDiario' : '*******',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        visivel ? (data.rentabilidadeDiariaValor >= 0 ? Colors.green.shade700 : Colors.red.shade700) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  visivel ? '(${data.rentabilidadeDiariaPercentual >= 0 ? '+' : ''}$valLucroPorcentagem%) hoje' : '(****) ****',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        visivel ? Colors.grey.shade600 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFF5F5F5)),
        ],
      ),
    );
  }
}
