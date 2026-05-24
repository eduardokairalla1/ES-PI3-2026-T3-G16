// Eduardo Kairalla - 24024241

// Help & Support screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- PAGE ---

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        leading: GestureDetector(
          onTap: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
          child: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
        ),
        centerTitle: true,
        title: Text(
          'Ajuda & Suporte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border(context)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _faqCard(
            context: context,
            question: 'O que é o MesclaInvest?',
            answer:
                'O MesclaInvest é uma plataforma simulada de investimento em startups, '
                'desenvolvida como projeto integrador da PUC-Campinas.',
          ),
          const SizedBox(height: 12),
          _faqCard(
            context: context,
            question: 'Como funcionam os tokens?',
            answer:
                'Cada startup emite uma quantidade de tokens. Ao investir, você adquire '
                'tokens proporcionais ao valor aplicado. O valor dos tokens varia com o '
                'desempenho da startup.',
          ),
          const SizedBox(height: 12),
          _faqCard(
            context: context,
            question: 'O que é a autenticação 2FA?',
            answer:
                'A autenticação em dois fatores adiciona uma camada extra de segurança '
                'à sua conta. Quando ativada, além da senha, você precisará confirmar '
                'o acesso por um segundo método.',
          ),
          const SizedBox(height: 12),
          _faqCard(
            context: context,
            question: 'Como entro em contato com o suporte?',
            answer:
                'Para este projeto, o suporte é prestado pelos desenvolvedores via '
                'e-mail: suporte@mesclainvest.com.br',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fale conosco',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'suporte@mesclainvest.com.br',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqCard({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
