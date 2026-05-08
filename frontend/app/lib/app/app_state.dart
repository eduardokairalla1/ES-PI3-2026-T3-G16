/// --- App state ---

// --- IMPORTS ---
import 'package:flutter/foundation.dart';
import 'package:mesclainvest/core/models/user_profile.dart';
import 'package:mesclainvest/core/services/auth.dart';


// --- CODE ---

/// I hold the global application state shared across the widget tree.
/// I am a singleton — access me via [AppState.instance].
class AppState extends ChangeNotifier {

  AppState._();
  static final AppState instance = AppState._();

  UserProfile? _profile;

  UserProfile? get profile => _profile;


  /// I load the user profile from the backend and notify listeners.
  Future<void> loadProfile(AuthService authService) async {
    final fetched = await authService.getProfile();
    _profile = fetched;
    notifyListeners();
  }


  /// I refresh the profile after an update, applying partial changes locally
  /// to avoid a round-trip when the fields are already known.
  void updateProfileLocally({String? fullName, String? phone, String? photoUrl, bool? twoFaEnabled}) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      fullName:     fullName,
      phone:        phone,
      photoUrl:     photoUrl,
      twoFaEnabled: twoFaEnabled,
    );
    notifyListeners();
  }


  /// I clear the user profile (call on sign-out).
  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
