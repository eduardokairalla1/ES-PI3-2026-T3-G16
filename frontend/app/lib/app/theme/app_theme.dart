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
    // Build the seed-based scheme, then override every surface variant so
    // Material 3 never bleeds its auto-generated purple/pink tints into
    // Scaffold, Dialog, Card, AppBar, BottomSheet, etc.
    final seedScheme = ColorScheme.fromSeed(
      seedColor: AppColors.black,
      brightness: Brightness.light,
      surface: AppColors.white,
    ).copyWith(
      primary: AppColors.black,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.grey100,
      onPrimaryContainer: AppColors.black,
      secondary: AppColors.black,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.grey100,
      onSecondaryContainer: AppColors.black,
      tertiary: AppColors.black,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.grey100,
      onTertiaryContainer: AppColors.black,
      error: const Color(0xFFB00020),
      onError: AppColors.white,
      errorContainer: const Color(0xFFFDE8E8),
      onErrorContainer: const Color(0xFF9B1C1C),
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.grey50,
      surfaceContainer: AppColors.grey50,
      surfaceContainerHigh: AppColors.grey100,
      surfaceContainerHighest: AppColors.grey200,
    );

    final base = ThemeData(
      brightness: Brightness.light,
      colorScheme: seedScheme,
      scaffoldBackgroundColor: AppColors.grey50,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.black,
        selectionColor: AppColors.black12,
        selectionHandleColor: AppColors.black,
      ),
    );

    return base.copyWith(
      iconTheme: const IconThemeData(color: AppColors.black),
      dividerTheme: const DividerThemeData(color: AppColors.black12),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle: TextStyle(color: AppColors.white),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // ── Dark ─────────────────────────────────────────────────────────────────

  /// Dark [ThemeData] used by [MaterialApp] in dark mode.
  static ThemeData get dark {
    final seedScheme = ColorScheme.fromSeed(
      seedColor: AppColors.white,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    ).copyWith(
      primary: AppColors.white,
      onPrimary: AppColors.black,
      primaryContainer: AppColors.darkSurfaceMuted,
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.white,
      onSecondary: AppColors.black,
      secondaryContainer: AppColors.darkSurfaceMuted,
      onSecondaryContainer: AppColors.white,
      tertiary: AppColors.white,
      onTertiary: AppColors.black,
      tertiaryContainer: AppColors.darkSurfaceMuted,
      onTertiaryContainer: AppColors.white,
      error: const Color(0xFFCF6679),
      onError: AppColors.black,
      errorContainer: const Color(0xFF4C1D24),
      onErrorContainer: const Color(0xFFFFAEAE),
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkBackground,
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkSurfaceMuted,
      surfaceContainerHighest: AppColors.darkSurfaceMuted,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: seedScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      useMaterial3: true,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.white,
        selectionColor: AppColors.darkBorderSoft,
        selectionHandleColor: AppColors.white,
      ),
    );

    return base.copyWith(
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorderSoft),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceMuted,
        contentTextStyle: TextStyle(color: AppColors.darkTextPrimary),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
