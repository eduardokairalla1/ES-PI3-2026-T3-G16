/// --- Period Filter Bar widget ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/features/dashboard/data/dashboard_mock_data.dart';

/// I display a horizontal row of period filter chips.
///
/// The currently selected period is highlighted; tapping another calls [onPeriodChanged].
class PeriodFilterBar extends StatelessWidget {
  /// Currently selected period.
  final DashboardPeriod selectedPeriod;

  /// Callback invoked when the user selects a different period.
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  // constructor
  const PeriodFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: DashboardPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period.label),
              selected: isSelected,
              onSelected: (_) => onPeriodChanged(period),
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
