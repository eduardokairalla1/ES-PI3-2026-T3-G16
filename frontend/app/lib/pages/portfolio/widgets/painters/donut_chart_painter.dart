/// --- Pintor de Gráfico de Rosca ---

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';

/// Eu desenho um gráfico de rosca usando arcos.
/// Se um índice selecionado for passado, destaco o segmento e mostro um tooltip.
class DonutChartPainter extends CustomPainter {
  final List<PortfolioDistribution> distribuicao;
  final List<Color> colors;
  final int? indiceSelecionado;

  DonutChartPainter({
    required this.distribuicao,
    required this.colors,
    this.indiceSelecionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(centerX, centerY);
    final double thickness = 15.0;
    final double selectedThickness = 22.0;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < distribuicao.length; i++) {
      final sweepAngle = distribuicao[i].percentual * 2 * math.pi;
      final isSelected = indiceSelecionado == i;
      final currentThickness = isSelected ? selectedThickness : thickness;

      final rect = Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius - (currentThickness / 2),
      );

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = currentThickness
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);

      // Tooltip flutuante no segmento selecionado
      if (isSelected) {
        // Calcula posição no meio do arco
        final midAngle = startAngle + sweepAngle / 2;
        final tooltipRadius = radius + 20;
        double tooltipX = centerX + tooltipRadius * math.cos(midAngle);
        double tooltipY = centerY + tooltipRadius * math.sin(midAngle);

        final item = distribuicao[i];
        final percentStr = '${(item.percentual * 100).toInt()}%';
        final label = '${item.nome} · $percentStr';

        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
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
        double tx = tooltipX - tooltipWidth / 2;
        double ty = tooltipY - tooltipHeight / 2;

        // Garante que não saia da tela
        if (tx < 0) tx = 0;
        if (tx + tooltipWidth > size.width) tx = size.width - tooltipWidth;
        if (ty < 0) ty = 0;
        if (ty + tooltipHeight > size.height) ty = size.height - tooltipHeight;

        final tooltipRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(tx, ty, tooltipWidth, tooltipHeight),
          const Radius.circular(6),
        );
        canvas.drawRRect(tooltipRect, Paint()..color = Colors.black87);
        textPainter.paint(canvas, Offset(tx + 8, ty + 4));
      }

      startAngle += sweepAngle;
    }
  }

  /// Calcula qual segmento contém o ponto (x, y).
  /// Retorna o índice do segmento ou null se nenhum foi tocado.
  static int? hitTest(
    Offset position,
    Size size,
    List<PortfolioDistribution> distribuicao,
  ) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(centerX, centerY);
    final double thickness = 15.0;

    final dx = position.dx - centerX;
    final dy = position.dy - centerY;
    final distance = math.sqrt(dx * dx + dy * dy);

    // Verifica se o toque está na área do anel
    final innerRadius = radius - thickness;
    final outerRadius = radius;
    if (distance < innerRadius - 5 || distance > outerRadius + 10) return null;

    // Calcula o ângulo do toque
    double angle = math.atan2(dy, dx);
    // Ajusta para começar do topo (-π/2)
    angle += math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    // Encontra qual segmento contém esse ângulo
    double startAngle = 0;
    for (int i = 0; i < distribuicao.length; i++) {
      final sweepAngle = distribuicao[i].percentual * 2 * math.pi;
      if (angle >= startAngle && angle < startAngle + sweepAngle) {
        return i;
      }
      startAngle += sweepAngle;
    }

    return null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
