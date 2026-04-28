import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Barra inferior mockada para fechar a composição visual da tela.
///
/// Não realiza navegação real, apenas representa o layout final.
class ProfileBottomNavMock extends StatelessWidget {
  const ProfileBottomNavMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Home'),
          _navItem(Icons.pie_chart_outline, 'Portfolio'),
          _navItem(Icons.swap_horiz, 'Balcao'),
          _navItem(Icons.person, 'Perfil', isActive: true),
        ],
      ),
    );
  }

  /// Item individual da barra inferior.
  Widget _navItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: isActive ? const Color(0xFF111111) : const Color(0xFFB3B3B3),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? const Color(0xFF111111) : const Color(0xFFB3B3B3),
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

