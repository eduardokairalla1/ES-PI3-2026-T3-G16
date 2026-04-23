/// --- Gráfico de Evolução ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/widgets/cartao_base.dart';
import 'package:mesclainvest/pages/portfolio/widgets/painters/line_chart_painter.dart';
import 'package:mesclainvest/pages/portfolio/widgets/portfolio_styles.dart';

/// Eu represento um cartão com um gráfico de linha mostrando a evolução do portfólio.
class GraficoEvolucao extends StatelessWidget {
  final List<double> pontos;

  const GraficoEvolucao({
    super.key,
    required this.pontos,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildChartTypeSelector(),
          const SizedBox(height: 12),
          _buildChart(),
          const SizedBox(height: 12),
          _buildTimelineLabels(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ícone de gráfico + título
        const Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 20, color: PortfolioStyles.textPrimary),
            SizedBox(width: 8),
            Text(
              'Evolução do Patrimônio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PortfolioStyles.textPrimary,
              ),
            ),
          ],
        ),
        _buildPeriodButton(),
      ],
    );
  }

  Widget _buildPeriodButton() {
    return PopupMenuButton<String>(
      initialValue: 'Período',
      onSelected: (String value) {
        // Lógica de filtro será implementada no futuro
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: '7_dias',
          child: Text('7 dias'),
        ),
        const PopupMenuItem<String>(
          value: '1_mes',
          child: Text('1 mês'),
        ),
        const PopupMenuItem<String>(
          value: '6_meses',
          child: Text('6 meses'),
        ),
        const PopupMenuItem<String>(
          value: '12_meses',
          child: Text('12 meses'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Text(
              'Período',
              style: TextStyle(fontSize: 12, color: PortfolioStyles.textSecondary),
            ),
            Icon(Icons.arrow_drop_down, color: PortfolioStyles.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Row(
      children: [
        _ChartTypeIcon(icon: Icons.show_chart, isSelected: true, label: 'Linha'),
        const SizedBox(width: 8),
        _ChartTypeIcon(icon: Icons.bar_chart, isSelected: false, label: 'Barra'),
        const SizedBox(width: 8),
        _ChartTypeIcon(icon: Icons.candlestick_chart, isSelected: false, label: 'Vela'),
      ],
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: LineChartPainter(pontos: pontos, color: Colors.black87),
      ),
    );
  }

  Widget _buildTimelineLabels() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TimeLabel('11:00'),
        _TimeLabel('13:00'),
        _TimeLabel('15:00'),
        _TimeLabel('17:00'),
      ],
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  const _TimeLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 10, color: PortfolioStyles.textSecondary),
    );
  }
}

class _ChartTypeIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final String label;

  const _ChartTypeIcon({
    required this.icon,
    required this.isSelected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade300,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : Colors.grey,
      ),
    );
  }
}
