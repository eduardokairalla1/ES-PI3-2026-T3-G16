/// --- Pintor de Gráfico de Velas (Mock) ---

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Eu desenho um gráfico de velas simulado baseado nos pontos fornecidos.
class CandleChartPainter extends CustomPainter {
  final List<double> pontos;

  CandleChartPainter({required this.pontos});

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.isEmpty) return;

    final double width = size.width / pontos.length;
    final double candleWidth = width * 0.6;
    final double maxVal = pontos.reduce((a, b) => a > b ? a : b);
    
    final random = math.Random(42); // Semente fixa para consistência visual

    for (int i = 0; i < pontos.length; i++) {
      final double x = i * width + (width / 2);
      
      // Simula OHLC baseado no ponto único
      final bool isUp = i == 0 || pontos[i] >= pontos[i-1];
      final double open = pontos[i] * (0.95 + random.nextDouble() * 0.1);
      final double close = pontos[i];
      final double high = math.max(open, close) * (1.0 + random.nextDouble() * 0.05);
      final double low = math.min(open, close) * (0.95 - random.nextDouble() * 0.05);

      final paint = Paint()
        ..color = isUp ? Colors.green : Colors.red
        ..strokeWidth = 2
        ..style = PaintingStyle.fill;

      final wickPaint = Paint()
        ..color = isUp ? Colors.green : Colors.red
        ..strokeWidth = 1;

      // Desenha o pavio
      canvas.drawLine(
        Offset(x, size.height - (high / maxVal * size.height)),
        Offset(x, size.height - (low / maxVal * size.height)),
        wickPaint,
      );

      // Desenha o corpo
      final double top = size.height - (math.max(open, close) / maxVal * size.height);
      final double bottom = size.height - (math.min(open, close) / maxVal * size.height);
      
      canvas.drawRect(
        Rect.fromLTRB(x - candleWidth / 2, top, x + candleWidth / 2, bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
