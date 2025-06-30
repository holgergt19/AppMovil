import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crea/lee/actualiza el perfil de usuario
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String photoUrl,
  }) {
    return _db.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? photoUrl,
  }) {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    return _db.collection('users').doc(uid).update(data);
  }

  /// Crea la solicitud de viaje y devuelve el rideId
  Future<String> createRideRequest({
    required LatLng origin,
    required LatLng destination,
    required double distanceMeters,
    required double fare,
  }) async {
    final doc = await _db.collection('ride_requests').add({
      'origin': GeoPoint(origin.latitude, origin.longitude),
      'destination': GeoPoint(destination.latitude, destination.longitude),
      'distanceMeters': distanceMeters,
      'fare': fare,
      'status': 'requested',
      'timestamp': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Escucha el documento de ride en tiempo real
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamRide(String rideId) {
    return _db.collection('ride_requests').doc(rideId).snapshots();
  }

  /// Actualiza cualquier campo de un rideRequest
  Future<void> updateRideRequest(String rideId, Map<String, dynamic> data) {
    return _db.collection('ride_requests').doc(rideId).update(data);
  }

  /// Graba un pago en la colección payments
  Future<void> recordPayment({
    required String rideId,
    required String userId,
    required String method,
    required double amount,
  }) {
    return _db.collection('payments').add({
      'rideId': rideId,
      'userId': userId,
      'method': method,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
