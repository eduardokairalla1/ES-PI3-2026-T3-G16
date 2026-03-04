/// --- Portfolio Summary Card widget ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/features/dashboard/models/token_holding.dart';

/// I display a summary card showing the total portfolio value and period variation.
class PortfolioSummaryCard extends StatelessWidget {
  /// List of token holdings used to compute totals.
  final List<TokenHolding> holdings;

  // constructor
  const PortfolioSummaryCard({super.key, required this.holdings});

  @override
  Widget build(BuildContext context) {
    final totalCurrent = holdings.fold<double>(0, (sum, h) => sum + h.totalValue);
    final totalPeriodStart = holdings.fold<double>(
      0,
      (sum, h) => sum + h.quantity * h.periodStartUnitValue,
    );
    final variationPercent = totalPeriodStart == 0
        ? 0.0
        : ((totalCurrent - totalPeriodStart) / totalPeriodStart) * 100;

    final isPositive = variationPercent >= 0;
    final variationColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final variationIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valor total da carteira',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatBrl(totalCurrent),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(variationIcon, size: 16, color: variationColor),
                const SizedBox(width: 4),
                Text(
                  '${variationPercent.toStringAsFixed(2)}% no período',
                  style: TextStyle(
                    fontSize: 14,
                    color: variationColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// I format a double value as Brazilian Real currency string.
  ///
  /// :param value: Numeric value in BRL.
  ///
  /// :returns: Formatted string like "R$ 7.302,50".
  String _formatBrl(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$ $intPart,${parts[1]}';
  }
}
