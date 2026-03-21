/// --- Página do Dashboard ---
/// Tela principal que monta todas as seções do dashboard.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/widgets.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';

/// Tela principal que compõe o Dashboard.
class PaginaDashboard extends StatefulWidget {

  // construtor
  const PaginaDashboard({super.key});

  @override
  State<PaginaDashboard> createState() => _PaginaDashboardState();
}

class _PaginaDashboardState extends State<PaginaDashboard> {
  // A verdadeira chamada para APIs reais acontecerá nesse controlador
  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    // Simula a obtenção de dados e inicialização de variáveis via API.
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Build reativo atrelado ao DashboardController.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fase 1: Cabeçalho — Barra Superior
                        CabecalhoDashboard(controller: _controller),

                        // Fase 2 — "Meu Patrimônio"
                        CartaoPatrimonio(controller: _controller),
                        
                        // Fase 3 — Botões de Ação Rápida
                        const BotoesAcao(),
                        
                        // Fase 4 — Resumo de Mercado (Estatísticas KPI)
                        ResumoMercado(controller: _controller),
                        // TODO: Fase 5 — "Startups do Ecossistema"
                        // TODO: Fase 6 — "Meus Investimentos"
                      ],
                    ),
                  ),
          ),
          // TODO: Fase 7 — Navegação Global (Barra de Navegação Inferior)
        );
      },
    );
  }
}
