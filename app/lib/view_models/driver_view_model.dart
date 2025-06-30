import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../models/ride_request.dart';

class DriverViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final LocationService _loc = LocationService();

  bool isAvailable = false;
  StreamSubscription<Position>? _posSub;

  // Stream de solicitudes pendientes
  Stream<List<RideRequest>> get pendingRequests => _db
      .collection('ride_requests')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => RideRequest.fromDoc(doc)).toList());

  // Carga estado inicial
  Future<void> loadStatus(String uid) async {
    final doc = await _db.collection('drivers').doc(uid).get();
    isAvailable = doc.data()?['available'] ?? false;
    notifyListeners();
    if (isAvailable) _startTracking(uid);
  }

  // Alterna disponibilidad + tracking
  Future<void> toggleAvailable(String uid, bool val) async {
    isAvailable = val;
    notifyListeners();
    await _db.collection('drivers').doc(uid).set({
      'available': val,
    }, SetOptions(merge: true));

    if (val) {
      _startTracking(uid);
    } else {
      await _posSub?.cancel();
      await _db.collection('drivers').doc(uid).update({'position': null});
    }
  }

  void _startTracking(String uid) {
    _posSub = _loc.getPositionStream().listen((pos) {
      _db.collection('drivers').doc(uid).update({
        'position': GeoPoint(pos.latitude, pos.longitude),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    await _db.collection('ride_requests').doc(rideId).update({
      'driverId': driverId,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> startTrip(String rideId) async {
    await _db.collection('ride_requests').doc(rideId).update({
      'status': 'in_progress',
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> finishTrip(String rideId) async {
    await _db.collection('ride_requests').doc(rideId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }
}
