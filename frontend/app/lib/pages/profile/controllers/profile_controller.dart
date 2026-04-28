import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/profile/models/profile_data.dart';
import 'package:mesclainvest/pages/profile/services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  bool isLoading = true;
  bool twoFactorEnabled = true;
  bool darkModeEnabled = false;
  ProfileData? data;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _service.fetchProfileData();
    } catch (error) {
      debugPrint('Failed to load profile: $error');
    }

    isLoading = false;
    notifyListeners();
  }

  void setTwoFactor(bool value) {
    twoFactorEnabled = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    darkModeEnabled = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
