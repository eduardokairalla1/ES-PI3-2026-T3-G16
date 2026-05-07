/// --- Startup service ---
///
/// Eduardo Kairalla - 24024241

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';


// --- SERVICE ---

/// I handle all Firebase Cloud Function calls related to startups.
class StartupService {

  final _functions = FirebaseFunctions.instance;

  /// I fetch a single startup by ID.
  Future<StartupModel> fetchStartup(String id) async {
    final result = await _functions
        .httpsCallable('onGetStartup')
        .call<Map<String, dynamic>>({'id': id});

    return StartupModel.fromMap(Map<String, dynamic>.from(result.data as Map));
  }

  /// I fetch the public questions for a startup.
  Future<List<QuestionModel>> fetchQuestions(String startupId) async {
    final result = await _functions
        .httpsCallable('onGetQuestions')
        .call<Map<String, dynamic>>({'startupId': startupId});

    final raw = (result.data as Map)['questions'] as List<dynamic>? ?? [];
    return raw
        .map((q) => QuestionModel.fromMap(Map<String, dynamic>.from(q as Map)))
        .toList();
  }

  /// I send a question to a startup.
  Future<void> sendQuestion(String startupId, String text, bool isPrivate) async {
    await _functions.httpsCallable('onSendQuestion').call<Map<String, dynamic>>({
      'isPrivate': isPrivate,
      'startupId': startupId,
      'text':      text,
    });
  }
}
