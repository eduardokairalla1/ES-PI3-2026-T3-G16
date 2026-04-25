import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/controllers/perfil_controller.dart';

/// Widget que exibe o avatar, nome, email e selo de verificação do usuário.
class InfoUsuario extends StatelessWidget {
  final PerfilController controller;

  const InfoUsuario({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Caso os dados ainda não tenham carregado, exibe um placeholder vazio.
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 20),
        // Avatar com inicial do nome
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black,
          child: Text(
            data.nome.isNotEmpty ? data.nome[0] : 'U',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Nome do usuário
        Text(
          data.nome,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // Email do usuário
        Text(
          data.email,
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        // Badge de "Perfil Verificado"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(
                'Perfil Verificado',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontSize: 12,
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
