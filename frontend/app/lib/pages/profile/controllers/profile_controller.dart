/// Eduardo Kairalla - 24024241

/// Controller for the profile screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/services/auth.dart';
import 'package:mesclainvest/pages/profile/services/profile_service.dart';


// --- CONTROLLER ---

class ProfileController extends ChangeNotifier {

  final ProfileService _service    = ProfileService();
  final AuthService    _authService = AuthService();

  bool isTogglingTwoFA = false;
  bool isSigningOut    = false;


  /// I toggle 2FA and update AppState locally.
  Future<void> toggle2FA() async {
    isTogglingTwoFA = true;
    notifyListeners();

    try {
      final newState = await _service.toggle2FA();
      AppState.instance.updateProfileLocally(twoFaEnabled: newState);
    } finally {
      isTogglingTwoFA = false;
      notifyListeners();
    }
  }


  /// I sign the user out and clear app state.
  Future<void> signOut() async {
    isSigningOut = true;
    notifyListeners();

    try {
      await _authService.signOut();
      AppState.instance.clearProfile();
    } finally {
      isSigningOut = false;
      notifyListeners();
    }
  }
}
