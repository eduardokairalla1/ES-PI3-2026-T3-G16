/// Eduardo Kairalla - 24024241

/// Controller for the startup catalog page.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';


// --- CONTROLLER ---

class CatalogController extends ChangeNotifier {

  final CatalogService _service = CatalogService();

  bool               isLoading    = true;
  List<StartupModel> startups     = [];
  String?            selectedStage;  // null = all
  String?            errorMessage;

  /// I load startups for the current stage filter.
  Future<void> load() async {
    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    try {
      startups = await _service.fetchStartups(stage: selectedStage);
    } catch (_) {
      errorMessage = 'Não foi possível carregar as startups. Tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// I apply a stage filter and reload.
  Future<void> filterByStage(String? stage) async {
    if (selectedStage == stage) return;
    selectedStage = stage;
    await load();
  }
}
