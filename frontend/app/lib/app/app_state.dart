/// --- App state ---

// --- IMPORTS ---
import 'package:flutter/foundation.dart';
import 'package:mesclainvest/core/models/user_profile.dart';
import 'package:mesclainvest/core/services/auth.dart';


// --- CODE ---

/// I hold the global application state shared across the widget tree.
/// I am a singleton — access me via [AppState.instance].
class AppState extends ChangeNotifier {

  // singleton setup
  AppState._();
  static final AppState instance = AppState._();

  // state
  UserProfile? _profile;


  /// I return the currently loaded user profile, or null if not yet loaded.
  UserProfile? get profile => _profile;


  /// I load the user profile from the backend and notify listeners.
  ///
  /// :param authService: the AuthService used to call the backend
  ///
  /// :returns: void
  Future<void> loadProfile(AuthService authService) async {
    final fetched = await authService.getProfile();
    _profile = fetched;
    notifyListeners();
  }


  /// I clear the user profile (call on sign-out).
  ///
  /// :returns: void
  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
