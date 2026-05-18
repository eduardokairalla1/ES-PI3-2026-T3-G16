/// Modelo de uma oferta pendente do usuário.
///
/// Alex Gabriel Soares Sousa - 24802449

import 'package:cloud_firestore/cloud_firestore.dart';

class PendingOrderModel {
  final String id;
  final String startupId;
  final String startupName;
  final String logoUrl;
  final String type;
  final int quantity;
  final double price;
  final double totalAmount;
  final DateTime createdAt;

  const PendingOrderModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.logoUrl,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.createdAt,
  });

  factory PendingOrderModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return PendingOrderModel(
      id: map['id'] as String,
      startupId: map['startupId'] as String,
      startupName: map['startupName'] as String,
      logoUrl: map['logoUrl'] as String? ?? '',
      type: map['type'] as String,
      quantity: (map['quantity'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      createdAt: parsedDate,
    );
  }
}
