/// Eduardo Kairalla - 24024241

/// Help & Support screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


// --- PAGE ---

class HelpPage extends StatelessWidget {

  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go('/profile'),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: const Text(
          'Ajuda & Suporte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _faqCard(
            question: 'O que é o MesclaInvest?',
            answer:   'O MesclaInvest é uma plataforma simulada de investimento em startups, '
                      'desenvolvida como projeto integrador da PUC-Campinas.',
          ),
          const SizedBox(height: 12),
          _faqCard(
            question: 'Como funcionam os tokens?',
            answer:   'Cada startup emite uma quantidade de tokens. Ao investir, você adquire '
                      'tokens proporcionais ao valor aplicado. O valor dos tokens varia com o '
                      'desempenho da startup.',
          ),
          const SizedBox(height: 12),
          _faqCard(
            question: 'O que é a autenticação 2FA?',
            answer:   'A autenticação em dois fatores adiciona uma camada extra de segurança '
                      'à sua conta. Quando ativada, além da senha, você precisará confirmar '
                      'o acesso por um segundo método.',
          ),
          const SizedBox(height: 12),
          _faqCard(
            question: 'Como entro em contato com o suporte?',
            answer:   'Para este projeto, o suporte é prestado pelos desenvolvedores via '
                      'e-mail: suporte@mesclainvest.com.br',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.email_outlined, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fale conosco',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'suporte@mesclainvest.com.br',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
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

  Widget _faqCard({required String question, required String answer}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
