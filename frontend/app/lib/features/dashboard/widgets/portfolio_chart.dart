/// --- Portfolio Chart widget ---

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/features/dashboard/models/portfolio_snapshot.dart';

/// I render a line chart of the portfolio value over time.
///
/// Receives a list of [PortfolioSnapshot] and plots them as a smooth line.
class PortfolioChart extends StatelessWidget {
  /// Ordered list of snapshots (oldest → newest).
  final List<PortfolioSnapshot> snapshots;

  // constructor
  const PortfolioChart({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Sem dados para o período')),
      );
    }

    final spots = snapshots.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalValue);
    }).toList();

    final minY = snapshots.map((s) => s.totalValue).reduce((a, b) => a < b ? a : b);
    final maxY = snapshots.map((s) => s.totalValue).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    final colorScheme = Theme.of(context).colorScheme;
    final lineColor = colorScheme.primary;
    final gradientColor = colorScheme.primary.withOpacity(0.15);

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LineChart(
          LineChartData(
            minY: minY - padding,
            maxY: maxY + padding,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 56,
                  getTitlesWidget: (value, meta) => Text(
                    'R\$${(value / 1000).toStringAsFixed(1)}k',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: lineColor,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: gradientColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
