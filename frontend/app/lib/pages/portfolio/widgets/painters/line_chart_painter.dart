/// --- Pintor de Gráfico de Linha ---

import 'package:flutter/material.dart';

/// Eu desenho um gráfico de linha simples baseado nos pontos fornecidos.
class LineChartPainter extends CustomPainter {
  final List<double> pontos;
  final Color color;

  LineChartPainter({
    required this.pontos,
    this.color = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final double stepX = size.width / (pontos.length - 1);
    final double maxVal = pontos.reduce((a, b) => a > b ? a : b);
    final double minVal = pontos.reduce((a, b) => a < b ? a : b);
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    for (int i = 0; i < pontos.length; i++) {
      final double x = i * stepX;
      // inverte Y pois o 0 é no topo
      final double y = size.height - ((pontos[i] - minVal) / range * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == pontos.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
