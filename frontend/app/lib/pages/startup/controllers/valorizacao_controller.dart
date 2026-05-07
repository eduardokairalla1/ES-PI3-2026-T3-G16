import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/models/price_snapshot_model.dart';
import 'package:mesclainvest/pages/dashboard/services/token_history_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/pages/startup/services/startup_service.dart';

class ValorizacaoController extends ChangeNotifier {

  final StartupService      _startupService = StartupService();
  final TokenHistoryService _historyService = TokenHistoryService();

  bool   isLoading      = true;
  String selectedPeriod = 'weekly';
  String? errorMessage;

  StartupModel?       startup;
  TokenHistoryModel?  tokenHistory;
  bool                isLoadingChart = false;
  String?             chartError;

  Future<void> load(String startupId) async {
    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    try {
      startup = await _startupService.fetchStartup(startupId);
      await _loadChart(startupId);
    } catch (_) {
      errorMessage = 'Não foi possível carregar os dados. Tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPeriod(String startupId, String period) async {
    selectedPeriod = period;
    notifyListeners();
    await _loadChart(startupId);
  }

  Future<void> _loadChart(String startupId) async {
    isLoadingChart = true;
    chartError     = null;
    notifyListeners();

    try {
      tokenHistory = await _historyService.fetchHistory(startupId, selectedPeriod);
    } catch (_) {
      tokenHistory = null;
      chartError   = 'Não foi possível carregar o histórico. Tente novamente.';
    } finally {
      isLoadingChart = false;
      notifyListeners();
    }
  }
}
