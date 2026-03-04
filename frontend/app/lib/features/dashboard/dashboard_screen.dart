/// --- Value Dashboard Screen ---
///
/// Main screen for tracking token portfolio value over time.
/// Currently powered by mock data; Firestore integration can be added
/// by replacing [DashboardMockData] calls with repository/provider calls.

import 'package:flutter/material.dart';
import 'package:mesclainvest/features/dashboard/data/dashboard_mock_data.dart';
import 'package:mesclainvest/features/dashboard/widgets/period_filter_bar.dart';
import 'package:mesclainvest/features/dashboard/widgets/portfolio_chart.dart';
import 'package:mesclainvest/features/dashboard/widgets/portfolio_summary_card.dart';
import 'package:mesclainvest/features/dashboard/widgets/token_list_item.dart';

/// I am the Value Dashboard screen.
///
/// I manage the selected [DashboardPeriod] state and coordinate
/// all child widgets: filter bar, summary card, chart, and token list.
class DashboardScreen extends StatefulWidget {
  // constructor
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Currently selected period filter.
  DashboardPeriod _selectedPeriod = DashboardPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final holdings = DashboardMockData.holdingsForPeriod(_selectedPeriod);
    final snapshots = DashboardMockData.snapshotsForPeriod(_selectedPeriod);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Carteira'),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Period filter chips
          PeriodFilterBar(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (period) => setState(() => _selectedPeriod = period),
          ),

          const SizedBox(height: 16),

          // Total value + variation summary card
          PortfolioSummaryCard(holdings: holdings),

          const SizedBox(height: 20),

          // Line chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Evolução do valor',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          PortfolioChart(snapshots: snapshots),

          const SizedBox(height: 24),

          // Token list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tokens na carteira',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 4),

          // Token list items
          ...holdings.map((h) => TokenListItem(holding: h)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
