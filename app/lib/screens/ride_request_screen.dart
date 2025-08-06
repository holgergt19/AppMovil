import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../models/ride_request.dart';
import 'waiting_for_driver_screen.dart';

class RideRequestScreen extends StatelessWidget {
  static const String routeName = '/ride-request';
  const RideRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RideViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final userId = authVm.user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Actividades')),
      body:
          userId == null
              ? const Center(child: Text('No autenticado'))
              : StreamBuilder<List<RideRequest>>(
                stream: vm.rideStream(userId),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('No tienes actividades por ahora.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final r = list[i];
                      IconData icon;
                      Color bg;
                      switch (r.status) {
                        case 'pending':
                          icon = Icons.access_time;
                          bg = Colors.orange.shade100;
                          break;
                        case 'accepted':
                          icon = Icons.check_circle_outline;
                          bg = Colors.blue.shade100;
                          break;
                        case 'on_the_way':
                          icon = Icons.directions_car;
                          bg = Colors.green.shade100;
                          break;
                        case 'in_progress':
                          icon = Icons.drive_eta;
                          bg = Colors.green.shade200;
                          break;
                        case 'completed':
                          icon = Icons.done_all;
                          bg = Colors.grey.shade300;
                          break;
                        case 'cancelled':
                          icon = Icons.cancel;
                          bg = Colors.red.shade100;
                          break;
                        default:
                          icon = Icons.info;
                          bg = Colors.white;
                      }
                      return Container(
                        color: bg,
                        child: ListTile(
                          leading: Icon(icon),
                          title: Text(
                            '${r.pickupAddress} → ${r.dropoffAddress}',
                          ),
                          subtitle: Text('Estado: ${r.status}'),
                          onTap: () {
                            if (r.status == 'pending') {
                              Navigator.pushNamed(
                                context,
                                WaitingForDriverScreen.routeName,
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
