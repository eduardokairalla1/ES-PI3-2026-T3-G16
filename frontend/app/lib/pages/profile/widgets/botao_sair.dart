import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/controllers/perfil_controller.dart';

/// [BotaoSair] representa a ação de logout na tela de perfil.
/// 
/// É estilizado como um botão de largura total com fundo branco, borda leve
/// e uma sombra sutil para se destacar dos outros itens de menu.
class BotaoSair extends StatelessWidget {
  final PerfilController controller;

  const BotaoSair({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            // Sombra sutil para dar elevação ao botão de ação principal.
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextButton(
          onPressed: () => controller.logout(), // Dispara o método de logout no controlador.
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56), // Altura maior para melhor usabilidade no toque.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE8E8E8)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Color(0xFF555555), size: 24),
              const SizedBox(width: 10),
              Text(
                'Sair da Conta',
                style: GoogleFonts.inter(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
