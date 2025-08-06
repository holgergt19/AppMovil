import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Asegúrate de tener url_launcher en pubspec.yaml
import 'package:url_launcher/url_launcher.dart';

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
        infoWindow: const InfoWindow(title: 'Origen'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.rideRequest.dropoffLocation,
        infoWindow: const InfoWindow(title: 'Destino'),
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
              _markers
                ..removeWhere((m) => m.markerId.value == 'driver')
                ..add(
                  Marker(
                    markerId: const MarkerId('driver'),
                    position: pos,
                    infoWindow: const InfoWindow(title: 'Tu ubicación'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
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

  /// Lanza navegación en Google Maps
  Future<void> _openNavigation() async {
    final lat = widget.rideRequest.destinationLat;
    final lng = widget.rideRequest.destinationLng;
    final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la navegación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaje Activo'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('ride_requests')
                  .doc(widget.rideRequest.id)
                  .update({'status': 'cancelled'});
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.rideRequest.pickupLocation,
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (c) => _mapController = c,
          ),
          Positioned(
            bottom: 20,
            right: 16,
            child: FloatingActionButton(
              onPressed: _openNavigation,
              child: const Icon(Icons.navigation),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: abrir chat con usuario
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
