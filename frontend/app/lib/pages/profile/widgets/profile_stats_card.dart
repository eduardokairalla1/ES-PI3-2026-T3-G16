import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/controllers/profile_controller.dart';

/// [ProfileStatsCard] exibe um resumo numérico da atividade do usuário.
/// 
/// Apresenta três métricas principais: Investimentos ativos, Valor total aplicado
/// e Startups favoritadas, organizadas horizontalmente com divisores entre elas.
class ProfileStatsCard extends StatelessWidget {
  final ProfileController controller;

  const ProfileStatsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Recupera os dados do controlador.
    final data = controller.data;
    // Se os dados ainda não estiverem disponíveis, não renderiza nada (shrink).
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
          _buildStatItem(data.investments, 'Investimentos'),
          _buildDivider(), // Divisor vertical entre as métricas.
          _buildStatItem(data.investedAmount, 'Aplicado'),
          _buildDivider(),
          _buildStatItem(data.favorites, 'Favoritas'),
        ],
      ),
    );
  }

  /// Constrói um item individual de estatística (Valor em cima, Label embaixo).
  Widget _buildStatItem(String value, String label) {
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

  /// Helper para criar a linha vertical fina de separação.
  Widget _buildDivider() {
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
