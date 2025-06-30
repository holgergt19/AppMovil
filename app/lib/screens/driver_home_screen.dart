import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_models/driver_view_model.dart';
import '../models/ride_request.dart';
import 'driver_trip_detail_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  static const routeName = '/driver-home';
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    context.read<DriverViewModel>().loadStatus(_uid);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DriverViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
        actions: [
          Row(
            children: [
              Text(vm.isAvailable ? 'Disponible' : 'Ocupado'),
              Switch(
                value: vm.isAvailable,
                onChanged: (v) => vm.toggleAvailable(_uid, v),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<RideRequest>>(
        stream: vm.pendingRequests,
        builder: (_, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty)
            return const Center(child: Text('No hay solicitudes'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final r = list[i];
              return ListTile(
                title: Text('Usuario: ${r.userId}'),
                subtitle: Text('Status: ${r.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => vm.acceptRide(r.id, _uid),
                      child: const Text('Aceptar'),
                    ),
                    TextButton(
                      onPressed: () {}, // Rechazar si lo implementas
                      child: const Text('Rechazar'),
                    ),
                  ],
                ),
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      DriverTripDetailScreen.routeName,
                      arguments: r,
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
