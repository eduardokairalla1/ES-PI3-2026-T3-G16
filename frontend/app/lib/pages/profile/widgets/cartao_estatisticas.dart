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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Linha vertical de separação entre itens.
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[200],
    );
  }
}
