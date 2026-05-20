// Eduardo Kairalla - 24024241

// Content of the "About" tab on the startup detail screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/pages/startup/widgets/startup_token_info.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- WIDGET ---

class AboutTab extends StatelessWidget {
  final StartupModel startup;

  const AboutTab({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Sumário Executivo'),
          const SizedBox(height: 10),
          Text(
            startup.executiveSummary,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
              height: 1.55,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  context: context,
                  label: 'CAPITAL CAPTADO',
                  value: NumberFormat.currency(
                    locale: 'pt_BR',
                    symbol: 'R\$',
                  ).format(startup.capitalRaised),
                  icon: Icons.monetization_on_outlined,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  context: context,
                  label: 'TOKENS EMITIDOS',
                  value: NumberFormat.compact(
                    locale: 'pt_BR',
                  ).format(startup.totalTokens),
                  icon: Icons.token_outlined,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          // --- Pedro Henrique Medeiros dos Reis - 24801656 ---
          // Token sigla + sold % progress bar — gives context for the
          // balcão (the per-startup order book uses this token name).
          const SizedBox(height: 16),
          StartupTokenInfo(startup: startup),
          // --- end Pedro ---

          const SizedBox(height: 24),

          _sectionTitle(context, 'Sobre o Projeto'),
          const SizedBox(height: 10),
          Text(
            startup.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
              height: 1.55,
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle(context, 'Documentos'),
          const SizedBox(height: 10),
          _documentItem(
            context: context,
            icon: Icons.picture_as_pdf_outlined,
            title: 'Plano de Negócios',
            subtitle: 'Em breve',
            available: false,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _statCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required dynamic color,
  }) {
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
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool available,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textSecondary(context), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            available ? Icons.download_outlined : Icons.lock_outline,
            color: AppColors.textMuted(context),
            size: 20,
          ),
        ],
      ),
    );
  }
}
