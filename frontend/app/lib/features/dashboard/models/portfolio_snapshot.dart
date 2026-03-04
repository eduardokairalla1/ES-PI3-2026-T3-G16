/// --- Portfolio Snapshot model ---

/// Represents the total portfolio value at a specific point in time.
/// Used to build the line chart data series.
class PortfolioSnapshot {
  /// The date/time of this snapshot.
  final DateTime date;

  /// Total portfolio value in BRL at this moment.
  final double totalValue;

  // constructor
  const PortfolioSnapshot({
    required this.date,
    required this.totalValue,
  });
}
