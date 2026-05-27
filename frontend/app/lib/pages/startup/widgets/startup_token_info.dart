// --- Startup token info ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Small metadata block shown on the "Sobre" tab: the token symbol
// ("MSCL", "TC", etc.) and a progress bar with the percentage of the
// total supply already sold via the primary market.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- WIDGET ---

/// Small token metadata block shown on the "Sobre" tab of a startup.
///
/// Renders the token symbol pill (e.g. `MSCL`, `TC`) and a progress bar with
/// the percentage of the total token supply already sold via the primary
/// market (bonding curve).
class StartupTokenInfo extends StatelessWidget {
  /// Startup whose token info is rendered.
  final StartupModel startup;

  /// Builds the token info block for [startup].
  const StartupTokenInfo({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    final sold     = startup.soldPercent;
    final tokenName = startup.tokenName.isEmpty
        ? '—'
        : startup.tokenName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // token symbol
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tokenName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.surfaceColor(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Tokens oficiais da startup',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'O que é um token?',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    content: const Text(
                      'Cada startup emite uma quantidade fixa de tokens que representam uma fração do seu valor.\n\n'
                      'Você compra tokens aqui (mercado primário) a um preço que sobe conforme mais tokens são vendidos — quem compra antes paga menos.\n\n'
                      'Quando todos os tokens forem vendidos, a negociação acontece apenas no Balcão, entre investidores.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Entendi'),
                      ),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // sold progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vendido (primário)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
              Text(
                '${sold.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (sold / 100).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.surfaceMuted(context),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }
}
