// --- App state ---
//
// Global singleton that keeps profile, wallet summary and app-wide refresh
// signals synchronized across the Flutter widget tree.

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
  double? _saldoDisponivel;
  double? _patrimonioTotal;
  final Set<String> _favoriteIds = {};

  int _refreshTicket = 0;

  UserProfile? get profile => _profile;

  /// Current wallet cash balance, defaulting to zero before the first load.
  double get saldoDisponivel => _saldoDisponivel ?? 0;

  /// Current wallet cash balance, or null while it has not been loaded yet.
  double? get saldoDisponivelAtual => _saldoDisponivel;

  /// Current total net worth returned by the dashboard payload.
  double? get patrimonioTotal => _patrimonioTotal;

  /// Startup ids favorited by the current user.
  Set<String> get favoriteIds => _favoriteIds;

  /// Monotonic signal used by pages that need to refresh after money changes.
  int get refreshTicket => _refreshTicket;

  /// I notify global listeners that money-sensitive pages should refresh.
  void triggerGlobalRefresh() {
    _refreshTicket++;
    notifyListeners();
  }

  /// I update only the wallet cash balance and notify listeners if it changed.
  void setSaldoDisponivel(double balance) {
    if (_saldoDisponivel == balance) return;
    _saldoDisponivel = balance;
    notifyListeners();
  }

  /// I update the wallet cash balance and total net worth together.
  void setFinancialSummary({
    required double saldoDisponivel,
    required double patrimonioTotal,
  }) {
    if (_saldoDisponivel == saldoDisponivel &&
        _patrimonioTotal == patrimonioTotal) {
      return;
    }
    _saldoDisponivel = saldoDisponivel;
    _patrimonioTotal = patrimonioTotal;
    notifyListeners();
  }

  /// I apply a local delta to total net worth when the backend has already
  /// confirmed a mutation but the dashboard refresh has not arrived yet.
  void adjustPatrimonioTotal(double delta) {
    if (_patrimonioTotal == null) return;
    _patrimonioTotal = _patrimonioTotal! + delta;
    notifyListeners();
  }

  /// I replace the current favorite startup set.
  void setFavoriteIds(Set<String> ids) {
    _favoriteIds.clear();
    _favoriteIds.addAll(ids);
    notifyListeners();
  }

  /// I optimistically update one startup favorite flag.
  void setFavorite(String startupId, bool isFav) {
    final wasFav = _favoriteIds.contains(startupId);
    if (wasFav == isFav) return;
    if (isFav) {
      _favoriteIds.add(startupId);
    } else {
      _favoriteIds.remove(startupId);
    }
    notifyListeners();
  }

  /// I load the user profile from the backend and notify listeners.
  Future<void> loadProfile(AuthService authService) async {
    final fetched = await authService.getProfile();
    _profile = fetched;
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

  /// I clear the user profile (call on sign-out).
  void clearProfile() {
    _profile = null;
    _saldoDisponivel = null;
    _patrimonioTotal = null;
    notifyListeners();
  }
}
