import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ride_request.dart';
import '../services/directions_service.dart';

class RideViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _directions = DirectionsService();

  LatLng? _origin;
  LatLng? _destination;
  String _paymentMethod = 'Efectivo';
  double _fare = 0.0;

  String? _lastRideId;
  String? _assignedDriverId;

  // getters públicos
  LatLng? get origin => _origin;
  LatLng? get destination => _destination;
  String get paymentMethod => _paymentMethod;
  double get estimatedFare => _fare;
  double get driverShare => _fare * 0.75;
  double get companyShare => _fare * 0.25;
  String? get rideId => _lastRideId;
  String? get assignedDriverId => _assignedDriverId;

  set paymentMethod(String v) {
    _paymentMethod = v;
    notifyListeners();
  }

  Future<void> setTripLocations({
    required LatLng origin,
    required LatLng destination,
  }) async {
    _origin = origin;
    _destination = destination;
    notifyListeners();

    final result = await _directions.getDirections(
      origin: origin,
      destination: destination,
    );
    final km = result.distanceMeters / 1000.0;
    const double minFare = 3.0, rate1 = 1.2, rate2 = 0.9;
    double fare = km <= 5 ? rate1 * km : rate1 * 5 + rate2 * (km - 5);
    _fare = max(fare, minFare);
    notifyListeners();
  }

  Future<void> requestRideSilent() async {
    if (_origin == null || _destination == null) return;
    final ride = RideRequest(
      id: '',
      userId: 'user-id-ejemplo',
      userName: 'Usuario Ejemplo',
      destinationName: 'Destino Ejemplo',
      pickupLat: _origin!.latitude,
      pickupLng: _origin!.longitude,
      destinationLat: _destination!.latitude,
      destinationLng: _destination!.longitude,
      status: 'pending',
      fare: _fare,
    );
    final docRef = await _firestore
        .collection('ride_requests')
        .add(ride.toMap());
    _lastRideId = docRef.id;
    notifyListeners();
  }

  Future<void> requestRide(BuildContext context) async {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Origen o destino no están definidos')),
      );
      return;
    }
    await requestRideSilent();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viaje solicitado correctamente')),
    );
  }

  Future<void> cancelRide() async {
    if (_lastRideId != null) {
      await _firestore.collection('ride_requests').doc(_lastRideId).update({
        'status': 'cancelled',
      });
    }
  }

  Stream<List<RideRequest>> rideStream(String userId) {
    return _firestore
        .collection('ride_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          final list =
              snap.docs
                  .map((d) => RideRequest.fromMap(d.data(), d.id))
                  .toList();
          if (list.isNotEmpty) {
            _lastRideId = list.first.id;
            _assignedDriverId = snap.docs.first.data()['driverId'] as String?;
            notifyListeners();
          }
          return list;
        });
  }

  Stream<RideRequest> currentRideStream() {
    if (_lastRideId == null) {
      throw Exception('No hay viaje activo');
    }
    return _firestore
        .collection('ride_requests')
        .doc(_lastRideId)
        .snapshots()
        .map((d) => RideRequest.fromMap(d.data()!, d.id));
  }
}
