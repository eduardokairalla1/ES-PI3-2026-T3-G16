import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Estilo padrão para exibição de valores monetários.
/// Usa Space Grotesk, que suporta pesos pesados e lê bem em números.
TextStyle moneyStyle({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w700,
  Color color = Colors.black87,
  double letterSpacing = -0.1,
}) {
  return GoogleFonts.spaceGrotesk(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}
