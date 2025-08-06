import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; // para Position
import '../services/location_service.dart';
import '../models/ride_request.dart';

class DriverViewModel extends ChangeNotifier {
  static const String driverHomeRoute = '/driver-home';
  static const String driverTripDetailRoute = '/driver-trip-detail';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _availableSub;
  StreamSubscription<Position>? _positionSub;

  /// Si está ONLINE, escucha solicitudes; si OFFLINE, no escucha.
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  List<RideRequest> availableRides = [];

  /// Activa el modo ONLINE y comienza a escuchar solicitudes.
  void goOnline() {
    if (_isOnline) return;
    _isOnline = true;
    fetchAvailableRides();
    notifyListeners();
  }

  /// Cancela la escucha y pasa a OFFLINE.
  void goOffline() {
    if (!_isOnline) return;
    _isOnline = false;
    _availableSub?.cancel();
    availableRides = [];
    notifyListeners();
  }

  /// Suscribe a los rides "pending" ≤15 min.
  void fetchAvailableRides() {
    if (!_isOnline) return;

    _availableSub?.cancel();
    _availableSub = _firestore
        .collection('ride_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final now = DateTime.now();
          final List<RideRequest> rides = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final ts = data['createdAt'] as Timestamp?;
            // Si lleva ≥15 minutos en pending, lo eliminamos
            if (ts != null && now.difference(ts.toDate()).inMinutes >= 15) {
              _firestore.collection('ride_requests').doc(doc.id).delete();
              continue;
            }
            rides.add(RideRequest.fromMap(data, doc.id));
          }

          availableRides = rides;
          notifyListeners();
        });
  }

  /// Acepta el ride, asigna driverId, status y genera un PIN de 4 dígitos
  Future<void> acceptRide(String rideId) async {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) return;
    final pin = (Random().nextInt(9000) + 1000).toString();
    await _firestore.collection('ride_requests').doc(rideId).update({
      'status': 'accepted',
      'driverId': driverId,
      'pinCode': pin,
    });
    // El ride saldrá de pending en el stream
  }

  /// Rechaza localmente la solicitud (no modifica Firestore)
  Future<void> rejectRide(String rideId) async {
    // No hacemos nada para que siga disponible para otros conductores
  }

  Future<void> markInProgress(String rideId) async {
    await _firestore.collection('ride_requests').doc(rideId).update({
      'status': 'in_progress',
    });
  }

  Future<void> startOnTheWay(String rideId) async {
    _positionSub?.cancel();
    _positionSub = _locationService.getPositionStream().listen((pos) {
      _firestore.collection('ride_requests').doc(rideId).update({
        'status': 'on_the_way',
        'driverLocation': GeoPoint(pos.latitude, pos.longitude),
      });
    });
  }

  Future<void> completeTrip(String rideId) async {
    await _positionSub?.cancel();
    await _firestore.collection('ride_requests').doc(rideId).update({
      'status': 'completed',
      'driverLocation': null,
    });
  }

  Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  @override
  void dispose() {
    _availableSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }
}
