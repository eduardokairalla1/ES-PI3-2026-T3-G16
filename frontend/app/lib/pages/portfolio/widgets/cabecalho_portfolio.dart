/// --- Cabeçalho do Portfólio ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/widgets/portfolio_styles.dart';

/// Eu represento o cabeçalho superior da tela de portfólio.
class CabecalhoPortfolio extends StatelessWidget {
  final String userName;

  const CabecalhoPortfolio({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: PortfolioStyles.cardDecoration,
        child: Row(
          children: [
            // Avatar preto com inicial branca
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  inicial,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nome do usuário (sem "Olá,")
            Text(
              userName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PortfolioStyles.textPrimary,
              ),
            ),
            const Spacer(),
            // Ícone de notificações
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_outlined,
                color: PortfolioStyles.textPrimary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
