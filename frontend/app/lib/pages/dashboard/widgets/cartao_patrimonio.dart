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
      ),
    );
  }
}
