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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: TextButton(
        onPressed: () => controller.logout(),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey[100]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              'Sair da Conta',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
