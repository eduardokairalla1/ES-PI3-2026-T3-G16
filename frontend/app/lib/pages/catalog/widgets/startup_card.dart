// Eduardo Kairalla - 24024241

// Card widget for a startup in the catalog listing.

// --- IMPORTS ---

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:mesclainvest/shared/styles/stage_colors.dart';


// --- HELPERS ---

final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);


// --- WIDGET ---

/// I display a summary card for a startup in the catalog listing.
class StartupCard extends StatelessWidget {

  final StartupModel startup;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onReturn;

  const StartupCard({
    super.key, 
    required this.startup,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onReturn,
  });

  /// I build the startup card layout with logo, name, stage badge, and stats.
  @override
  Widget build(BuildContext context) {
    final color = stageColor(startup.stage);

    return GestureDetector(
      onTap: () async {
        await context.push('/startup/${startup.id}');
        if (context.mounted && onReturn != null) {
          onReturn!();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

            // --- logo + name + stage ---
            Row(
              children: [
                _Logo(url: startup.logoUrl, name: startup.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startup.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        startup.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onFavoriteTap != null)
                  IconButton(
                    onPressed: onFavoriteTap,
                    icon: Icon(
                      isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFavorite ? Colors.amber.shade600 : AppColors.textMuted(context),
                      size: 26,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 24,
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    startup.stageLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: AppColors.borderSoft(context)),
            const SizedBox(height: 14),

            // --- token price + capital raised ---
            Row(
              children: [
                _Stat(
                  label: 'Preço do token',
                  value: NumberFormat.currency(
                    locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2,
                  ).format(startup.tokenPrice),
                ),
                const SizedBox(width: 24),
                _Stat(
                  label: 'Capital captado',
                  value: _currencyFmt.format(startup.capitalRaised),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted(context)),
              ],
            ),

          ],
        ),
      ),
    );
  }
}


/// I render the circular startup logo with a fallback initial letter.
class _Logo extends StatelessWidget {
  final String url;
  final String name;

  const _Logo({required this.url, required this.name});

  /// I build the circular logo container with a network image or initial fallback.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceMuted(context),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// I render a labeled numeric stat column inside the startup card.
class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  /// I build the label and value column for a stat entry.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: moneyStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
