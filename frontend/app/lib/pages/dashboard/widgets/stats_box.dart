import 'package:flutter/material.dart';

/// Componente visual reutilizável (Fração inicial - Apenas esqueleto)
class StatsBox extends StatelessWidget {
  
  // Parâmetros estritos requisitados pela task 12
  final String primaryText;
  final String secondaryText;

  const StatsBox({
    super.key,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    // Geometria do Card (BoxDecoration, Shading) estabelecida.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // O interior ainda continuará vazio. Adicionaremos a coluna no próx ciclo.
      child: const SizedBox.shrink(),
    );
  }
}
