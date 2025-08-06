import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) =>
      _db.collection('users').doc(uid).get();

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String photoUrl,
    required String role,
  }) => _db.collection('users').doc(uid).set({
    'name': name,
    'phone': phone,
    'photoUrl': photoUrl,
    'role': role,
    'createdAt': FieldValue.serverTimestamp(),
  });

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

  Future<void> recordPayment({
    required String rideId,
    required String userId,
    required String method,
    required double amount,
  }) => _db.collection('payments').add({
    'rideId': rideId,
    'userId': userId,
    'method': method,
    'amount': amount,
    'timestamp': FieldValue.serverTimestamp(),
  });

  Future<void> deleteRideRequest(String rideId) =>
      _db.collection('ride_requests').doc(rideId).delete();
}
