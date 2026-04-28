import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Título de seção usado em telas de configurações/suporte.
class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color: const Color(0xFF888888),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

