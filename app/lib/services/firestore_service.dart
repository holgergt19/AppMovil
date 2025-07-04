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
    required String role, // ← nuevo parámetro
  }) {
    return _db.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role, // ← guardamos rol
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

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

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? photoUrl,
    // no tocamos role aquí
  }) {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    return _db.collection('users').doc(uid).update(data);
  }

  // ... el resto de métodos sin cambios
}
