import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Estilo padrão para exibição de valores monetários.
/// Usa Space Grotesk, que suporta pesos pesados e lê bem em números.
///
/// `color` é nullable. When null, the resulting TextStyle inherits the colour
/// from the surrounding DefaultTextStyle / Theme — that's what callers in
/// theme-aware screens want, so the value flips automatically between light
/// and dark mode.
TextStyle moneyStyle({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w700,
  Color? color,
  double letterSpacing = -0.1,
}) {
  return GoogleFonts.spaceGrotesk(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}
