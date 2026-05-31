// --- Evolução do patrimônio card ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Line chart that visualizes how the user's total patrimônio has moved over
// the selected period. The curve here is real: the backend queries historical
// snapshots, wallet transactions, and asset valuation retroactively, and we
// dynamically render the exact data points fetched from the API with support
// for caching, loading state indicators, and error handling.
//

// --- IMPORTS ---
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- TYPES ---

/// Selectable windows in the period dropdown.
enum _Period { d7, m1, m3, m6, y1 }

extension _PeriodX on _Period {
  /// Short label shown in the dropdown trigger.
  String get label => switch (this) {
        _Period.d7 => '7 dias',
        _Period.m1 => '1 mês',
        _Period.m3 => '3 meses',
        _Period.m6 => '6 meses',
        _Period.y1 => '1 ano',
      };

  /// Length of the window in days, used to label the X axis.
  int get days => switch (this) {
        _Period.d7 => 7,
        _Period.m1 => 30,
        _Period.m3 => 90,
        _Period.m6 => 180,
        _Period.y1 => 365,
      };
}

// --- WIDGET ---

/// Card with the "Evolução do Patrimônio" title, a period selector and the
/// line chart itself. Renders nothing if the dashboard data hasn't loaded.
class EvolucaoPatrimonioCard extends StatefulWidget {
  /// Controller that exposes the loaded [DashboardData].
  final DashboardController controller;

  /// Builds the card bound to [controller].
  const EvolucaoPatrimonioCard({super.key, required this.controller});

  @override
  State<EvolucaoPatrimonioCard> createState() => _EvolucaoPatrimonioCardState();
}

class _EvolucaoPatrimonioCardState extends State<EvolucaoPatrimonioCard> {
  _Period _period = _Period.m1;
  final Map<_Period, List<FlSpot>> _spotsCache = {};
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistoryForPeriod(_period);
  }

  @override
  void didUpdateWidget(covariant EvolucaoPatrimonioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.data != oldWidget.controller.data && widget.controller.data != null) {
      _spotsCache.clear();
      _loadHistoryForPeriod(_period);
    }
  }

  Future<void> _loadHistoryForPeriod(_Period period) async {
    if (widget.controller.data == null) return;
    if (_spotsCache.containsKey(period)) {
      setState(() {
        _period = period;
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _period = period;
      _loading = true;
      _error = null;
    });

    try {
      final periodStr = period.name;
      final history = await widget.controller.fetchPatrimonyHistory(periodStr);
      final List<FlSpot> spots = [];
      for (int i = 0; i < history.length; i++) {
        final double val = (history[i]['patrimony'] as num).toDouble();
        spots.add(FlSpot(i.toDouble(), val));
      }
      _spotsCache[period] = spots;
      if (mounted && _period == period) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted && _period == period) {
        setState(() {
          _loading = false;
          _error = 'Falha ao carregar histórico.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.controller.data;
    if (data == null) return const SizedBox.shrink();

    final spots = _spotsCache[_period];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color:        AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset:    const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                size:  18,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Evolução do Patrimônio',
                  style: TextStyle(
                    fontSize:    15,
                    fontWeight:  FontWeight.w700,
                    color:       AppColors.textPrimary(context),
                  ),
                ),
              ),
              _PeriodDropdown(
                current:  _period,
                onChange: _loadHistoryForPeriod,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      )
                    : (spots == null || spots.isEmpty)
                        ? Center(
                            child: Text(
                              'Carregando histórico...',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted(context),
                              ),
                            ),
                          )
                        : _Chart(spots: spots, period: _period),
          ),
        ],
      ),
    );
  }
}

// --- INTERNAL: CHART ---

class _Chart extends StatelessWidget {
  final List<FlSpot> spots;
  final _Period period;
  const _Chart({required this.spots, required this.period});

  @override
  Widget build(BuildContext context) {
    if (spots.length < 2) {
      // Single data point — fl_chart needs at least 2 to draw anything.
      return Center(
        child: Text(
          'Aguardando movimentações...',
          style: TextStyle(
            fontSize: 13,
            color:    AppColors.textMuted(context),
          ),
        ),
      );
    }

    final rawMin = spots.map((s) => s.y).reduce(min);
    final minY   = rawMin <= 0 ? rawMin * 1.03 : rawMin * 0.97;
    final maxY   = spots.map((s) => s.y).reduce(max) * 1.03;

    // Trend colour: green if the curve ends higher than it started, red otherwise.
    final isUp = spots.last.y >= spots.first.y;
    final color = isUp ? Colors.green.shade600 : Colors.red.shade600;

    final fmt = NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$');

    return LineChart(
      LineChartData(
        minX:    0,
        maxX:    (spots.length - 1).toDouble(),
        minY:    minY,
        maxY:    maxY,
        gridData: FlGridData(
          show:                   true,
          drawVerticalLine:       false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border(context), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 44,
              getTitlesWidget: (v, _) => Text(
                fmt.format(v),
                style: TextStyle(
                  fontSize: 9,
                  color:    AppColors.textMuted(context),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 20,
              interval:     ((spots.length - 1) / 4).clamp(1, 100).toDouble(),
              getTitlesWidget: (v, _) {
                // Convert "sample index" → relative day count for the label.
                final days = period.days;
                final dayAgo = ((spots.length - 1 - v) /
                        (spots.length - 1) *
                        days)
                    .round();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    dayAgo == 0 ? 'hoje' : '-${dayAgo}d',
                    style: TextStyle(
                      fontSize: 9,
                      color:    AppColors.textMuted(context),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => touched
                .map((s) => LineTooltipItem(
                      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                          .format(s.y),
                      const TextStyle(
                        color:      Colors.white,
                        fontSize:   12,
                        fontWeight: FontWeight.w700,
                      ),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots:           spots,
            isCurved:                   true,
            curveSmoothness:            0.3,
            preventCurveOverShooting:   true,
            color:           color,
            barWidth:        2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                radius:      3,
                color:       color,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end:   Alignment.bottomCenter,
                colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- INTERNAL: PERIOD DROPDOWN ---

class _PeriodDropdown extends StatelessWidget {
  final _Period current;
  final ValueChanged<_Period> onChange;
  const _PeriodDropdown({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Period>(
      tooltip:  '',
      onSelected: onChange,
      itemBuilder: (_) => [
        for (final p in _Period.values)
          PopupMenuItem(value: p, child: Text(p.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        AppColors.surfaceMuted(context),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current.label,
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size:  16,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

