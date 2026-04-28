import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/controllers/profile_controller.dart';

/// Card com resumo de indicadores do perfil.
class ProfileStatsCard extends StatelessWidget {
  final ProfileController controller;

  const ProfileStatsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(data.investments, 'Investimentos'),
          _divider(),
          _statItem(data.investedAmount, 'Aplicado'),
          _divider(),
          _statItem(data.favorites, 'Favoritas'),
        ],
      ),
    );
  }

  /// Monta um item com valor + rótulo.
  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF888888),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Divisor vertical entre os indicadores.
  Widget _divider() {
    return const SizedBox(
      height: 36,
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: Color(0xFFEEEEEE),
      ),
    );
  }
}

