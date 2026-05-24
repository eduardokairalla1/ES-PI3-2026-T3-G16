// Eduardo Kairalla - 24024241

// Card with logo, token price, and stage badge.

// --- IMPORTS ---

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:mesclainvest/shared/styles/stage_colors.dart';


// --- WIDGET ---

class StartupInfoCard extends StatelessWidget {

  final StartupModel startup;

  const StartupInfoCard({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      color: AppColors.surfaceColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [

          Container(
            width: 63,
            height: 63,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: startup.logoUrl.isNotEmpty
                ? Image.network(
                    startup.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _logoPlaceholder(startup.name),
                  )
                : _logoPlaceholder(startup.name),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currencyFmt.format(startup.tokenPrice),
                  style: moneyStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Preço por token',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: stageColor(startup.stage).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              startup.stageLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: stageColor(startup.stage),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _logoPlaceholder(String name) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Builder(
      builder: (context) => Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

}
