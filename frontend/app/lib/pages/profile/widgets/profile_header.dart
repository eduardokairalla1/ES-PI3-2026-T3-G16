import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cabeçalho fixo exibido no topo da tela de perfil.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E2E2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

