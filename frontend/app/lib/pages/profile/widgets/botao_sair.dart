import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/controllers/perfil_controller.dart';

/// Botão de encerramento de sessão.
class BotaoSair extends StatelessWidget {
  final PerfilController controller;

  const BotaoSair({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: TextButton(
        onPressed: () => controller.logout(),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Color(0xFF333333), size: 18),
            const SizedBox(width: 6),
            Text(
              'Sair da Conta',
              style: GoogleFonts.inter(
                color: const Color(0xFF111111),
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
