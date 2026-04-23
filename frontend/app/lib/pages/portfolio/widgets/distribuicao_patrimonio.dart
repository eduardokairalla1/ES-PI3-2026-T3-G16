/// --- Distribuição de Patrimônio ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';
import 'package:mesclainvest/pages/portfolio/widgets/cartao_base.dart';
import 'package:mesclainvest/pages/portfolio/widgets/painters/donut_chart_painter.dart';
import 'package:mesclainvest/pages/portfolio/widgets/portfolio_styles.dart';

/// Eu represento um cartão mostrando a distribuição de ativos em um gráfico de rosca.
class DistribuicaoPatrimonio extends StatefulWidget {
  final List<PortfolioDistribution> distribuicao;

  const DistribuicaoPatrimonio({
    super.key,
    required this.distribuicao,
  });

  @override
  State<DistribuicaoPatrimonio> createState() => _DistribuicaoPatrimonioState();
}

class _DistribuicaoPatrimonioState extends State<DistribuicaoPatrimonio> {
  int? _indiceSelecionado;

  final List<Color> _colors = const [
    Color(0xFF4A4A4A),  // FinnoLab - cinza escuro
    Color(0xFFD4A574),  // DataBrave - bege/marrom claro
    Color(0xFF8FBC8F),  // GreenLoop - verde suave
  ];

  @override
  Widget build(BuildContext context) {
    return CartaoBase(
      child: Column(
        children: [
          // Título
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Distribuição do Patrimônio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PortfolioStyles.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Gráfico de rosca com interação
          _buildChartWithInteraction(),
          const SizedBox(height: 20),
          // Legenda em linha horizontal
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildChartWithInteraction() {
    const double chartSize = 160.0;

    return GestureDetector(
      onTapDown: (details) => _handleTouch(details.localPosition, chartSize),
      onPanStart: (details) => _handleTouch(details.localPosition, chartSize),
      onPanUpdate: (details) => _handleTouch(details.localPosition, chartSize),
      onPanEnd: (_) => setState(() => _indiceSelecionado = null),
      onTapUp: (_) => Future.delayed(
        const Duration(seconds: 2),
        () { if (mounted) setState(() => _indiceSelecionado = null); },
      ),
      child: SizedBox(
        height: chartSize,
        width: chartSize,
        child: CustomPaint(
          painter: DonutChartPainter(
            distribuicao: widget.distribuicao,
            colors: _colors,
            indiceSelecionado: _indiceSelecionado,
          ),
        ),
      ),
    );
  }

  void _handleTouch(Offset localPosition, double chartSize) {
    final size = Size(chartSize, chartSize);
    final index = DonutChartPainter.getHitIndex(
      localPosition,
      size,
      widget.distribuicao,
    );

    if (index != _indiceSelecionado) {
      setState(() => _indiceSelecionado = index);
    }
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.distribuicao.length, (index) {
        final item = widget.distribuicao[index];
        final color = _colors[index % _colors.length];
        final isSelected = _indiceSelecionado == index;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                item.nome,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? PortfolioStyles.textPrimary : PortfolioStyles.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
