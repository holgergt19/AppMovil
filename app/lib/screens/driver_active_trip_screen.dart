import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ride_request.dart';

class DriverActiveTripScreen extends StatefulWidget {
  static const String routeName = '/driver-active-trip';
  final RideRequest rideRequest;

  const DriverActiveTripScreen({Key? key, required this.rideRequest})
    : super(key: key);

  @override
  _DriverActiveTripScreenState createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends State<DriverActiveTripScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rideSub;

  @override
  void initState() {
    super.initState();
    _markers.addAll({
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.rideRequest.pickupLocation,
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.rideRequest.dropoffLocation,
      ),
    });
    _listenDriverUpdates();
  }

  void _listenDriverUpdates() {
    _rideSub = FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(widget.rideRequest.id)
        .snapshots()
        .listen((snap) {
          final data = snap.data();
          if (data != null && data['driverLocation'] != null) {
            final gp = data['driverLocation'] as GeoPoint;
            final pos = LatLng(gp.latitude, gp.longitude);
            setState(() {
              _markers.removeWhere((m) => m.markerId.value == 'driver');
              _markers.add(
                Marker(
                  markerId: const MarkerId('driver'),
                  position: pos,
                  infoWindow: const InfoWindow(title: 'Tu ubicación'),
                ),
              );
            });
            _mapController.animateCamera(CameraUpdate.newLatLng(pos));
          }
        });
  }

  @override
  void dispose() {
    _rideSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viaje Activo')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.rideRequest.pickupLocation,
          zoom: 14,
        ),
        markers: _markers,
        onMapCreated: (c) => _mapController = c,
      ),
    );
  }
}
