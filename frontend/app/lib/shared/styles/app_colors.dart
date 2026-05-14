// --- Shared color palette ---
//
// Single source of truth for the app's monochrome black/white/grey palette.
// Page-specific constants (e.g. auth_constants.dart) should reference these.

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

  // Page background
  static const Color background = grey50;
  static const Color surface    = white;
}
