import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/ride_request.dart';
import '../view_models/driver_view_model.dart';
import 'driver_history_screen.dart';
import '../widget/custom_map.dart';

class DriverActiveTripScreen extends StatelessWidget {
  static const routeName = '/driver-active';
  const DriverActiveTripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final r = ModalRoute.of(context)!.settings.arguments as RideRequest;
    final vm = context.read<DriverViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('En viaje')),
      body: CustomMap(
        initialPosition: LatLng(r.origin.latitude, r.origin.longitude),
        markers: {
          Marker(
            markerId: const MarkerId('origin'),
            position: LatLng(r.origin.latitude, r.origin.longitude),
          ),
          Marker(
            markerId: const MarkerId('dest'),
            position: LatLng(r.destination.latitude, r.destination.longitude),
          ),
        },
        polylines: {},
        onMapCreated: (_) {},
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: () async {
            await vm.finishTrip(r.id);
            Navigator.pushReplacementNamed(
              context,
              DriverHistoryScreen.routeName,
            );
          },
          child: const Text('Finalizar viaje'),
        ),
      ),
    );
  }
}
