import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  });

  factory RideRequest.fromMap(Map<String, dynamic> data, String documentId) {
    return RideRequest(
      id: documentId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      destinationName: data['destinationName'] ?? '',
      pickupLat: (data['pickupLat'] ?? 0).toDouble(),
      pickupLng: (data['pickupLng'] ?? 0).toDouble(),
      destinationLat: (data['destinationLat'] ?? 0).toDouble(),
      destinationLng: (data['destinationLng'] ?? 0).toDouble(),
      status: data['status'] ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'destinationName': destinationName,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'status': status,
      'fare': fare,
    };
  }

  LatLng get pickupLocation => LatLng(pickupLat, pickupLng);
  LatLng get dropoffLocation => LatLng(destinationLat, destinationLng);

  String get pickupAddress => 'Lat: $pickupLat, Lng: $pickupLng';
  String get dropoffAddress => destinationName;
}
