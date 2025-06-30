import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import '../models/ride_request.dart';

class RideRequestScreen extends StatelessWidget {
  static const routeName = '/ride-request';
  const RideRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rideVm = context.watch<RideViewModel>();
    final stream = rideVm.rideStream();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF008000),
        title: const Text('Conductor en camino'),
      ),
      body:
          stream == null
              ? const Center(
                child: Text(
                  'No hay viaje activo',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : StreamBuilder<RideRequest>(
                stream: stream,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final req = snap.data!;
                  final driverPos = LatLng(req.driverLat!, req.driverLng!);
                  final originPos = LatLng(req.originLat, req.originLng);

                  final dist = rideVm.calculateDistance(driverPos, originPos);
                  final km = (dist / 1000).toStringAsFixed(2);

                  return Column(
                    children: [
                      Expanded(
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: driverPos,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('driver'),
                              position: driverPos,
                            ),
                            Marker(
                              markerId: const MarkerId('origin'),
                              position: originPos,
                            ),
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Conductor está a $km km de ti',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
    );
  }
}
