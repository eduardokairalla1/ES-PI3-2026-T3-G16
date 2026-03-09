/// --- Main application widget ---

/// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/routes.dart';
import 'package:google_fonts/google_fonts.dart';


/// --- CODE ---

/// I represent the root application widget.
class MesclaInvestApp extends StatelessWidget {

  // constructor
  const MesclaInvestApp({super.key});


  /// I describe the UI structure and return the visual representation
  /// of this widget.
  ///
  /// :param context: BuildContext used to access widget tree.
  ///
  /// :returns: Widget configured as application root.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MesclaInvest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: router,
    );
  }
}
