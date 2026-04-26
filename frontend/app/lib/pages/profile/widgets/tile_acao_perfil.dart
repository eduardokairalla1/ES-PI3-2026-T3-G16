import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Item de lista genérico para ações e configurações no perfil.
class TileAcaoPerfil extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showArrow;

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
    final subtitleWidget = subtitle == null
        ? null
        : Text(
            subtitle!,
            style: GoogleFonts.inter(
              color: const Color(0xFF8A8A8A),
              fontSize: 11,
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF444444), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF111111),
                  ),
                ),
                if (subtitleWidget != null) ...[
                  const SizedBox(height: 2),
                  subtitleWidget,
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (showArrow)
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF111111)),
        ],
      ),
    );
  }
}
