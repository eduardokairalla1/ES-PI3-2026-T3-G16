import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget do cabeçalho da tela de perfil.
class CabecalhoPerfil extends StatelessWidget {
  const CabecalhoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E2E2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
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
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Mescla Invest',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}
