import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ride_request.dart';

class RideTrackingScreen extends StatefulWidget {
  static const String routeName = '/ride-tracking';
  final RideRequest rideRequest;

  const RideTrackingScreen({Key? key, required this.rideRequest})
    : super(key: key);

  @override
  _RideTrackingScreenState createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rideSub;

  @override
  void initState() {
    super.initState();
    _markers.addAll({
      Marker(
        markerId: const MarkerId('origin'),
        position: widget.rideRequest.pickupLocation,
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.rideRequest.dropoffLocation,
      ),
    });
    _listenDriverLocation();
  }

  void _listenDriverLocation() {
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
                  infoWindow: const InfoWindow(title: 'Conductor'),
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
    final origin = widget.rideRequest.pickupLocation;
    final dest = widget.rideRequest.dropoffLocation;
    final sw = LatLng(
      min(origin.latitude, dest.latitude),
      min(origin.longitude, dest.longitude),
    );
    final ne = LatLng(
      max(origin.latitude, dest.latitude),
      max(origin.longitude, dest.longitude),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento de Viaje')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: sw, zoom: 12),
        markers: _markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [origin, dest],
            width: 5,
            color: Colors.blue,
          ),
        },
        onMapCreated: (c) {
          _mapController = c;
          _mapController.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(southwest: sw, northeast: ne),
              60,
            ),
          );
        },
      ),
    );
  }
}
