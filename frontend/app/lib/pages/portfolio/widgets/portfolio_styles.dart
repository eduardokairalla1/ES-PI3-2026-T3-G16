/// --- Estilos do Portfólio ---

import 'package:flutter/material.dart';

/// Eu centralizo as cores e decorações usadas na tela de portfólio.
class PortfolioStyles {

  // Cores
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color positiveGrowth = Colors.green;
  static const Color negativeGrowth = Colors.red;
  static const Color textSecondary = Colors.grey;
  static const Color textPrimary = Colors.black87;

  // Decorações de Card
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Paddings padrão
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20.0);

}
