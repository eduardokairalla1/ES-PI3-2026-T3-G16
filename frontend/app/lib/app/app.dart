// --- Main application widget ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mesclainvest/app/routes.dart';
import 'package:mesclainvest/app/theme/app_theme.dart';
import 'package:mesclainvest/app/theme/theme_controller.dart';

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
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'MesclaInvest',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeController.instance.mode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
          locale: const Locale('pt', 'BR'),
          routerConfig: router,
        );
      },
    );
  }
}
