// Pedro Henrique Medeiros dos Reis - 24801656
//
// Wrappers over the 3 notification callables.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/notifications/models/notification_model.dart';

class NotificationsService {
  final _functions = FirebaseFunctions.instance;

  Future<List<NotificationModel>> fetchAll() async {
    final result = await _functions
        .httpsCallable('onGetNotifications')
        .call<Map<String, dynamic>>();

    final list = (result.data['notifications'] as List<dynamic>?) ?? const [];
    return list
        .map((e) => NotificationModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> deleteOne(String notificationId) async {
    await _functions
        .httpsCallable('onDeleteNotification')
        .call<Map<String, dynamic>>({'notificationId': notificationId});
  }

  /// Returns the number of notifications deleted.
  Future<int> deleteAll() async {
    final result = await _functions
        .httpsCallable('onDeleteAllNotifications')
        .call<Map<String, dynamic>>();

    return (result.data['deletedCount'] as num?)?.toInt() ?? 0;
  }
}
