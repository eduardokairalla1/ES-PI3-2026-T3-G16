/// --- Startup detail controller ---
///
/// Eduardo Kairalla - 24024241

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/pages/startup/services/startup_service.dart';


// --- CONTROLLER ---

/// I manage state and logic for the startup detail screen.
class StartupController extends ChangeNotifier {

  final StartupService _service = StartupService();

  bool isLoading         = true;
  bool isSendingQuestion = false;
  bool isBuyingTokens    = false;
  bool showOrderPanel    = false;
  int  orderQuantity     = 1;
  String? buyErrorMessage;

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

  void openOrderPanel() {
    orderQuantity   = 1;
    buyErrorMessage = null;
    showOrderPanel  = true;
    notifyListeners();
  }

  void closeOrderPanel() {
    showOrderPanel = false;
    notifyListeners();
  }

  void incrementOrder() {
    orderQuantity++;
    notifyListeners();
  }

  void decrementOrder() {
    if (orderQuantity > 1) orderQuantity--;
    notifyListeners();
  }

  /// I buy tokens and return true on success.
  Future<bool> buyTokens(String startupId) async {
    isBuyingTokens  = true;
    buyErrorMessage = null;
    notifyListeners();

    try {
      await _service.buyTokens(startupId, orderQuantity);
      showOrderPanel = false;
      return true;
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'invalid-argument':
          final msg = e.message ?? '';
          if (msg.toLowerCase().contains('balance')) {
            buyErrorMessage = 'Saldo insuficiente para realizar este investimento.';
          } else if (msg.toLowerCase().contains('token')) {
            buyErrorMessage = 'Tokens insuficientes disponíveis para esta startup.';
          } else {
            buyErrorMessage = e.message ?? 'Dados inválidos.';
          }
        case 'not-found':
          buyErrorMessage = 'Startup não encontrada.';
        case 'unauthenticated':
          buyErrorMessage = 'Sessão expirada. Faça login novamente.';
        default:
          buyErrorMessage = 'Não foi possível realizar o investimento. Tente novamente.';
      }
      return false;
    } finally {
      isBuyingTokens = false;
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
