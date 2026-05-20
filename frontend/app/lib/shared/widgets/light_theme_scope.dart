// --- Light theme scope ---
//
// Pedro Henrique Medeiros dos Reis - 24801656
// Helper widget that forces its subtree to render with the light ThemeData,
// regardless of the global ThemeMode. Used to pin the public-facing screens
// (landing, login, register, forgot/reset password) to the light palette so
// the brand presentation stays consistent for unauthenticated users.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/theme/app_theme.dart';

// --- CODE ---

/// Forces its subtree to render with the light [ThemeData], regardless of the
/// global [ThemeMode].
///
/// Used to pin the public-facing screens (landing, login, register, forgot
/// password, reset password) to the light palette so the brand presentation
/// stays consistent for unauthenticated users even when the device or app is
/// in dark mode.
class LightThemeScope extends StatelessWidget {
  /// Subtree that will be rendered under the forced light theme.
  final Widget child;

  /// Wraps [child] in a [Theme] using the app's light preset.
  const LightThemeScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(data: AppTheme.light, child: child);
  }
}
