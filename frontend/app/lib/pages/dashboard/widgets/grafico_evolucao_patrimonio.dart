import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';

class GraficoEvolucaoPatrimonio extends StatefulWidget {
  final DashboardController controller;

  const GraficoEvolucaoPatrimonio({super.key, required this.controller});

  @override
  State<GraficoEvolucaoPatrimonio> createState() => _GraficoEvolucaoPatrimonioState();
}

class _GraficoEvolucaoPatrimonioState extends State<GraficoEvolucaoPatrimonio> {
  String _selectedPeriod = 'monthly';

  final List<(String, String)> _periods = const [
    ('daily', 'Diário'),
    ('weekly', 'Semanal'),
    ('monthly', 'Mensal'),
    ('6months', '6 Meses'),
    ('ytd', 'YTD'),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.controller.data == null) return const SizedBox.shrink();

    final currentPatrimony = widget.controller.data!.patrimonioTotal;
    
    // Generate mock history based on selected period
    final spots = _generateMockHistory(currentPatrimony, _selectedPeriod);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolução do Patrimônio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: _buildChart(spots),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _periods.map((entry) {
          final isSelected = _selectedPeriod == entry.$1;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = entry.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                entry.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(List<FlSpot> spots) {
    if (spots.isEmpty) return const SizedBox.shrink();

    final prices = spots.map((s) => s.y).toList();
    final minY = prices.reduce(min) * 0.95;
    final maxY = prices.reduce(max) * 1.05;
    
    final isUp = spots.last.y >= spots.first.y;
    final color = isUp ? Colors.green : Colors.red;
    final dateFmt = DateFormat('dd/MM');

    return LineChart(
      LineChartData(
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (v, _) => Text(
                'R\$${(v/1000).toStringAsFixed(1)}k',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: max((spots.last.x - spots.first.x) / 4, 1.0),
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  dateFmt.format(DateTime.fromMillisecondsSinceEpoch(v.toInt())),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) => LineTooltipItem(
              'R\$${s.y.toStringAsFixed(2)}',
              const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            )).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: color,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateMockHistory(double finalValue, String period) {
    int days = 30;
    switch (period) {
      case 'daily': days = 1; break;
      case 'weekly': days = 7; break;
      case 'monthly': days = 30; break;
      case '6months': days = 180; break;
      case 'ytd': days = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays; break;
    }

    final random = Random(42); // fixed seed for consistent look
    final spots = <FlSpot>[];
    final now = DateTime.now();
    
    // Simulate a random walk starting from finalValue backwards
    double currentVal = finalValue;
    spots.add(FlSpot(now.millisecondsSinceEpoch.toDouble(), currentVal));

    for (int i = 1; i <= days; i++) {
      // 1% daily volatility
      final change = 1 + (random.nextDouble() * 0.02 - 0.008); 
      currentVal = currentVal / change;
      final date = now.subtract(Duration(days: i));
      spots.insert(0, FlSpot(date.millisecondsSinceEpoch.toDouble(), currentVal));
    }

    return spots;
  }
}
