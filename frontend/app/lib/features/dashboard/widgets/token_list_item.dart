/// --- Token List Item widget ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/features/dashboard/models/token_holding.dart';

/// I display a single row in the token holdings list.
///
/// Shows startup name, symbol, quantity, current unit value and period variation.
class TokenListItem extends StatelessWidget {
  /// The token holding to display.
  final TokenHolding holding;

  // constructor
  const TokenListItem({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final variation = holding.periodVariationPercent;
    final isPositive = variation >= 0;
    final variationColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final variationIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            holding.symbol.substring(0, 2),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        title: Text(
          holding.startupName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${holding.quantity.toStringAsFixed(0)} tokens · R\$ ${holding.currentUnitValue.toStringAsFixed(2)} un.',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'R\$ ${holding.totalValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(variationIcon, size: 12, color: variationColor),
                Text(
                  '${variation.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 12, color: variationColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
