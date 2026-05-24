// --- Shared color palette ---
//
// Single source of truth for the app's monochrome black/white/grey palette.
// Page-specific constants (e.g. auth_constants.dart) should reference these.

// Pedro Henrique Medeiros dos Reis - 24801656
// Added theme-aware helpers (pageBackground, surface, textPrimary, etc.) so
// every internal page can flip between light and dark mode by passing the
// BuildContext. The static base tokens (black, white, greyXxx) are kept for
// backwards compatibility with auth screens and components that should stay
// on the light palette regardless of the active theme.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Greys (Material grey scale)
  static const Color grey50  = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  // Subtle black tints (semi-transparent black for borders/dividers/hints)
  static const Color black87 = Color(0xDD000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black38 = Color(0x61000000);
  static const Color black26 = Color(0x42000000);
  static const Color black12 = Color(0x1F000000);

  // Semantic tokens — buttons
  static const Color buttonPrimaryBg     = black;
  static const Color buttonPrimaryFg     = white;
  static const Color buttonSecondaryBg   = white;
  static const Color buttonSecondaryFg   = black;
  static const Color buttonSecondaryBorder = black12;
  static const Color buttonTextFg        = black87;
  static const Color buttonDestructiveFg = Color(0xFFB00020);
  static const Color buttonDisabledBg    = grey200;
  static const Color buttonDisabledFg    = grey500;

  // Page background (legacy — prefer pageBackground(context))
  static const Color background = grey50;
  static const Color surface    = white;

  // --- DARK MODE PALETTE ---
  // Reference values used by the helpers below when the active theme is dark.

  /// Scaffold background in dark mode (near-black).
  static const Color darkBackground   = Color(0xFF0E0E10);

  /// Card / panel surface in dark mode (raised dark grey).
  static const Color darkSurface      = Color(0xFF1A1A1D);

  /// Muted surface tier in dark mode — icon containers, badges, inner blocks.
  static const Color darkSurfaceMuted = Color(0xFF2A2A2E);

  /// Hairline border in dark mode (white at 20% opacity).
  static const Color darkBorder       = Color(0x33FFFFFF); // white 20%

  /// Softer inner separator in dark mode (white at 12% opacity).
  static const Color darkBorderSoft   = Color(0x1FFFFFFF); // white 12%

  /// Primary on-surface text in dark mode.
  static const Color darkTextPrimary  = Color(0xFFF1F1F3);

  /// Secondary on-surface text in dark mode (subtitles, descriptions).
  static const Color darkTextSecondary = Color(0xB3FFFFFF); // white 70%

  /// Muted on-surface text in dark mode (labels, captions).
  static const Color darkTextMuted    = Color(0x80FFFFFF);  // white 50%

  // --- THEME-AWARE HELPERS ---

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Scaffold background — light grey in light mode, near-black in dark mode.
  static Color pageBackground(BuildContext context) =>
      _isDark(context) ? darkBackground : grey50;

  /// Card / panel background — white in light mode, raised dark grey in dark.
  static Color surfaceColor(BuildContext context) =>
      _isDark(context) ? darkSurface : white;

  /// Subtle background tier for icon containers, badges, muted blocks.
  static Color surfaceMuted(BuildContext context) =>
      _isDark(context) ? darkSurfaceMuted : grey100;

  /// Hairline border colour for cards, dividers and outlined controls.
  static Color border(BuildContext context) =>
      _isDark(context) ? darkBorder : grey200;

  /// Even softer border, used for inner separators inside menus.
  static Color borderSoft(BuildContext context) =>
      _isDark(context) ? darkBorderSoft : black12;

  /// Main on-surface text colour.
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? darkTextPrimary : black;

  /// Secondary on-surface text (subtitles, descriptions).
  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? darkTextSecondary : black.withValues(alpha: 0.6);

  /// Muted on-surface text (labels, captions).
  static Color textMuted(BuildContext context) =>
      _isDark(context) ? darkTextMuted : black.withValues(alpha: 0.4);
}
