/// --- Página do Dashboard ---
/// Tela principal que monta todas as seções do dashboard.

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/widgets.dart';


// --- CÓDIGO ---

/// Eu represento a página do dashboard.
class PaginaDashboard extends StatelessWidget {

  // construtor
  const PaginaDashboard({super.key});


  /// Eu construo a árvore de widgets para a página do dashboard.
  ///
  /// :returns: a árvore de widgets para esta página
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Fase 1: Cabeçalho — Barra Superior
              const CabecalhoDashboard(),

              // Fase 2 — "Meu Patrimônio" (Cartão de Patrimônio)
              const CartaoPatrimonio(),
              // Fase 3 — Botões de Ação Rápida
              const BotoesAcao(),
              // TODO: Fase 4 — Resumo de Mercado (Estatísticas KPI)
              // TODO: Fase 5 — "Startups do Ecossistema"
              // TODO: Fase 6 — "Meus Investimentos"

            ],
          ),
        ),
      ),
      // TODO: Fase 7 — Navegação Global (Barra de Navegação Inferior)
    );
  }
}
