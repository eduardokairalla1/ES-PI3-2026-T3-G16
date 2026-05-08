/// --- Startup detail controller ---
///
/// Eduardo Kairalla - 24024241

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/pages/startup/services/startup_service.dart';


// --- CONTROLLER ---

/// I manage state and logic for the startup detail screen.
class StartupController extends ChangeNotifier {

  final StartupService _service = StartupService();

  bool isLoading         = true;
  bool isSendingQuestion = false;

  StartupModel?       startup;
  List<QuestionModel> questions = [];
  String?             errorMessage;

  /// I load the startup details and its public questions in parallel.
  Future<void> load(String startupId) async {
    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchStartup(startupId),
        _service.fetchQuestions(startupId),
      ]);

      startup   = results[0] as StartupModel;
      questions = results[1] as List<QuestionModel>;
    } catch (_) {
      errorMessage = 'Não foi possível carregar a startup. Tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// I send a question and refresh the questions list on success.
  ///
  /// Returns true if the question was sent successfully.
  Future<bool> sendQuestion(String startupId, String text, bool isPrivate) async {
    isSendingQuestion = true;
    notifyListeners();

    try {
      await _service.sendQuestion(startupId, text, isPrivate);
      questions = await _service.fetchQuestions(startupId);
      return true;
    } catch (_) {
      return false;
    } finally {
      isSendingQuestion = false;
      notifyListeners();
    }
  }
}
