// --- App state ---

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
  bool         _pendingTwoFa  = false;
  bool         _isRegistering = false;

  UserProfile? get profile        => _profile;
  bool         get pendingTwoFa   => _pendingTwoFa;
  bool         get isRegistering  => _isRegistering;

  void setRegistering(bool value) {
    _isRegistering = value;
    notifyListeners();
  }

  /// I load the user profile from the backend and notify listeners.
  Future<void> loadProfile(AuthService authService) async {
    final fetched = await authService.getProfile();
    _profile = fetched;
    notifyListeners();
  }



  /// I set the profile directly (used after sign-in when 2FA is not required).
  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }


  /// I mark that the current session is awaiting 2FA verification.
  void setPendingTwoFa() {
    _pendingTwoFa = true;
    notifyListeners();
  }


  /// I clear the pending 2FA state after successful verification.
  void clearPendingTwoFa() {
    _pendingTwoFa = false;
    notifyListeners();
  }



  /// I refresh the profile after an update, applying partial changes locally
  /// to avoid a round-trip when the fields are already known.
  void updateProfileLocally({
    String? fullName,
    String? phone,
    String? photoUrl,
    bool? twoFaEnabled,
  }) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      fullName: fullName,
      phone: phone,
      photoUrl: photoUrl,
      twoFaEnabled: twoFaEnabled,
    );
    notifyListeners();
  }


  /// I clear the user profile and pending 2FA state (call on sign-out).
  void clearProfile() {
    _profile      = null;
    _pendingTwoFa = false;
    notifyListeners();
  }
}
