// --- Theme controller ---
//
// Pedro Henrique Medeiros dos Reis - 24801656
// Singleton ChangeNotifier that owns the active ThemeMode. The current value
// is persisted to SharedPreferences so the user's choice survives app
// restarts. Wired to MaterialApp.router via an AnimatedBuilder in app.dart.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CODE ---

/// Singleton [ChangeNotifier] that owns the active [ThemeMode].
///
/// The current value is persisted to SharedPreferences so the user's choice
/// survives app restarts. Wired to `MaterialApp.router` via an
/// `AnimatedBuilder` in `app.dart`. Access via [ThemeController.instance].
class ThemeController extends ChangeNotifier {
  ThemeController._();

  /// Process-wide singleton instance.
  static final ThemeController instance = ThemeController._();

  // Key used to persist the preference under SharedPreferences.
  static const String _prefsKey = 'mescla_theme_mode';

  ThemeMode _mode = ThemeMode.light;

  /// Currently active theme mode (light or dark — system mode is not used).
  ThemeMode get mode => _mode;

  /// True when the active mode is [ThemeMode.dark].
  bool get isDark => _mode == ThemeMode.dark;

  /// I load the persisted theme preference on app start. Called once from
  /// main() before runApp so the first frame already paints in the right mode.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == 'dark') {
        _mode = ThemeMode.dark;
      } else {
        _mode = ThemeMode.light;
      }
    } catch (_) {
      // If persistence fails for any reason, fall back to light mode silently.
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  /// I flip between light and dark mode, persist the new value and notify
  /// listeners so MaterialApp rebuilds with the right theme.
  Future<void> toggle() async {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // Best-effort persistence; the runtime value is already updated above.
    }
  }
}
