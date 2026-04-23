/// --- Distribuição de Patrimônio ---

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';

/// Eu represento um cartão mostrando a distribuição de ativos em um gráfico de rosca.
class DistribuicaoPatrimonio extends StatelessWidget {
  final List<PortfolioDistribution> distribuicao;

  const DistribuicaoPatrimonio({
    super.key,
    required this.distribuicao,
  });

  @override
  Widget build(BuildContext context) {
    // Cores para o gráfico
    final List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribuição do Patrimônio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    distribuicao: distribuicao,
                    colors: colors,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: List.generate(distribuicao.length, (index) {
                    final item = distribuicao[index];
                    final color = colors[index % colors.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.nome,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            '${(item.percentual * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Eu desenho um gráfico de rosca usando arcos.
class _DonutChartPainter extends CustomPainter {
  final List<PortfolioDistribution> distribuicao;
  final List<Color> colors;

  _DonutChartPainter({
    required this.distribuicao,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(centerX, centerY);
    final double thickness = 15.0;

    final rect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius - (thickness / 2),
    );

    double startAngle = -math.pi / 2;

    for (int i = 0; i < distribuicao.length; i++) {
      final sweepAngle = distribuicao[i].percentual * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      // Desenha o arco levemente menor para criar um espaço se necessário, ou apenas o arco completo
      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
