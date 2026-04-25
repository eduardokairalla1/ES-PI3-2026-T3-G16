import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Item de lista genérico para ações e configurações no perfil.
class TileAcaoPerfil extends StatelessWidget {
  final IconData icon; // Ícone que representa a ação
  final String title;  // Título da ação
  final String? subtitle; // Subtítulo opcional
  final Widget? trailing; // Widget opcional no final (ex: Switch)
  final bool showArrow; // Define se exibe a seta de navegação

  const TileAcaoPerfil({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Container do ícone
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(width: 15),
          // Textos (Título e Subtítulo)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Espaço para widget final ou seta
          if (trailing != null) trailing!,
          if (showArrow)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
