import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequest {
  final String id;
  final String userId;
  final String userName;
  final String destinationName;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final String status;
  final double fare;

  final DateTime? createdAt;
  final String? pinCode;

  RideRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.destinationName,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.status,
    required this.fare,
    this.createdAt,
    this.pinCode,
  });

  factory RideRequest.fromMap(Map<String, dynamic> data, String documentId) {
    return RideRequest(
      id: documentId,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      destinationName: data['destinationName'] as String? ?? '',
      pickupLat: (data['pickupLat'] ?? 0).toDouble(),
      pickupLng: (data['pickupLng'] ?? 0).toDouble(),
      destinationLat: (data['destinationLat'] ?? 0).toDouble(),
      destinationLng: (data['destinationLng'] ?? 0).toDouble(),
      status: data['status'] as String? ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      pinCode: data['pinCode'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'destinationName': destinationName,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'status': status,
      'fare': fare,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (pinCode != null) {
      map['pinCode'] = pinCode;
    }
    return map;
  }

  LatLng get pickupLocation => LatLng(pickupLat, pickupLng);
  LatLng get dropoffLocation => LatLng(destinationLat, destinationLng);

  String get pickupAddress => 'Lat: $pickupLat, Lng: $pickupLng';
  String get dropoffAddress => destinationName;
}
