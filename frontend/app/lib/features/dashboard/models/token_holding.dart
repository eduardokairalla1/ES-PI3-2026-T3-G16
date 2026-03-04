/// --- Token Holding model ---

/// Represents a single token holding in the user's portfolio.
class TokenHolding {
  /// Unique identifier for the token/startup.
  final String id;

  /// Name of the startup that issued the token.
  final String startupName;

  /// Ticker/symbol for the token.
  final String symbol;

  /// Number of tokens held by the user.
  final double quantity;

  /// Current unit value of the token in BRL.
  final double currentUnitValue;

  /// Unit value at the start of the selected period (used to compute variation).
  final double periodStartUnitValue;

  // constructor
  const TokenHolding({
    required this.id,
    required this.startupName,
    required this.symbol,
    required this.quantity,
    required this.currentUnitValue,
    required this.periodStartUnitValue,
  });

  /// I return the total current value of this holding (quantity × currentUnitValue).
  double get totalValue => quantity * currentUnitValue;

  /// I return the percentage variation of the unit value over the selected period.
  double get periodVariationPercent {
    if (periodStartUnitValue == 0) return 0;
    return ((currentUnitValue - periodStartUnitValue) / periodStartUnitValue) * 100;
  }

  /// I return a copy of this holding with a new period start price.
  ///
  /// :param periodStartUnitValue: New reference price for the selected period.
  TokenHolding copyWithPeriodStart(double newPeriodStartUnitValue) {
    return TokenHolding(
      id: id,
      startupName: startupName,
      symbol: symbol,
      quantity: quantity,
      currentUnitValue: currentUnitValue,
      periodStartUnitValue: newPeriodStartUnitValue,
    );
  }
}
