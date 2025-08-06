import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ride_request.dart';
import '../services/directions_service.dart';
import 'payment_screen.dart';

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
  final _markers = <Marker>{};
  final _polylines = <Polyline>{};
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rideSub;
  String _status = '';
  int? _etaMinutes;

  @override
  void initState() {
    super.initState();
    _status = widget.rideRequest.status;
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
    _listenRideUpdates();
  }

  void _listenRideUpdates() {
    _rideSub = FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(widget.rideRequest.id)
        .snapshots()
        .listen((snap) async {
          final data = snap.data();
          if (data == null) return;
          final status = data['status'] as String? ?? '';
          final gp = data['driverLocation'] as GeoPoint?;
          setState(() => _status = status);

          if (gp != null) {
            final pos = LatLng(gp.latitude, gp.longitude);
            _markers
              ..removeWhere((m) => m.markerId.value == 'driver')
              ..add(Marker(markerId: const MarkerId('driver'), position: pos));
            _mapController.animateCamera(CameraUpdate.newLatLng(pos));

            // calcular ETA y polilínea
            final origin =
                (status == 'on_the_way')
                    ? pos
                    : widget.rideRequest.pickupLocation;
            final dest =
                (status == 'on_the_way')
                    ? widget.rideRequest.pickupLocation
                    : widget.rideRequest.dropoffLocation;
            final result = await DirectionsService().getDirections(
              origin: origin,
              destination: dest,
            );
            final speed = status == 'on_the_way' ? 40.0 : 30.0;
            final eta = (result.distanceMeters / 1000 / (speed / 60)).ceil();
            setState(() => _etaMinutes = eta);
            _updatePolyline([origin, dest]);

            if (status == 'completed') {
              Navigator.pushReplacementNamed(
                context,
                PaymentScreen.routeName,
                arguments: {
                  'rideId': widget.rideRequest.id,
                  'amount': widget.rideRequest.fare,
                },
              );
            }
          }
        });
  }

  void _updatePolyline(List<LatLng> pts) {
    _polylines
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: pts,
          width: 5,
          color: Colors.green.shade800,
        ),
      );
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
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: sw, zoom: 12),
              markers: _markers,
              polylines: _polylines,
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
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _status == 'on_the_way'
                        ? 'En camino hacia ti'
                        : _status == 'in_progress'
                        ? 'Viaje en curso'
                        : 'Estado: $_status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_etaMinutes != null)
                    Text(
                      'ETA: $_etaMinutes min',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
