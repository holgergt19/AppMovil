import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import '../models/ride_request.dart';

class RideRequestScreen extends StatelessWidget {
  // Defínelo directamente como string para evitar problemas de const inicialization
  static const String routeName = '/ride-request';

  const RideRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RideViewModel>();
    const userId = 'user-id-ejemplo'; // TODO: reemplaza por el UID real

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de Viaje')),
      body: StreamBuilder<List<RideRequest>>(
        stream: vm.rideStream(userId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('No hay solicitudes activas.'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final r = list[i];
              return ListTile(
                title: Text('Origen: ${r.pickupAddress}'),
                subtitle: Text('Destino: ${r.dropoffAddress}'),
              );
            },
          );
        },
      ),
    );
  }
}
