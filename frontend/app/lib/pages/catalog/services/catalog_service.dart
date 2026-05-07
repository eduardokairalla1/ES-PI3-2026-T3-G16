/// Eduardo Kairalla - 24024241

/// Service for startup catalog Cloud Function calls.

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';


// --- SERVICE ---

class CatalogService {

  final _functions = FirebaseFunctions.instance;

  /// I fetch all startups, optionally filtered by stage.
  Future<List<StartupModel>> fetchStartups({String? stage}) async {
    final data = <String, dynamic>{};
    if (stage != null) data['stage'] = stage;

    final result = await _functions
        .httpsCallable('onGetStartups')
        .call<Map<String, dynamic>>(data);

    final raw = (result.data as Map)['startups'] as List<dynamic>? ?? [];
    return raw
        .map((s) => StartupModel.fromMap(Map<String, dynamic>.from(s as Map)))
        .toList();
  }
}
