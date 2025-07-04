import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/ride_request.dart';
import '../view_models/driver_view_model.dart';

class DriverTripDetailScreen extends StatelessWidget {
  static const String routeName = DriverViewModel.driverTripDetailRoute;
  final RideRequest rideRequest;

  DriverTripDetailScreen({Key? key, required this.rideRequest})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DriverViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Viaje')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: rideRequest.pickupLocation,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: rideRequest.pickupLocation,
                  infoWindow: const InfoWindow(title: 'Origen'),
                ),
                Marker(
                  markerId: const MarkerId('dropoff'),
                  position: rideRequest.dropoffLocation,
                  infoWindow: const InfoWindow(title: 'Destino'),
                ),
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await vm.acceptRide(rideRequest.id, 'driver-id-ejemplo');
              vm.startOnTheWay(rideRequest.id);
              Navigator.pushReplacementNamed(
                context,
                DriverViewModel.driverActiveTripRoute,
                arguments: rideRequest,
              );
            },
            child: const Text('Aceptar Viaje'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
