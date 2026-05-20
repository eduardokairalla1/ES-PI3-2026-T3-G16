// --- Application themes ---
//
// Pedro Henrique Medeiros dos Reis - 24801656
// Defines the light and dark ThemeData used by MaterialApp. The values are
// kept intentionally minimal: only the framework-level surfaces, text colours
// and component defaults are set here. Per-widget hard-coded colours that
// also need to flip are resolved through AppColors helpers (which read the
// active brightness from BuildContext).

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- CODE ---

/// Static holder for the app's [ThemeData] presets.
///
/// Exposes [light] and [dark] getters that build a fresh [ThemeData] on each
/// access. Both presets set Material 3, the Inter font (via google_fonts) and
/// neutral surfaces. Theme-aware colours that need a [BuildContext] live in
/// `AppColors`.
class AppTheme {
  AppTheme._();

  // ── Light ────────────────────────────────────────────────────────────────

  /// Light [ThemeData] used by [MaterialApp] in light mode.
  static ThemeData get light {
    final base = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.black,
        brightness: Brightness.light,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.grey50,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );

    return base.copyWith(
      iconTheme: const IconThemeData(color: AppColors.black),
      dividerTheme: const DividerThemeData(color: AppColors.black12),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle: TextStyle(color: AppColors.white),
      ),
    );
  }

  // ── Dark ─────────────────────────────────────────────────────────────────

  /// Dark [ThemeData] used by [MaterialApp] in dark mode.
  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.white,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      useMaterial3: true,
    );

    return base.copyWith(
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorderSoft),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceMuted,
        contentTextStyle: TextStyle(color: AppColors.darkTextPrimary),
      ),
    );
  }
}
