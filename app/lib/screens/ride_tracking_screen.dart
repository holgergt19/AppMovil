import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import '../models/ride_request.dart';

class RideTrackingScreen extends StatelessWidget {
  static const routeName = '/ride-tracking';
  const RideTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rideVm = context.watch<RideViewModel>();
    final stream = rideVm.rideStream();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF008000),
        title: const Text('En ruta al destino'),
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
                  if (!snap.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final req = snap.data!;

                  final driverPos = LatLng(req.driverLat!, req.driverLng!);
                  final destPos = LatLng(req.destLat, req.destLng);

                  final dist = rideVm.calculateDistance(driverPos, destPos);
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
                              markerId: const MarkerId('dest'),
                              position: destPos,
                            ),
                          },
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId('route'),
                              color: Colors.green,
                              width: 6,
                              points: rideVm.polylinePoints,
                            ),
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Te faltan $km km para llegar',
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
