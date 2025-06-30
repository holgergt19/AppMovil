import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ride_request.dart';
import '../view_models/driver_view_model.dart';
import 'driver_active_trip_screen.dart';

class DriverTripDetailScreen extends StatelessWidget {
  static const routeName = '/driver-trip-detail';
  const DriverTripDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final r = ModalRoute.of(context)!.settings.arguments as RideRequest;
    final vm = context.read<DriverViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del viaje')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Origen: ${r.origin.latitude}, ${r.origin.longitude}'),
            Text(
              'Destino: ${r.destination.latitude}, ${r.destination.longitude}',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await vm.startTrip(r.id);
                Navigator.pushReplacementNamed(
                  context,
                  DriverActiveTripScreen.routeName,
                  arguments: r,
                );
              },
              child: const Text('Iniciar viaje'),
            ),
          ],
        ),
      ),
    );
  }
}
