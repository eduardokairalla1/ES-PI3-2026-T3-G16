// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';


// --- CÓDIGO ---

/// Eu represento a linha de botões de ações rápidas.
class BotoesAcao extends StatelessWidget {
  
  // construtor
  const BotoesAcao({super.key});


  /// Eu construo a linha com os botões de ação principal.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [

          // item: depositar (destaque)
          _BotaoAcaoItem(
            icon: Icons.add,
            label: 'Depositar',
            isPrimary: true,
          ),

          // item: comprar
          _BotaoAcaoItem(
            icon: Icons.trending_up,
            label: 'Comprar',
          ),

          // item: vender
          _BotaoAcaoItem(
            icon: Icons.trending_down,
            label: 'Vender',
          ),

          // item: extrato
          _BotaoAcaoItem(
            icon: Icons.receipt_long_outlined,
            label: 'Extrato',
          ),

        ],
      ),
    );
  }
}


/// Eu represento um item individual de botão de ação.
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

        // container circular do ícone
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isPrimary ? Colors.black : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : Colors.black87,
            size: 24,
          ),
        ),

        const SizedBox(height: 8),

        // rótulo do botão
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),

      ],
    );
  }
}