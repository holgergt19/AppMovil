import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String rideId;
  final double amount;
  final String method; // 'cash' o 'card'
  final String status; // 'pending' o 'completed'
  final Timestamp timestamp;

  PaymentModel({
    required this.id,
    required this.rideId,
    required this.amount,
    required this.method,
    required this.status,
    required this.timestamp,
  });
}
