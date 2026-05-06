/// Card de valorização de tokens — gráfico de linha com bonding curve.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/price_snapshot_model.dart';


// --- CONSTANTES ---

const _periods = [
  ('daily',   'Diário'),
  ('weekly',  'Semanal'),
  ('monthly', 'Mensal'),
  ('6months', '6 Meses'),
  ('ytd',     'YTD'),
];

enum StartupSelectorStyle { a, b, c, d }

Color _stageColor(String stage) => switch (stage) {
  'new'       => const Color(0xFF4F46E5),
  'operating' => const Color(0xFF16A34A),
  'expanding' => const Color(0xFF0EA5E9),
  _           => Colors.grey,
};


// --- WIDGET PRINCIPAL ---

class CardValorizacao extends StatelessWidget {

  final DashboardController    controller;
  final StartupSelectorStyle   style;
  final String?                label;

  const CardValorizacao({
    super.key,
    required this.controller,
    this.style = StartupSelectorStyle.a,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          _Header(controller: controller),
          _buildStartupSelector(context),
          const SizedBox(height: 10),
          _PeriodSelector(controller: controller),
          _ChartArea(controller: controller),
        ],
      ),
    );
  }

  Widget _buildStartupSelector(BuildContext context) => switch (style) {
    StartupSelectorStyle.a => _SelectorA(controller: controller),
    StartupSelectorStyle.b => _SelectorB(controller: controller),
    StartupSelectorStyle.c => _SelectorC(controller: controller),
    StartupSelectorStyle.d => _SelectorD(controller: controller),
  };
}


// --- HEADER ---

class _Header extends StatelessWidget {

  final DashboardController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    final history       = controller.tokenHistory;
    final changePercent = history?.changePercent ?? 0;
    final isPositive    = changePercent >= 0;
    final currencyFmt   = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Expanded(
            child: Text(
              'Valorização',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),

          if (history != null && history.hasInvestment)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFmt.format(history.totalValue),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 13,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    Text(
                      '${changePercent.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      ' no período',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                Text(
                  '${history.tokenQuantity} tokens · ${currencyFmt.format(history.currentPrice)}/un',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),

        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// OPÇÃO A — Abas com underline
// ─────────────────────────────────────────────────────────────

class _SelectorA extends StatelessWidget {

  final DashboardController controller;
  const _SelectorA({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.startups.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: controller.startups.map((s) {
          final isSelected = controller.selectedStartup?.id == s.id;
          return GestureDetector(
            onTap: () => controller.selectStartup(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                s.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// OPÇÃO B — Cards com logo, nome e preço
// ─────────────────────────────────────────────────────────────

class _SelectorB extends StatelessWidget {

  final DashboardController controller;
  const _SelectorB({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.startups.isEmpty) return const SizedBox.shrink();

    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SizedBox(
      height: 72,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: controller.startups.map((s) {
          final isSelected = controller.selectedStartup?.id == s.id;
          final color      = _stageColor(s.stage);

          return GestureDetector(
            onTap: () => controller.selectStartup(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.15) : color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            s.name[0],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    s.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currencyFmt.format(s.tokenPrice),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// OPÇÃO C — Segmented control (pill único)
// ─────────────────────────────────────────────────────────────

class _SelectorC extends StatelessWidget {

  final DashboardController controller;
  const _SelectorC({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.startups.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: controller.startups.asMap().entries.map((entry) {
            final idx        = entry.key;
            final s          = entry.value;
            final isSelected = controller.selectedStartup?.id == s.id;
            final isLast     = idx == controller.startups.length - 1;

            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectStartup(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 1))]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isLast && !isSelected) ...[
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// OPÇÃO D — Botão que abre bottom sheet
// ─────────────────────────────────────────────────────────────

class _SelectorD extends StatelessWidget {

  final DashboardController controller;
  const _SelectorD({required this.controller});

  @override
  Widget build(BuildContext context) {
    final startup     = controller.selectedStartup;
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _openSheet(context, currencyFmt),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              if (startup != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _stageColor(startup.stage).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      startup.name[0],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _stageColor(startup.stage),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startup.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        currencyFmt.format(startup.tokenPrice),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ] else
                Expanded(
                  child: Text(
                    'Selecionar startup',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ),
              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context, NumberFormat currencyFmt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecionar startup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          ...controller.startups.map((s) {
            final isSelected = controller.selectedStartup?.id == s.id;
            final color      = _stageColor(s.stage);
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    s.name[0],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
              ),
              title: Text(
                s.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              subtitle: Text(
                currencyFmt.format(s.tokenPrice),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded, color: Colors.black, size: 20)
                  : null,
              onTap: () {
                controller.selectStartup(s);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


// --- SELETOR DE PERÍODO ---

class _PeriodSelector extends StatelessWidget {

  final DashboardController controller;
  const _PeriodSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: _periods.map((entry) {
          final (value, label) = entry;
          final isSelected = controller.selectedPeriod == value;
          return GestureDetector(
            onTap: () => controller.selectPeriod(value),
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


// --- ÁREA DO GRÁFICO ---

class _ChartArea extends StatelessWidget {

  final DashboardController controller;
  const _ChartArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingChart) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)),
      );
    }

    if (controller.chartErrorMessage != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_outlined, size: 36, color: Colors.black12),
              const SizedBox(height: 8),
              Text(
                controller.chartErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    final history = controller.tokenHistory;

    if (history == null || !history.hasInvestment) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, size: 36, color: Colors.black12),
              const SizedBox(height: 8),
              Text(
                history != null ? 'Você ainda não investiu\nnesta startup' : 'Sem dados para este período',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 20),
      child: SizedBox(height: 200, child: _LineChart(history: history)),
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
    final minMs       = snapshots.first.recordedAt.millisecondsSinceEpoch.toDouble();
    final maxMsRaw    = snapshots.last.recordedAt.millisecondsSinceEpoch.toDouble();
    final maxMs       = maxMsRaw > minMs ? maxMsRaw : minMs + 86400000; // mínimo 1 dia
    final rangeMs     = maxMs - minMs;
    final showXTitles = rangeMs > 0 && snapshots.length > 1;
    final spots     = snapshots.map((s) => FlSpot(
      s.recordedAt.millisecondsSinceEpoch.toDouble(), s.price,
    )).toList();
    final prices = snapshots.map((s) => s.price).toList();
    final minY   = prices.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY   = prices.reduce((a, b) => a > b ? a : b) * 1.05;
    final isUp   = history.changePercent >= 0;
    final color  = isUp ? Colors.green : Colors.red;
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
          reservedSize: 52,
          getTitlesWidget: (v, _) => Text('R\$${v.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        )),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: showXTitles,
          reservedSize: 22,
          interval: showXTitles ? (rangeMs / 4).clamp(1, double.infinity) : 1,
          getTitlesWidget: (v, _) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(dateFmt.format(DateTime.fromMillisecondsSinceEpoch(v.toInt())),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
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
