import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../models/ride_request.dart';

class RideHistoryScreen extends StatelessWidget {
  static const String routeName = '/ride-history';
  const RideHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RideViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final userId = authVm.user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de viajes')),
      body:
          userId == null
              ? const Center(child: Text('No autenticado'))
              : StreamBuilder<List<RideRequest>>(
                stream: vm.rideStream(userId),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final completed =
                      (snap.data ?? [])
                          .where((r) => r.status == 'completed')
                          .toList();
                  if (completed.isEmpty) {
                    return const Center(
                      child: Text('No tienes viajes completados.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: completed.length,
                    itemBuilder: (_, i) {
                      final r = completed[i];
                      return ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text('${r.pickupAddress} → ${r.dropoffAddress}'),
                        subtitle: Text(
                          'Importe: \$${r.fare.toStringAsFixed(2)}',
                        ),
                        trailing: Text(r.status),
                        onTap: () {
                          // TODO: Detalle de viaje
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
