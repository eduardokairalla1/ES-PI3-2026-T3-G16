/// --- Pintor de Gráfico de Linha ---

import 'package:flutter/material.dart';

/// Eu desenho um gráfico de linha simples baseado nos pontos fornecidos.
/// Se um índice selecionado for passado, desenho um destaque nesse ponto.
class LineChartPainter extends CustomPainter {
  final List<double> pontos;
  final Color color;
  final int? indiceSelecionado;

  LineChartPainter({
    required this.pontos,
    this.color = Colors.blue,
    this.indiceSelecionado,
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

    // Margem superior para o tooltip não cortar
    final double topMargin = 30.0;
    final double chartHeight = size.height - topMargin;

    for (int i = 0; i < pontos.length; i++) {
      final double x = i * stepX;
      final double y = topMargin + chartHeight - ((pontos[i] - minVal) / range * chartHeight);

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

    // Desenha destaque no ponto selecionado
    if (indiceSelecionado != null && indiceSelecionado! >= 0 && indiceSelecionado! < pontos.length) {
      final double sx = indiceSelecionado! * stepX;
      final double sy = topMargin + chartHeight - ((pontos[indiceSelecionado!] - minVal) / range * chartHeight);

      // Linha vertical tracejada
      final dashPaint = Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(sx, topMargin), Offset(sx, size.height), dashPaint);

      // Ponto de destaque
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), 5, dotPaint);

      // Borda branca no ponto
      final dotBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(sx, sy), 5, dotBorderPaint);

      // Tooltip flutuante com o valor
      final valor = pontos[indiceSelecionado!];
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

      // Posiciona o tooltip acima do ponto
      final tooltipWidth = textPainter.width + 16;
      final tooltipHeight = textPainter.height + 8;
      double tooltipX = sx - tooltipWidth / 2;
      final double tooltipY = sy - tooltipHeight - 12;

      // Garante que o tooltip não saia da tela
      if (tooltipX < 0) tooltipX = 0;
      if (tooltipX + tooltipWidth > size.width) tooltipX = size.width - tooltipWidth;

      // Fundo do tooltip
      final tooltipRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
        const Radius.circular(6),
      );
      final tooltipBgPaint = Paint()..color = Colors.black87;
      canvas.drawRRect(tooltipRect, tooltipBgPaint);

      // Texto do tooltip
      textPainter.paint(canvas, Offset(tooltipX + 8, tooltipY + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
