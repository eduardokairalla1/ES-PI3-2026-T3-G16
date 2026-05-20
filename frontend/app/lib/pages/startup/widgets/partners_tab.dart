// Eduardo Kairalla - 24024241

// Content of the "Partners" tab on the startup detail screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- WIDGET ---

class PartnersTab extends StatelessWidget {
  final StartupModel startup;

  const PartnersTab({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Sócios Fundadores'),
          const SizedBox(height: 12),
          ...startup.partners.map((p) => _partnerCard(context, p)),

          if (startup.advisors.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, 'Conselho & Mentores'),
            const SizedBox(height: 12),
            ...startup.advisors.map((a) => _advisorCard(context, a)),
          ],

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

  Widget _partnerCard(BuildContext context, PartnerModel partner) {
    final initial = partner.name.isNotEmpty
        ? partner.name[0].toUpperCase()
        : '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.textPrimary(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surfaceColor(context),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        partner.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${partner.equityPct.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceColor(context),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  partner.role,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted(context),
                  ),
                ),

                if (partner.bio != null && partner.bio!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    partner.bio!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _advisorCard(BuildContext context, AdvisorModel advisor) {
    final initial = advisor.name.isNotEmpty
        ? advisor.name[0].toUpperCase()
        : '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisor.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  advisor.role,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
