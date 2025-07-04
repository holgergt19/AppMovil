import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../view_models/ride_view_model.dart';
import '../screens/ride_options_screen.dart';
import '../screens/favorite_locations_screen.dart';
import '../utils/location_helper.dart';
import '../services/directions_service.dart'; // ← aquí

class PlanTripScreen extends StatefulWidget {
  static const String routeName = '/plan-trip';
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _destinationController = TextEditingController();

  LatLng? _origin;
  LatLng? _destination;
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    final loc = await LocationHelper.getCurrentLocation();
    setState(() => _origin = loc);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  Future<void> _onDestinationSelected(LatLng location) async {
    setState(() {
      _destination = location;
      _polylines.clear();
    });
    await _drawRoute();
  }

  Future<void> _drawRoute() async {
    if (_origin == null || _destination == null) return;

    final result = await DirectionsService().getDirections(
      origin: _origin!,
      destination: _destination!,
    );

    final poly = Polyline(
      polylineId: const PolylineId('route'),
      points: result.points,
      width: 5,
      color: Colors.blue,
    );
    final ctrl = await _mapController.future;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _origin!.latitude < _destination!.latitude
            ? _origin!.latitude
            : _destination!.latitude,
        _origin!.longitude < _destination!.longitude
            ? _origin!.longitude
            : _destination!.longitude,
      ),
      northeast: LatLng(
        _origin!.latitude > _destination!.latitude
            ? _origin!.latitude
            : _destination!.latitude,
        _origin!.longitude > _destination!.longitude
            ? _origin!.longitude
            : _destination!.longitude,
      ),
    );
    ctrl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    setState(() => _polylines.add(poly));
  }

  Future<void> _onContinue() async {
    if (_origin != null && _destination != null) {
      final rideVm = context.read<RideViewModel>();
      // calcula tarifa internamente
      await rideVm.setTripLocations(
        origin: _origin!,
        destination: _destination!,
      );
      Navigator.pushNamed(context, RideOptionsScreen.routeName);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un destino')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{};
    if (_origin != null) {
      markers.add(
        Marker(markerId: const MarkerId('origin'), position: _origin!),
      );
    }
    if (_destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination!,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Planificar viaje')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Ingresa destino o selecciona en el mapa',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => FavoriteLocationsScreen(
                              onLocationSelected: _onDestinationSelected,
                            ),
                      ),
                    );
                  },
                ),
              ),
              onSubmitted: (value) async {
                final loc = await LocationHelper.searchLocation(value);
                if (loc != null) _onDestinationSelected(loc);
              },
            ),
          ),
          Expanded(
            flex: 5,
            child:
                _origin == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      onMapCreated: _onMapCreated,
                      markers: markers,
                      polylines: _polylines, // ← aquí
                      onTap: _onDestinationSelected,
                      initialCameraPosition: CameraPosition(
                        target: _origin!,
                        zoom: 14,
                      ),
                    ),
          ),
          ElevatedButton.icon(
            onPressed: _onContinue,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuar'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.indigo,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
