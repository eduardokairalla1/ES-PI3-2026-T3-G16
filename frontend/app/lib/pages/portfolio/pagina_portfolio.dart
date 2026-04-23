/// --- Página de Portfólio ---

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/portfolio/controllers/portfolio_controller.dart';
import 'package:mesclainvest/pages/portfolio/widgets/widgets.dart';

/// I represent the main Portfolio screen.
class PaginaPortfolio extends StatefulWidget {
  const PaginaPortfolio({super.key});

  @override
  State<PaginaPortfolio> createState() => _PaginaPortfolioState();
}

class _PaginaPortfolioState extends State<PaginaPortfolio> {
  late final PortfolioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PortfolioController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }

            final data = _controller.data;
            if (data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não foi possível carregar os dados.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _controller.loadPortfolio,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CabecalhoPortfolio(userName: data.userName),
                  CartaoPatrimonioPortfolio(
                    patrimonioTotal: data.patrimonioTotal,
                    lucroTotal: data.lucroTotal,
                    valorInvestido: data.valorInvestido,
                    lucroPorToken: data.lucroPorToken,
                    posicoesAtivas: data.posicoesAtivas,
                    isObscured: _controller.isObscured,
                    onToggleVisibility: _controller.toggleVisibility,
                  ),
                  GraficoEvolucao(pontos: data.evolucaoPontos),
                  DistribuicaoPatrimonio(distribuicao: data.distribuicao),
                  HistoricoTransacoes(transacoes: data.transacoes),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Portfólio selecionado
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          // Outras rotas ainda não implementadas conforme plano
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Portfólio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Balcão',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
