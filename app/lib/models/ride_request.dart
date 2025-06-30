import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequest {
  final String id;
  final String userId;
  final double originLat, originLng;
  final double destLat, destLng;
  final int distanceMeters, durationSeconds;
  final double fare;
  String status; // pending, accepted, in_progress, completed
  double? driverLat, driverLng;

  RideRequest({
    required this.id,
    required this.userId,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.fare,
    this.status = 'pending',
    this.driverLat,
    this.driverLng,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'origin': {'lat': originLat, 'lng': originLng},
    'destination': {'lat': destLat, 'lng': destLng},
    'distanceMeters': distanceMeters,
    'durationSeconds': durationSeconds,
    'fare': fare,
    'status': status,
    // driverLoc solo si existe:
    if (driverLat != null && driverLng != null)
      'driverLocation': {'lat': driverLat, 'lng': driverLng},
  };

  factory RideRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final driverLoc = d['driverLocation'] as Map<String, dynamic>?;
    return RideRequest(
      id: doc.id,
      userId: d['userId'] as String,
      originLat: d['origin']['lat'] as double,
      originLng: d['origin']['lng'] as double,
      destLat: d['destination']['lat'] as double,
      destLng: d['destination']['lng'] as double,
      distanceMeters: d['distanceMeters'] as int,
      durationSeconds: d['durationSeconds'] as int,
      fare: (d['fare'] as num).toDouble(),
      status: d['status'] as String,
      driverLat: driverLoc?['lat'] as double?,
      driverLng: driverLoc?['lng'] as double?,
    );
  }
}
