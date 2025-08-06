import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/ride_request.dart';
import '../view_models/driver_view_model.dart';

class DriverTripDetailScreen extends StatefulWidget {
  static const String routeName = DriverViewModel.driverTripDetailRoute;
  final RideRequest rideRequest;

  const DriverTripDetailScreen({Key? key, required this.rideRequest})
    : super(key: key);

  @override
  _DriverTripDetailScreenState createState() => _DriverTripDetailScreenState();
}

class _DriverTripDetailScreenState extends State<DriverTripDetailScreen> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _rideStream;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _rideStream =
        FirebaseFirestore.instance
            .collection('ride_requests')
            .doc(widget.rideRequest.id)
            .snapshots();

    _markers.addAll({
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.rideRequest.pickupLocation,
        infoWindow: const InfoWindow(title: 'Origen'),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: widget.rideRequest.dropoffLocation,
        infoWindow: const InfoWindow(title: 'Destino'),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DriverViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Viaje')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _rideStream,
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snap.data!.data()!;
          final status = data['status'] as String;
          final pinCode = data['pinCode'] as String?;
          final gp = data['driverLocation'] as GeoPoint?;
          final driverPos =
              gp != null ? LatLng(gp.latitude, gp.longitude) : null;

          if (status == 'cancelled') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.pop(context);
            });
            return const SizedBox.shrink();
          }

          if (driverPos != null) {
            _markers
              ..removeWhere((m) => m.markerId.value == 'driver')
              ..add(
                Marker(
                  markerId: const MarkerId('driver'),
                  position: driverPos,
                  infoWindow: const InfoWindow(title: 'Tu ubicación'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
              );
          }

          return Column(
            children: [
              // ── Mostrar PIN tras aceptar ───────────────────────────
              if (status == 'accepted' && pinCode != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Card(
                    color: Colors.yellow.shade100,
                    child: ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('PIN de recogida'),
                      subtitle: Text(
                        pinCode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Tarjeta con precio y chat ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    leading: Text(
                      '\$${widget.rideRequest.fare.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: const Text('Precio estimado'),
                    subtitle:
                        driverPos != null
                            ? const Text('Ver mapa para ETA y distancia')
                            : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {
                        // TODO: implementar chat conductor ↔ usuario
                      },
                    ),
                  ),
                ),
              ),

              // ── Mapa con ruta ────────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: GoogleMap(
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  initialCameraPosition: CameraPosition(
                    target: widget.rideRequest.pickupLocation,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: [
                        widget.rideRequest.pickupLocation,
                        if (driverPos != null) driverPos,
                        widget.rideRequest.dropoffLocation,
                      ],
                      width: 5,
                      color: Colors.green.shade800,
                    ),
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ── Botón de acción según estado ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildActionButton(vm, status),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(DriverViewModel vm, String status) {
    switch (status) {
      case 'pending':
        return ElevatedButton(
          onPressed: () => vm.acceptRide(widget.rideRequest.id),
          child: const Text('Aceptar viaje'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        );
      case 'accepted':
        return ElevatedButton(
          onPressed: () => vm.markInProgress(widget.rideRequest.id),
          child: const Text('Marcar llegada'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        );
      case 'in_progress':
        return ElevatedButton(
          onPressed: () => vm.startOnTheWay(widget.rideRequest.id),
          child: const Text('Iniciar viaje'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        );
      case 'on_the_way':
        return ElevatedButton(
          onPressed: () => vm.completeTrip(widget.rideRequest.id),
          child: const Text('Completar viaje'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Colors.green,
          ),
        );
      default:
        return Text('Estado: $status', textAlign: TextAlign.center);
    }
  }
}
