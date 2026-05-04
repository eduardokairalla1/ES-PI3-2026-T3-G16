/// Eduardo Kairalla - 24024241

/// Controller for the profile screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/services/auth.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/profile/services/profile_service.dart';


// --- CONTROLLER ---

class ProfileController extends ChangeNotifier {

  final ProfileService _service = ProfileService();
  final AuthService _authService = AuthService();
  final DashboardService _dashboardService = DashboardService();

  bool isTogglingTwoFA = false;
  bool isSigningOut = false;
  bool isLoadingStats = true;
  DashboardData? _dashboardData;

  /// Carrega dados do dashboard para exibir estatísticas.
  Future<void> loadStats() async {
    isLoadingStats = true;
    notifyListeners();

    try {
      _dashboardData = await _dashboardService.fetchUserDashboardData();
    } catch (_) {
      _dashboardData = null;
    } finally {
      isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Retorna o número de investimentos do usuário.
  int get totalInvestimentos => _dashboardData?.investimentos.length ?? 0;

  /// Retorna o total aplicado pelo usuário.
  double get totalAplicado => _dashboardData?.patrimonioTotal ?? 0;

  /// Retorna o número de startups favoritadas.
  int get totalFavoritas => _dashboardData?.favoriteIds.length ?? 0;

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