// Eduardo Kairalla - 24024241

// Controller for the profile screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/services/auth.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';

// --- CONTROLLER ---

/// I manage state and actions for the user profile screen.
class ProfileController extends ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  final AuthService _authService = AuthService();
  final DashboardService _dashboardService = DashboardService();

  bool isDisabling2FA = false;
  bool isSigningOut   = false;
  bool isLoadingStats = true;
  DashboardData? _dashboardData;

  /// Carrega dados do dashboard para exibir estatísticas.
  Future<void> loadStats({bool silent = false}) async {
    if (!silent) {
      isLoadingStats = true;
      notifyListeners();
    }

    try {
      _dashboardData = await _dashboardService.fetchUserDashboardData();
    } catch (_) {
      if (!silent) _dashboardData = null;
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

  /// I disable 2FA after re-authenticating with the user's password.
  Future<void> disable2FAWithPassword(String password) async {
    isDisabling2FA = true;
    notifyListeners();

    try {
      await _authService.disable2FAByPassword(password);
      AppState.instance.updateProfileLocally(twoFaEnabled: false);
    } finally {
      isDisabling2FA = false;
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
