/// View principal do Dashboard.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/widgets.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';

/// Tela principal que compõe o Dashboard.
class PaginaDashboard extends StatefulWidget {

  const PaginaDashboard({super.key});

  @override
  State<PaginaDashboard> createState() => _PaginaDashboardState();
}

class _PaginaDashboardState extends State<PaginaDashboard> {
  // Controlador de estado e dados.
  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    // Carrega dados iniciais via API.
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Renderização baseada no estado do controller.
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
                        // Cabeçalho — Barra Superior
                        CabecalhoDashboard(controller: _controller),

                        // Patrimônio atual
                        CartaoPatrimonio(controller: _controller),
                        
                        // Ações rápidas (Depósito, Compra, Venda, Extrato)
                        const BotoesAcao(),
                        
                        // Indicadores de Mercado (KPIs)
                        ResumoMercado(controller: _controller),
                        // TODO: Listagem de startups
                        // TODO: Ativos da carteira
                      ],
                    ),
                  ),
          ),
          // TODO: Navegação Global (BottomNavigationBar)
        );
      },
    );
  }
}
