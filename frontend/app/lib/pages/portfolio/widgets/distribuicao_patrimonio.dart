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
      const Color(0xFF4A4A4A),  // FinnoLab - cinza escuro
      const Color(0xFFD4A574),  // DataBrave - bege/marrom claro
      const Color(0xFF8FBC8F),  // GreenLoop - verde suave
    ];

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
          // Gráfico de rosca centralizado
          SizedBox(
            height: 140,
            width: 140,
            child: CustomPaint(
              painter: DonutChartPainter(
                distribuicao: distribuicao,
                colors: colors,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legenda em linha horizontal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(distribuicao.length, (index) {
              final item = distribuicao[index];
              final color = colors[index % colors.length];
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
                      style: const TextStyle(
                        fontSize: 11,
                        color: PortfolioStyles.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
