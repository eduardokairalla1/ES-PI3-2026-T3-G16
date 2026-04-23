/// --- Pintor de Gráfico de Barras ---

import 'package:flutter/material.dart';

/// Eu desenho um gráfico de barras simples baseado nos pontos fornecidos.
class BarChartPainter extends CustomPainter {
  final List<double> pontos;
  final Color color;

  BarChartPainter({
    required this.pontos,
    this.color = Colors.black87,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width / pontos.length;
    final double spacing = width * 0.2;
    final double barWidth = width - spacing;

    final double maxVal = pontos.reduce((a, b) => a > b ? a : b);
    final double minVal = pontos.reduce((a, b) => a < b ? a : b);
    final double range = maxVal - minVal == 0 ? 1 : maxVal; // Usa 0 como base para barras

    for (int i = 0; i < pontos.length; i++) {
      final double x = i * width + (spacing / 2);
      final double barHeight = (pontos[i] / range) * size.height;
      final double y = size.height - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
