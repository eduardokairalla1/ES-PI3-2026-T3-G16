/// --- Pintor de Gráfico de Barras ---

import 'package:flutter/material.dart';

/// Eu desenho um gráfico de barras simples baseado nos pontos fornecidos.
/// Se um índice selecionado for passado, desenho um destaque nessa barra.
class BarChartPainter extends CustomPainter {
  final List<double> pontos;
  final Color color;
  final int? indiceSelecionado;

  BarChartPainter({
    required this.pontos,
    this.color = Colors.black87,
    this.indiceSelecionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.isEmpty) return;

    // Margem superior para o tooltip
    final double topMargin = 30.0;
    final double chartHeight = size.height - topMargin;

    final double width = size.width / pontos.length;
    final double spacing = width * 0.2;
    final double barWidth = width - spacing;

    final double maxVal = pontos.reduce((a, b) => a > b ? a : b);
    final double range = maxVal == 0 ? 1 : maxVal;

    for (int i = 0; i < pontos.length; i++) {
      final double x = i * width + (spacing / 2);
      final double barHeight = (pontos[i] / range) * chartHeight;
      final double y = topMargin + chartHeight - barHeight;

      final isSelected = indiceSelecionado == i;

      final paint = Paint()
        ..color = isSelected ? Colors.black : color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );

      // Tooltip flutuante na barra selecionada
      if (isSelected) {
        final valor = pontos[i];
        final valorStr = 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

        final textPainter = TextPainter(
          text: TextSpan(
            text: valorStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final tooltipWidth = textPainter.width + 16;
        final tooltipHeight = textPainter.height + 8;
        double tooltipX = x + barWidth / 2 - tooltipWidth / 2;
        final double tooltipY = y - tooltipHeight - 8;

        if (tooltipX < 0) tooltipX = 0;
        if (tooltipX + tooltipWidth > size.width) tooltipX = size.width - tooltipWidth;

        final tooltipRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(tooltipX, tooltipY < 0 ? 0 : tooltipY, tooltipWidth, tooltipHeight),
          const Radius.circular(6),
        );
        canvas.drawRRect(tooltipRect, Paint()..color = Colors.black87);
        textPainter.paint(canvas, Offset(tooltipX + 8, (tooltipY < 0 ? 0 : tooltipY) + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
