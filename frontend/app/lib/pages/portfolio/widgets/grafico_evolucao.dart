/// --- Gráfico de Evolução ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/widgets/cartao_base.dart';
import 'package:mesclainvest/pages/portfolio/widgets/painters/line_chart_painter.dart';
import 'package:mesclainvest/pages/portfolio/widgets/painters/bar_chart_painter.dart';
import 'package:mesclainvest/pages/portfolio/widgets/painters/candle_chart_painter.dart';
import 'package:mesclainvest/pages/portfolio/widgets/portfolio_styles.dart';

/// Tipos de gráfico disponíveis.
enum TipoGrafico { linha, barra, vela }

/// Eu represento um cartão com um gráfico que mostra a evolução do patrimônio.
/// Permito alternar entre diferentes tipos de visualização (linha, barra, vela).
class GraficoEvolucao extends StatefulWidget {
  final List<double> pontos;

  const GraficoEvolucao({
    super.key,
    required this.pontos,
  });

  @override
  State<GraficoEvolucao> createState() => _GraficoEvolucaoState();
}

class _GraficoEvolucaoState extends State<GraficoEvolucao> {
  TipoGrafico _tipoSelecionado = TipoGrafico.linha;
  String _periodoSelecionado = '7 dias'; // Período padrão

  @override
  Widget build(BuildContext context) {
    return CartaoBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildChart(),
          const SizedBox(height: 12),
          _buildTimelineLabels(),
          const SizedBox(height: 16),
          _buildChartTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
      initialValue: _periodoSelecionado,
      onSelected: (String value) {
        setState(() {
          _periodoSelecionado = value;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: '7 dias', child: Text('7 dias')),
        const PopupMenuItem<String>(value: '1 mês', child: Text('1 mês')),
        const PopupMenuItem<String>(value: '6 meses', child: Text('6 meses')),
        const PopupMenuItem<String>(value: '12 meses', child: Text('12 meses')),
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
              _periodoSelecionado,
              style: const TextStyle(fontSize: 12, color: PortfolioStyles.textSecondary),
            ),
            Icon(Icons.arrow_drop_down, color: PortfolioStyles.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ChartTypeIcon(
          icon: Icons.show_chart,
          isSelected: _tipoSelecionado == TipoGrafico.linha,
          onTap: () => setState(() => _tipoSelecionado = TipoGrafico.linha),
        ),
        const SizedBox(width: 8),
        _ChartTypeIcon(
          icon: Icons.bar_chart,
          isSelected: _tipoSelecionado == TipoGrafico.barra,
          onTap: () => setState(() => _tipoSelecionado = TipoGrafico.barra),
        ),
        const SizedBox(width: 8),
        _ChartTypeIcon(
          icon: Icons.candlestick_chart,
          isSelected: _tipoSelecionado == TipoGrafico.vela,
          onTap: () => setState(() => _tipoSelecionado = TipoGrafico.vela),
        ),
      ],
    );
  }

  Widget _buildChart() {
    CustomPainter painter;

    switch (_tipoSelecionado) {
      case TipoGrafico.barra:
        painter = BarChartPainter(pontos: widget.pontos);
        break;
      case TipoGrafico.vela:
        painter = CandleChartPainter(pontos: widget.pontos);
        break;
      case TipoGrafico.linha:
      default:
        painter = LineChartPainter(pontos: widget.pontos, color: Colors.black87);
        break;
    }

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: painter,
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
  final VoidCallback onTap;

  const _ChartTypeIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
