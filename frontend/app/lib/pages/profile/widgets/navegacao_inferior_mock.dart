//esse arquivo deve ser reintegrado
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Barra de navegação inferior simulada (Mockup).
class NavegacaoInferiorMock extends StatelessWidget {
  const NavegacaoInferiorMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home'),
          _buildNavItem(Icons.pie_chart_outline, 'Portfólio'),
          _buildNavItem(Icons.swap_horiz, 'Balcão'),
          _buildNavItem(Icons.person, 'Perfil', isActive: true),
        ],
      ),
    );
  }

  /// Constrói um item individual da barra de navegação.
  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.black : Colors.grey[400],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? Colors.black : Colors.grey[400],
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
