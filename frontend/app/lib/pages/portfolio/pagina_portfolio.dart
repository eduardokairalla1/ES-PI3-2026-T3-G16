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

class _PaginaPortfolioState extends State<PaginaPortfolio>
    with TickerProviderStateMixin {
  late final PortfolioController _controller;
  late final AnimationController _entranceController;

  // Animações escalonadas para cada card
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

  static const int _totalCards = 5; // cabeçalho, patrimônio, gráfico, distribuição, histórico

  @override
  void initState() {
    super.initState();
    _controller = PortfolioController();

    // Controller da animação de entrada (1.2s total)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Cria animações escalonadas para cada card
    for (int i = 0; i < _totalCards; i++) {
      final start = i * 0.15; // 150ms de atraso entre cada card
      final end = start + 0.4; // cada animação dura 40% do total

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
          ),
        ),
      );

      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    // Inicia a animação quando os dados carregarem
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!_controller.isLoading && _controller.data != null) {
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _entranceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Envolve um widget com animação de entrada escalonada.
  Widget _animatedCard(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
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
                  _animatedCard(0, CabecalhoPortfolio(userName: data.userName)),
                  _animatedCard(1, CartaoPatrimonioPortfolio(
                    patrimonioTotal: data.patrimonioTotal,
                    lucroTotal: data.lucroTotal,
                    valorInvestido: data.valorInvestido,
                    lucroPorToken: data.lucroPorToken,
                    posicoesAtivas: data.posicoesAtivas,
                    isObscured: _controller.isObscured,
                    onToggleVisibility: _controller.toggleVisibility,
                  )),
                  _animatedCard(2, GraficoEvolucao(pontos: data.evolucaoPontos)),
                  _animatedCard(3, DistribuicaoPatrimonio(distribuicao: data.distribuicao)),
                  _animatedCard(4, HistoricoTransacoes(transacoes: data.transacoes)),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
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
