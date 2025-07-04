import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ride_request.dart';
import '../services/location_service.dart';

class DriverViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  List<RideRequest> _availableRides = [];
  List<RideRequest> get availableRides => _availableRides;

  StreamSubscription<Position>? _positionSub;

  static const String driverHomeRoute = '/driver-home';
  static const String driverTripDetailRoute = '/driver-trip-detail';
  static const String driverActiveTripRoute = '/driver-active-trip';

  Future<void> fetchAvailableRides() async {
    final snapshot =
        await _firestore
            .collection('ride_requests')
            .where('status', isEqualTo: 'pending')
            .get();
    _availableRides =
        snapshot.docs.map((d) => RideRequest.fromMap(d.data(), d.id)).toList();
    notifyListeners();
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    // paso 1: marcar accepted
    await _firestore.collection('ride_requests').doc(rideId).update({
      'status': 'accepted',
      'driverId': driverId,
    });
    // paso 2: navega a ActiveTrip
    notifyListeners();
  }

  Future<void> startOnTheWay(String rideId) async {
    // solicita permisos y empieza a enviar geo
    final ok = await _locationService.requestPermission();
    if (!ok) return;
    _positionSub = _locationService.getPositionStream().listen((pos) {
      _firestore.collection('ride_requests').doc(rideId).update({
        'driverLocation': GeoPoint(pos.latitude, pos.longitude),
        'status': 'on_the_way',
      });
    });
  }

  Future<void> markInProgress(String rideId) async {
    await _positionSub?.cancel();
    await _firestore.collection('ride_requests').doc(rideId).update({
      'status': 'in_progress',
    });
  }

  Future<void> completeTrip(String rideId) async {
    await _firestore.collection('ride_requests').doc(rideId).update({
      'status': 'completed',
    });
  }

  Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }
}
