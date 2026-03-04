/// --- Dashboard Mock Data ---
///
/// Provides static mock data for the Value Dashboard.
/// Replace these methods with Firestore queries in future integration.

import 'package:mesclainvest/features/dashboard/models/portfolio_snapshot.dart';
import 'package:mesclainvest/features/dashboard/models/token_holding.dart';

/// Enum representing the selectable time periods in the dashboard filter.
enum DashboardPeriod {
  daily,
  weekly,
  monthly,
  sixMonths,
  ytd,
}

/// I provide human-readable labels for each [DashboardPeriod].
extension DashboardPeriodLabel on DashboardPeriod {
  String get label {
    switch (this) {
      case DashboardPeriod.daily:
        return 'Diário';
      case DashboardPeriod.weekly:
        return 'Semanal';
      case DashboardPeriod.monthly:
        return 'Mensal';
      case DashboardPeriod.sixMonths:
        return '6 Meses';
      case DashboardPeriod.ytd:
        return 'YTD';
    }
  }
}

/// I hold all mock data for the dashboard feature.
class DashboardMockData {
  DashboardMockData._();

  // --- Holdings ---

  /// Base token holdings with current unit values.
  static const List<TokenHolding> _baseHoldings = [
    TokenHolding(
      id: 'tk_001',
      startupName: 'AgroTech Brasil',
      symbol: 'AGRB',
      quantity: 150,
      currentUnitValue: 12.40,
      periodStartUnitValue: 10.00,
    ),
    TokenHolding(
      id: 'tk_002',
      startupName: 'CleanEnergy Co',
      symbol: 'CLNE',
      quantity: 80,
      currentUnitValue: 25.75,
      periodStartUnitValue: 22.00,
    ),
    TokenHolding(
      id: 'tk_003',
      startupName: 'HealthBridge',
      symbol: 'HLTH',
      quantity: 200,
      currentUnitValue: 8.90,
      periodStartUnitValue: 9.50,
    ),
    TokenHolding(
      id: 'tk_004',
      startupName: 'FinEdge',
      symbol: 'FNDG',
      quantity: 300,
      currentUnitValue: 5.20,
      periodStartUnitValue: 4.80,
    ),
    TokenHolding(
      id: 'tk_005',
      startupName: 'LogiFlow',
      symbol: 'LGFL',
      quantity: 60,
      currentUnitValue: 40.00,
      periodStartUnitValue: 35.50,
    ),
  ];

  /// I return token holdings with period start prices adjusted for [period].
  ///
  /// :param period: Selected dashboard period.
  ///
  /// :returns: List of [TokenHolding] with updated [periodStartUnitValue].
  static List<TokenHolding> holdingsForPeriod(DashboardPeriod period) {
    // Multipliers that simulate how much lower prices were at period start
    final Map<String, double> multipliers = switch (period) {
      DashboardPeriod.daily => {
          'tk_001': 0.99,
          'tk_002': 0.98,
          'tk_003': 1.01,
          'tk_004': 0.995,
          'tk_005': 0.98,
        },
      DashboardPeriod.weekly => {
          'tk_001': 0.95,
          'tk_002': 0.93,
          'tk_003': 1.03,
          'tk_004': 0.97,
          'tk_005': 0.94,
        },
      DashboardPeriod.monthly => {
          'tk_001': 0.88,
          'tk_002': 0.87,
          'tk_003': 1.06,
          'tk_004': 0.92,
          'tk_005': 0.89,
        },
      DashboardPeriod.sixMonths => {
          'tk_001': 0.80,
          'tk_002': 0.75,
          'tk_003': 1.10,
          'tk_004': 0.85,
          'tk_005': 0.78,
        },
      DashboardPeriod.ytd => {
          'tk_001': 0.72,
          'tk_002': 0.68,
          'tk_003': 1.15,
          'tk_004': 0.80,
          'tk_005': 0.70,
        },
    };

    return _baseHoldings.map((h) {
      final multiplier = multipliers[h.id] ?? 1.0;
      return h.copyWithPeriodStart(h.currentUnitValue * multiplier);
    }).toList();
  }

  // --- Portfolio snapshots (chart data) ---

  /// I return a list of [PortfolioSnapshot] for the given [period].
  ///
  /// :param period: Selected dashboard period.
  ///
  /// :returns: Ordered list of snapshots from oldest to most recent.
  static List<PortfolioSnapshot> snapshotsForPeriod(DashboardPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case DashboardPeriod.daily:
        return List.generate(24, (i) {
          final date = now.subtract(Duration(hours: 23 - i));
          return PortfolioSnapshot(
            date: date,
            totalValue: 6800 + (i * 12.5) + (i % 5 == 0 ? -30 : 20),
          );
        });

      case DashboardPeriod.weekly:
        return List.generate(7, (i) {
          final date = now.subtract(Duration(days: 6 - i));
          return PortfolioSnapshot(
            date: date,
            totalValue: 6500 + (i * 80) + (i % 2 == 0 ? -40 : 60),
          );
        });

      case DashboardPeriod.monthly:
        return List.generate(30, (i) {
          final date = now.subtract(Duration(days: 29 - i));
          return PortfolioSnapshot(
            date: date,
            totalValue: 5900 + (i * 35) + (i % 7 == 0 ? -80 : 50),
          );
        });

      case DashboardPeriod.sixMonths:
        return List.generate(26, (i) {
          final date = now.subtract(Duration(days: (25 - i) * 7));
          return PortfolioSnapshot(
            date: date,
            totalValue: 4500 + (i * 90) + (i % 4 == 0 ? -100 : 70),
          );
        });

      case DashboardPeriod.ytd:
        final startOfYear = DateTime(now.year, 1, 1);
        final totalDays = now.difference(startOfYear).inDays;
        final steps = totalDays ~/ 7;
        return List.generate(steps, (i) {
          final date = startOfYear.add(Duration(days: i * 7));
          return PortfolioSnapshot(
            date: date,
            totalValue: 4000 + (i * 110) + (i % 5 == 0 ? -120 : 80),
          );
        });
    }
  }
}
