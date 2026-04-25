import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget do cabeçalho da tela de perfil.
class CabecalhoPerfil extends StatelessWidget {
  const CabecalhoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo circular preto
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Text(
              'M',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Nome do aplicativo
          Text(
            'Mescla Invest',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
