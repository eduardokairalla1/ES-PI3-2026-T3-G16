// --- Distribuição do patrimônio card ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Donut chart that breaks down the user's investments by startup. The slice
// of each startup is proportional to its current position value
// (`tokenQuantity * currentPrice`). A side legend mirrors the chart with a
// coloured dot, the startup name and the percentage.
//
// Empty state (no holdings yet) is rendered inline so the card always
// occupies a stable footprint in the page layout — keeps the scroll position
// from jumping when the dashboard finishes loading.

// --- IMPORTS ---
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- CONSTANTS ---

// Palette cycled through for the donut slices. Order is deterministic so the
// same startup always gets the same colour across renders.
const List<Color> _kSlicePalette = [
  Color(0xFF111111),
  Color(0xFF6B7280),
  Color(0xFFA1A1AA),
  Color(0xFFD4D4D8),
  Color(0xFF2563EB),
  Color(0xFFDC2626),
  Color(0xFF16A34A),
  Color(0xFFEA580C),
];

// --- WIDGET ---

/// Card with the "Distribuição do Patrimônio" title, the donut chart and a
/// legend listing every startup the user holds.
class DistribuicaoPatrimonioCard extends StatelessWidget {
  /// Controller that exposes the loaded [DashboardData].
  final DashboardController controller;

  /// Builds the card bound to [controller].
  const DistribuicaoPatrimonioCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    final slices = _buildSlices(data.investimentos);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
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
                Icons.pie_chart_outline,
                size:  18,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Distribuição do Patrimônio',
                style: TextStyle(
                  fontSize:    15,
                  fontWeight:  FontWeight.w700,
                  color:       AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (slices.isEmpty)
            _EmptyState()
          else
            _DonutWithLegend(slices: slices),
        ],
      ),
    );
  }
}

// --- INTERNAL: SLICE MODEL ---

class _Slice {
  final String name;
  final double value;
  final double percent;
  final Color  color;
  const _Slice({
    required this.name,
    required this.value,
    required this.percent,
    required this.color,
  });
}

/// Converts the user's holdings into chart-ready slices, sorted from largest
/// to smallest. Holdings with zero current value are dropped.
List<_Slice> _buildSlices(List<InvestimentoResumo> investimentos) {
  final raw = investimentos
      .map((i) => MapEntry(i.startupName, i.tokenQuantity * i.currentPrice))
      .where((e) => e.value > 0)
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  if (raw.isEmpty) return const [];

  final total = raw.fold<double>(0, (sum, e) => sum + e.value);
  return [
    for (var i = 0; i < raw.length; i++)
      _Slice(
        name:    raw[i].key,
        value:   raw[i].value,
        percent: (raw[i].value / total) * 100,
        color:   _kSlicePalette[i % _kSlicePalette.length],
      ),
  ];
}

// --- INTERNAL: DONUT + LEGEND LAYOUT ---

class _DonutWithLegend extends StatelessWidget {
  final List<_Slice> slices;
  const _DonutWithLegend({required this.slices});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width:  120,
          height: 120,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 36,
              sectionsSpace:     2,
              startDegreeOffset: -90,
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                    value:    s.value,
                    color:    s.color,
                    radius:   24,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _Legend(slices: slices)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final List<_Slice> slices;
  const _Legend({required this.slices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width:  10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.name,
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textPrimary(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${s.percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// --- INTERNAL: EMPTY STATE ---

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.donut_large_outlined,
              size:  40,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Sem investimentos por enquanto.',
              style: TextStyle(
                fontSize: 13,
                color:    AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Compre tokens de uma startup para ver a sua distribuição aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color:    AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
