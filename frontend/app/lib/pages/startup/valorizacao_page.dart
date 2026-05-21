/// Página de valorização de tokens de uma startup específica.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/dashboard/models/price_snapshot_model.dart';
import 'package:mesclainvest/pages/dashboard/services/token_history_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/pages/startup/services/startup_service.dart';
import 'package:mesclainvest/pages/startup/widgets/startup_header.dart';
import 'package:mesclainvest/pages/startup/widgets/startup_info_card.dart';


// --- CONSTANTES ---

const _periods = [
  ('daily',   'Diário'),
  ('weekly',  'Semanal'),
  ('monthly', 'Mensal'),
  ('6months', '6 Meses'),
  ('ytd',     'YTD'),
];


// --- CONTROLLER ---

class _ValorizacaoController extends ChangeNotifier {

  final StartupService      _startupService = StartupService();
  final TokenHistoryService _historyService = TokenHistoryService();

  bool   isLoading      = true;
  String selectedPeriod = 'weekly';
  String? errorMessage;

  StartupModel?       startup;
  TokenHistoryModel?  tokenHistory;
  bool                isLoadingChart = false;
  String?             chartError;

  Future<void> load(String startupId) async {
    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    try {
      startup = await _startupService.fetchStartup(startupId);
      await _loadChart(startupId);
    } catch (_) {
      errorMessage = 'Não foi possível carregar os dados. Tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPeriod(String startupId, String period) async {
    selectedPeriod = period;
    notifyListeners();
    await _loadChart(startupId);
  }

  Future<void> _loadChart(String startupId) async {
    isLoadingChart = true;
    chartError     = null;
    notifyListeners();

    try {
      tokenHistory = await _historyService.fetchHistory(startupId, selectedPeriod);
    } catch (_) {
      tokenHistory = null;
      chartError   = 'Não foi possível carregar o histórico. Tente novamente.';
    } finally {
      isLoadingChart = false;
      notifyListeners();
    }
  }
}


// --- PAGE ---

class ValorizacaoPage extends StatefulWidget {

  final String startupId;

  const ValorizacaoPage({super.key, required this.startupId});

  @override
  State<ValorizacaoPage> createState() => _ValorizacaoPageState();
}

class _ValorizacaoPageState extends State<ValorizacaoPage> {

  final _ValorizacaoController _controller = _ValorizacaoController();

  @override
  void initState() {
    super.initState();
    _controller.load(widget.startupId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        if (_controller.errorMessage != null || _controller.startup == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F8F8),
            body: SafeArea(
              child: Column(
                children: [
                  _buildFallbackHeader(context),
                  Expanded(
                    child: Center(
                      child: Text(
                        _controller.errorMessage ?? 'Erro inesperado.',
                        style: const TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final startup  = _controller.startup!;
        final userName = AppState.instance.profile?.fullName ?? '';
        final history  = _controller.tokenHistory;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [

                // reusa o header da tela de detalhe da startup
                StartupHeader(startup: startup, userName: userName),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // reusa o info card (preço atual + stage badge)
                        StartupInfoCard(startup: startup),

                        Divider(height: 1, color: Colors.grey.shade200),

                        // resumo do investimento
                        if (history != null && history.hasInvestment)
                          _InvestmentSummary(history: history),

                        // seletor de período
                        const SizedBox(height: 16),
                        _PeriodSelector(
                          selectedPeriod: _controller.selectedPeriod,
                          onSelect: (p) => _controller.selectPeriod(widget.startupId, p),
                        ),

                        // gráfico
                        _ChartSection(
                          controller: _controller,
                          history: history,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Valorização', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}


// --- RESUMO DO INVESTIMENTO ---

class _InvestmentSummary extends StatelessWidget {

  final TokenHistoryModel history;

  const _InvestmentSummary({required this.history});

  @override
  Widget build(BuildContext context) {
    final currencyFmt   = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final changePercent = history.changePercent;
    final isPositive    = changePercent >= 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currencyFmt.format(history.totalValue),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${history.tokenQuantity} tokens · ${currencyFmt.format(history.currentPrice)}/un',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${changePercent.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              Text(
                'no período',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// --- SELETOR DE PERÍODO ---

class _PeriodSelector extends StatelessWidget {

  final String selectedPeriod;
  final void Function(String) onSelect;

  const _PeriodSelector({required this.selectedPeriod, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: _periods.map((entry) {
          final (value, label) = entry;
          final isSelected = selectedPeriod == value;

          return GestureDetector(
            onTap: () => onSelect(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
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
}


// --- SEÇÃO DO GRÁFICO ---

class _ChartSection extends StatelessWidget {

  final _ValorizacaoController controller;
  final TokenHistoryModel?      history;

  const _ChartSection({required this.controller, required this.history});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingChart) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)),
      );
    }

    if (controller.chartError != null) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_outlined, size: 36, color: Colors.black12),
              const SizedBox(height: 8),
              Text(
                controller.chartError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    if (history == null || !history!.hasInvestment) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, size: 40, color: Colors.black12),
              const SizedBox(height: 8),
              Text(
                'Você ainda não investiu\nnesta startup',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 0),
      child: SizedBox(height: 260, child: _LineChart(history: history!)),
    );
  }
}


// --- GRÁFICO DE LINHA ---

class _LineChart extends StatelessWidget {

  final TokenHistoryModel history;

  const _LineChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final snapshots = history.snapshots;
    final minMs     = snapshots.first.recordedAt.millisecondsSinceEpoch.toDouble();
    final maxMs     = snapshots.last.recordedAt.millisecondsSinceEpoch.toDouble();
    final spots     = snapshots.map((s) => FlSpot(
      s.recordedAt.millisecondsSinceEpoch.toDouble(), s.price,
    )).toList();
    final prices  = snapshots.map((s) => s.price).toList();
    final minY    = prices.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY    = prices.reduce((a, b) => a > b ? a : b) * 1.05;
    final isUp    = history.changePercent >= 0;
    final color   = isUp ? Colors.green : Colors.red;
    final dateFmt = DateFormat('dd/MM');

    return LineChart(LineChartData(
      minX: minMs, maxX: maxMs, minY: minY, maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 56,
          getTitlesWidget: (v, _) => Text(
            'R\$${v.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        )),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: (maxMs - minMs) / 4,
          getTitlesWidget: (v, _) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              dateFmt.format(DateTime.fromMillisecondsSinceEpoch(v.toInt())),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ),
        )),
        topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
            'R\$${s.y.toStringAsFixed(4)}',
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
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
            ),
          ),
        ),
      ],
    ));
  }
}
