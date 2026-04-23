/// --- Distribuição de Patrimônio ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';
import 'package:mesclainvest/pages/portfolio/widgets/cartao_base.dart';
import 'package:mesclainvest/pages/portfolio/widgets/painters/donut_chart_painter.dart';
import 'package:mesclainvest/pages/portfolio/widgets/portfolio_styles.dart';

/// Eu represento um cartão mostrando a distribuição de ativos em um gráfico de rosca.
class DistribuicaoPatrimonio extends StatelessWidget {
  final List<PortfolioDistribution> distribuicao;

  const DistribuicaoPatrimonio({
    super.key,
    required this.distribuicao,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
    ];

    return CartaoBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribuição do Patrimônio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PortfolioStyles.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildChart(colors),
              const SizedBox(width: 24),
              Expanded(child: _buildLegend(colors)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<Color> colors) {
    return SizedBox(
      height: 120,
      width: 120,
      child: CustomPaint(
        painter: DonutChartPainter(
          distribuicao: distribuicao,
          colors: colors,
        ),
      ),
    );
  }

  Widget _buildLegend(List<Color> colors) {
    return Column(
      children: List.generate(distribuicao.length, (index) {
        final item = distribuicao[index];
        final color = colors[index % colors.length];
        return _LegendItem(item: item, color: color);
      }),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final PortfolioDistribution item;
  final Color color;

  const _LegendItem({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.nome,
              style: const TextStyle(fontSize: 13, color: PortfolioStyles.textPrimary),
            ),
          ),
          Text(
            '${(item.percentual * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: PortfolioStyles.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
