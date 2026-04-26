import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// [NavegacaoInferiorMock] é uma representação visual da barra de navegação principal.
/// 
/// Como o sistema de rotas e navegação global pode ser gerenciado de forma centralizada,
/// este widget serve como um mockup para garantir que o design da tela de perfil
/// esteja completo e respeite o espaço da barra inferior.
class NavegacaoInferiorMock extends StatelessWidget {
  const NavegacaoInferiorMock({super.key});

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
          _buildNavItem(Icons.home_outlined, 'Home'),
          _buildNavItem(Icons.pie_chart_outline, 'Portfólio'),
          _buildNavItem(Icons.swap_horiz, 'Balcão'),
          // O item 'Perfil' é marcado como ativo neste mockup.
          _buildNavItem(Icons.person, 'Perfil', isActive: true),
        ],
      ),
    );
  }

  /// Constrói um item individual (Ícone + Texto) para a barra de navegação.
  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          // Altera a cor se o item estiver selecionado.
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
