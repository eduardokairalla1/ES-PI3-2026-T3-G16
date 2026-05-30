// --- Startup detail controller ---
//
// Eduardo Kairalla - 24024241

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/pages/startup/services/startup_service.dart';

// --- CONTROLLER ---

/// I manage state and logic for the startup detail screen.
class StartupController extends ChangeNotifier {
  final StartupService _service = StartupService();

  bool isLoading = true;
  bool isSendingQuestion = false;
  bool isBuyingTokens    = false;
  bool showOrderPanel    = false;
  int  orderQuantity     = 1;
  String? buyErrorMessage;

  StartupModel? startup;
  List<QuestionModel> questions = [];
  bool isInvestor = false;
  String? errorMessage;

  /// I load the startup details and its public questions in parallel.
  Future<void> load(String startupId, {bool silent = false}) async {
    // set loading state unless running silently
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      // fetch startup details and questions in parallel
      final results = await Future.wait([
        _service.fetchStartup(startupId),
        _service.fetchQuestions(startupId),
      ]);

      // unpack results
      startup = results[0] as StartupModel;
      final questionsResult = results[1] as ({List<QuestionModel> questions, bool isInvestor});
      questions = questionsResult.questions;
      isInvestor = questionsResult.isInvestor;
    } catch (_) {
      if (!silent) {
        errorMessage = 'Não foi possível carregar a startup. Tente novamente.';
      }
    } finally {
      if (!silent) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  /// I open the order panel and reset quantity and error state.
  void openOrderPanel() {
    orderQuantity   = 1;
    buyErrorMessage = null;
    showOrderPanel  = true;
    notifyListeners();
  }

  /// I close the order panel.
  void closeOrderPanel() {
    showOrderPanel = false;
    notifyListeners();
  }

  /// I increment the order quantity by one, up to a maximum of 10 000.
  void incrementOrder() {
    if (orderQuantity < 10000) orderQuantity++;
    notifyListeners();
  }

  /// I decrement the order quantity by one, down to a minimum of 1.
  void decrementOrder() {
    if (orderQuantity > 1) orderQuantity--;
    notifyListeners();
  }

  /// I set the order quantity to the given value, clamped between 1 and 10 000.
  void setOrderQuantity(int qty) {
    if (qty >= 1 && qty <= 10000) {
      orderQuantity = qty;
      notifyListeners();
    }
  }

  /// I buy tokens and return true on success.
  Future<bool> buyTokens(String startupId) async {
    // mark purchase as in progress
    isBuyingTokens  = true;
    buyErrorMessage = null;
    notifyListeners();

    try {
      // call cloud function to execute the buy order
      await _service.buyTokens(startupId, orderQuantity);
      // close panel and silently refresh startup data
      showOrderPanel = false;
      await load(startupId, silent: true);
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
  Future<bool> sendQuestion(
    String startupId,
    String text,
    bool isPrivate,
  ) async {
    isSendingQuestion = true;
    notifyListeners();

    try {
      await _service.sendQuestion(startupId, text, isPrivate);
      final result = await _service.fetchQuestions(startupId);
      questions = result.questions;
      isInvestor = result.isInvestor;
      return true;
    } catch (_) {
      return false;
    } finally {
      isSendingQuestion = false;
      notifyListeners();
    }
  }
}
