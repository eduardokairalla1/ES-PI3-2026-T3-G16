import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// [CabecalhoPerfil] representa a barra superior da tela de perfil.
/// 
/// Ela contém o logotipo minimalista "M" e o nome do aplicativo centralizados,
/// seguindo o padrão visual de branding do projeto.
class CabecalhoPerfil extends StatelessWidget {
  const CabecalhoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E2E2)), // Linha sutil de separação na parte inferior.
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centraliza os elementos na barra.
        children: [
          // Container circular que simula o logo da Mescla.
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'M',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Texto de branding ao lado do logo.
          Text(
            'Mescla Invest',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}
