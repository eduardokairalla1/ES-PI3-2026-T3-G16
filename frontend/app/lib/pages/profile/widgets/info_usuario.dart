import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/controllers/perfil_controller.dart';

/// [InfoUsuario] é responsável por exibir os dados principais de identificação do usuário.
/// 
/// Inclui o Avatar circular com a inicial do nome, o nome completo, e-mail e
/// o selo de verificação de perfil.
class InfoUsuario extends StatelessWidget {
  final PerfilController controller;

  const InfoUsuario({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        // Avatar circular exibindo a inicial do nome do usuário.
        CircleAvatar(
          radius: 42,
          backgroundColor: Colors.black,
          child: Text(
            data.nome.isNotEmpty ? data.nome[0] : 'U',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Nome do usuário em negrito.
        Text(
          data.nome,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        // E-mail em cor mais suave para hierarquia visual.
        Text(
          data.email,
          style: GoogleFonts.inter(
            color: const Color(0xFF676767),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Tag "Perfil Verificado" estilizada como uma pílula (pill shape).
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, size: 12, color: Color(0xFF888888)),
              const SizedBox(width: 6),
              Text(
                'Perfil Verificado',
                style: GoogleFonts.inter(
                  color: const Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
