import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../view_models/driver_view_model.dart';
import '../models/ride_request.dart';
import '../widget/bottom_nav_bar.dart';
import 'profile_screen.dart';
import '../services/directions_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});
  static const String routeName = DriverViewModel.driverHomeRoute;

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  final Set<String> _shownRequests = {};

  @override
  void initState() {
    super.initState();
    context.read<DriverViewModel>().addListener(_onRidesUpdated);
  }

  @override
  void dispose() {
    context.read<DriverViewModel>().removeListener(_onRidesUpdated);
    super.dispose();
  }

  void _onRidesUpdated() {
    final vm = context.read<DriverViewModel>();
    for (var r in vm.availableRides) {
      if (!_shownRequests.contains(r.id)) {
        _shownRequests.add(r.id);
        _showRideNotification(r);
      }
    }
  }

  Future<void> _showRideNotification(RideRequest r) async {
    Position driverPos;
    try {
      driverPos = await Geolocator.getCurrentPosition();
    } catch (_) {
      // fallback a la ubicación de pickup
      driverPos = Position(
        latitude: r.pickupLat,
        longitude: r.pickupLng,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        headingAccuracy: 0.0,
        altitudeAccuracy: 0.0,
      );
    }

    final directions = await DirectionsService().getDirections(
      origin: LatLng(driverPos.latitude, driverPos.longitude),
      destination: r.pickupLocation,
    );
    final km = directions.distanceMeters / 1000.0;
    final eta = (km / (40 / 60)).ceil();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nuevo viaje disponible',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Origen: ${r.pickupAddress}'),
              Text('Destino: ${r.destinationName}'),
              const SizedBox(height: 8),
              Text('Precio estimado: \$${r.fare.toStringAsFixed(2)}'),
              Text('Distancia: ${km.toStringAsFixed(1)} km'),
              Text('ETA: $eta min'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<DriverViewModel>().rejectRide(r.id);
                    },
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await context.read<DriverViewModel>().acceptRide(r.id);
                      Navigator.pushNamed(
                        context,
                        DriverViewModel.driverTripDetailRoute,
                        arguments: r,
                      );
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DriverViewModel>();

    final onlineToggle = TextButton.icon(
      onPressed: vm.isOnline ? vm.goOffline : vm.goOnline,
      icon: Icon(
        vm.isOnline ? Icons.toggle_on : Icons.toggle_off,
        color: Colors.white,
      ),
      label: Text(
        vm.isOnline ? 'Detener' : 'Iniciar',
        style: const TextStyle(color: Colors.white),
      ),
    );

    Widget homeContent;
    if (!vm.isOnline) {
      homeContent = const Center(
        child: Text(
          'Estás desconectado\nPresiona Iniciar para recibir viajes',
          textAlign: TextAlign.center,
        ),
      );
    } else {
      homeContent = const Center(
        child: Text(
          'Esperando nuevas solicitudes…',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    final pages = [homeContent, const ProfileContent()];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_currentIndex == 0 ? 'Inicio Conductor' : 'Mi Perfil'),
        actions: _currentIndex == 0 ? [onlineToggle] : null,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
      ),
    );
  }
}
