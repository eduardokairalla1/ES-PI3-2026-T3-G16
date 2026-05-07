import 'package:flutter/material.dart';

/// Atalhos para ações principais (Depósito, Compra, Venda, Extrato).
class BotoesAcao extends StatelessWidget {
  
  // construtor
  const BotoesAcao({super.key});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _BotaoAcaoItem(icon: Icons.add,                      label: 'Depositar', isPrimary: true),
          SizedBox(width: 24),
          _BotaoAcaoItem(icon: Icons.trending_up,              label: 'Comprar'),
          SizedBox(width: 24),
          _BotaoAcaoItem(icon: Icons.account_balance_outlined, label: 'Vender'),
          SizedBox(width: 24),
          _BotaoAcaoItem(icon: Icons.receipt_long_outlined,    label: 'Extrato'),
        ],
      ),
    );
  }
}


/// Botão de ação individual.
class _BotaoAcaoItem extends StatelessWidget {

  // atributos
  final IconData icon;
  final String label;
  final bool isPrimary;

  // construtor
  const _BotaoAcaoItem({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // container arredondado (squircle) do ícone
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isPrimary ? Colors.black : const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : Colors.black87,
            size: 26,
          ),
        ),

        const SizedBox(height: 8),

        // rótulo do botão
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            color: isPrimary ? Colors.black : Colors.grey.shade600,
          ),
        ),

      ],
    );
  }
}