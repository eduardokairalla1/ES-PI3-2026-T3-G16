/// --- Pintor de Gráfico de Rosca ---

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';

/// Eu desenho um gráfico de rosca usando arcos.
class DonutChartPainter extends CustomPainter {
  final List<PortfolioDistribution> distribuicao;
  final List<Color> colors;

  DonutChartPainter({
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
