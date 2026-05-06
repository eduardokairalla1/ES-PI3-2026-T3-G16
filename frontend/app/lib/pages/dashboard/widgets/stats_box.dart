/**
 * Componente de caixa de estatísticas usado para exibir indicadores de mercado.
 * Fornece uma estrutura visual padronizada com texto primário em destaque e rótulo secundário.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * IMPORTS
 */
import 'package:flutter/material.dart';


/**
 * CODE
 */

/// Componente visual base para indicadores numéricos/estatísticos no Dashboard.
class StatsBox extends StatelessWidget {
  
  // Atributos
  final String primaryText;   // Texto em destaque (ex: valor numérico)
  final String secondaryText; // Descrição/Rótulo do indicador

  // Construtor
  const StatsBox({
    super.key,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Texto Primário (Destaque) ---
            Text(
              primaryText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            
            // --- Texto Secundário (Rótulo) ---
            Text(
              secondaryText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
