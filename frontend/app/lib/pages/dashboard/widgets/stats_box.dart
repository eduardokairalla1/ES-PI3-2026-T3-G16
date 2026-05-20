/*
 * Componente de caixa de estatísticas usado para exibir indicadores de mercado.
 * Fornece uma estrutura visual padronizada com texto primário em destaque e rótulo secundário.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

library;

/*
 * IMPORTS
 */

import 'package:flutter/material.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

/*
 * CODE
 */

/// Componente visual base para indicadores numéricos/estatísticos no Dashboard.
class StatsBox extends StatelessWidget {
  // Atributos
  final String primaryText; // Texto em destaque (ex: valor numérico)
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
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
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
                color: AppColors.textSecondary(context),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
