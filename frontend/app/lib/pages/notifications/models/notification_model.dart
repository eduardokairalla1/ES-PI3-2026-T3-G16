// Pedro Henrique Medeiros dos Reis - 24801656
//
// Model + enum mirroring backend/.../notifications/model.d.ts.

import 'package:flutter/material.dart';

/// Types recognised by the backend.
enum NotificationType {
  welcome,
  depositConfirmed,
  orderExecuted,
  orderCounterMatch,
  questionAnswered,
  unknown;

  /// Parses the backend string into the enum (fallback: [unknown]).
  static NotificationType fromString(String? raw) {
    switch (raw) {
      case 'welcome':              return NotificationType.welcome;
      case 'deposit_confirmed':    return NotificationType.depositConfirmed;
      case 'order_executed':       return NotificationType.orderExecuted;
      case 'order_counter_match':  return NotificationType.orderCounterMatch;
      case 'question_answered':    return NotificationType.questionAnswered;
      default:                     return NotificationType.unknown;
    }
  }
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.payload,
    required this.createdAt,
  });

  String? get startupId   => payload['startupId']   as String?;
  String? get questionId  => payload['questionId']  as String?;

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id:        map['id']    as String? ?? '',
      type:      NotificationType.fromString(map['type'] as String?),
      title:     map['title'] as String? ?? '',
      body:      map['body']  as String? ?? '',
      payload:   Map<String, dynamic>.from((map['payload'] as Map?) ?? const {}),
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
    );
  }
}

/// Converts a Firestore Timestamp ({_seconds, _nanoseconds}) into a DateTime.
DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    final seconds = (value['_seconds'] as num?)?.toInt() ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Icon + colour used by the tile, per type.
class NotificationVisual {
  final IconData icon;
  final Color color;
  const NotificationVisual({required this.icon, required this.color});

  static NotificationVisual forType(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return NotificationVisual(icon: Icons.celebration, color: Colors.amber.shade700);
      case NotificationType.depositConfirmed:
        return NotificationVisual(icon: Icons.account_balance_wallet, color: Colors.green.shade700);
      case NotificationType.orderExecuted:
        return NotificationVisual(icon: Icons.check_circle, color: Colors.green.shade700);
      case NotificationType.orderCounterMatch:
        return NotificationVisual(icon: Icons.swap_horiz, color: Colors.blue.shade700);
      case NotificationType.questionAnswered:
        return NotificationVisual(icon: Icons.forum, color: Colors.deepPurple.shade400);
      case NotificationType.unknown:
        return NotificationVisual(icon: Icons.notifications, color: Colors.grey.shade600);
    }
  }
}
