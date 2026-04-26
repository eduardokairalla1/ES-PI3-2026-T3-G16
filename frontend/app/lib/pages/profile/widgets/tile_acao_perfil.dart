import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// [TileAcaoPerfil] é um componente visual reutilizável para itens de menu e configurações.
/// Ele segue o padrão de design do MesclaInvest, com ícones em containers cinzas e fontes bold.
class TileAcaoPerfil extends StatelessWidget {
  final IconData icon;      // Ícone que representa a ação.
  final String title;       // Título principal do item.
  final String? subtitle;   // Subtítulo opcional para mais contexto.
  final Widget? trailing;   // Widget opcional para o lado direito (ex: Switch).
  final bool showArrow;     // Define se deve exibir a seta de navegação (>) ao final.

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
    // Widget auxiliar para tratar o subtítulo, se existir.
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
          // Container do ícone com fundo cinza arredondado (estilo Apple/Moderno).
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
          
          // Área de texto que ocupa o espaço central.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, // Título em negrito conforme solicitado.
                    fontSize: 14,
                    color: const Color(0xFF111111),
                  ),
                ),
                // Se houver subtítulo, adicionamos um pequeno espaçamento e o exibimos.
                if (subtitleWidget != null) ...[
                  const SizedBox(height: 2),
                  subtitleWidget,
                ],
              ],
            ),
          ),
          
          // Se houver um widget customizado para o final (ex: Switch), exibimos aqui.
          if (trailing != null) trailing!,
          
          // Se for um item de navegação, mostramos a seta à direita.
          if (showArrow)
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF111111)),
        ],
      ),
    );
  }
}
