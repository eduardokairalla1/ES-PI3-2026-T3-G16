// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';


// --- CÓDIGO ---

/// Eu represento o cartão de patrimônio do usuário.
class CartaoPatrimonio extends StatelessWidget {
  
  // construtor
  const CartaoPatrimonio({super.key});


  /// Eu construo o container principal.
  @override
  Widget build(BuildContext context) {
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

          // saldo total com ícone de visibilidade
          Row(
            children: [
              const Text(
                'R$ 999.999.999,99',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // rentabilidade diária
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '+R$ 9.999,99',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(+ 9,99%) hoje',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFF5F5F5)),
        ],
      ),
    );
  }
}
