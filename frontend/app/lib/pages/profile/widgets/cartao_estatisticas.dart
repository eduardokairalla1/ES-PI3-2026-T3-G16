import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/controllers/perfil_controller.dart';

/// Cartão que exibe métricas do usuário (Investimentos, Valor Aplicado e Favoritas).
class CartaoEstatisticas extends StatelessWidget {
  final PerfilController controller;

  const CartaoEstatisticas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(data.investimentos, 'Investimentos'),
          _buildDivider(),
          _buildStatItem(data.aplicado, 'Aplicado'),
          _buildDivider(),
          _buildStatItem(data.favoritas, 'Favoritas'),
        ],
      ),
    );
  }

  /// Constrói um item de estatística individual.
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF7A7A7A),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// Linha vertical de separação entre itens.
  Widget _buildDivider() {
    return const SizedBox(
      height: 40,
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: Color(0xFFE9E9E9),
      ),
    );
  }
}
