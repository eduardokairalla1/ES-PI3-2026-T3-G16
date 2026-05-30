// Pedro Henrique Medeiros dos Reis - 24801656
//
// State for the notifications inbox. Singleton shared between the bell
// (header) and the modal. ChangeNotifier + silent reload pattern, same
// shape as the other controllers in the project.

import 'package:flutter/foundation.dart';
import 'package:mesclainvest/pages/notifications/models/notification_model.dart';
import 'package:mesclainvest/pages/notifications/services/notifications_service.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController._();
  static final NotificationsController instance = NotificationsController._();

  final NotificationsService _service = NotificationsService();

  bool _disposed = false;

  List<NotificationModel> notifications = [];
  bool isLoading                        = true;
  String? errorMessage;

  /// Count of pending items — drives the dot on the bell.
  int get unreadCount => notifications.length;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Reloads the inbox. In [silent] mode the loading flag is left alone
  /// (used by the silent reload on tab switch).
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      isLoading    = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      notifications = await _service.fetchAll();
    } catch (_) {
      if (!silent) {
        errorMessage = 'Não foi possível carregar as notificações.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a single notification optimistically. Restores on failure.
  Future<void> deleteOne(String notificationId) async {
    final before = List<NotificationModel>.from(notifications);

    notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();

    try {
      await _service.deleteOne(notificationId);
    } catch (_) {
      notifications = before;
      errorMessage  = 'Erro ao remover a notificação.';
      notifyListeners();
    }
  }

  /// Clears the entire inbox at once (optimistic too).
  Future<void> clearAll() async {
    final before = List<NotificationModel>.from(notifications);

    notifications = [];
    notifyListeners();

    try {
      await _service.deleteAll();
    } catch (_) {
      notifications = before;
      errorMessage  = 'Erro ao limpar as notificações.';
      notifyListeners();
    }
  }
}
