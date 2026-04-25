import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/controllers/perfil_controller.dart';

/// Widget que exibe o avatar, nome, email e selo de verificação do usuário.
class InfoUsuario extends StatelessWidget {
  final PerfilController controller;

  const InfoUsuario({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 18),
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black,
          child: Text(
            data.nome.isNotEmpty ? data.nome[0] : 'U',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data.nome,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Text(
          data.email,
          style: GoogleFonts.inter(
            color: const Color(0xFF676767),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE6E6E6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_outlined, size: 12, color: Color(0xFF666666)),
              const SizedBox(width: 4),
              Text(
                'Perfil Verificado',
                style: GoogleFonts.inter(
                  color: const Color(0xFF666666),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
