/// --- Página de Portfólio ---

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/portfolio/controllers/portfolio_controller.dart';
import 'package:mesclainvest/pages/portfolio/widgets/widgets.dart';

/// Eu represento a tela principal de Portfólio.
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
      backgroundColor: PortfolioStyles.backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
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
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          // Outras rotas ainda não implementadas
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Portfólio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Balcão',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
