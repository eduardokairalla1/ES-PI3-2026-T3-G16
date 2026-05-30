// Eduardo Kairalla - 24024241

// Service for profile-related Cloud Function calls.

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';

// --- SERVICE ---

/// I handle Firebase Cloud Function calls for profile management.
class ProfileService {
  final _functions = FirebaseFunctions.instance;

  /// I update the authenticated user's profile fields.
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    final result = await _functions
        .httpsCallable('onUpdateProfile')
        .call<Map<String, dynamic>>(data);
    return Map<String, dynamic>.from(result.data as Map);
  }

}
