import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../view_models/ride_view_model.dart';

class PlanTripScreen extends StatelessWidget {
  static const routeName = '/plan-trip';
  const PlanTripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rideVm = context.watch<RideViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Planifica tu viaje')),
      body: Column(
        children: [
          // Encabezado con origen y campo "¿A dónde vas?"
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rideVm.origin != null)
                      Text(
                        'Origen: ${rideVm.origin!.latitude.toStringAsFixed(5)}, '
                        '${rideVm.origin!.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 8),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText:
                            rideVm.destination == null
                                ? '¿A dónde vas?'
                                : 'Destino: '
                                    '${rideVm.destination!.latitude.toStringAsFixed(5)}, '
                                    '${rideVm.destination!.longitude.toStringAsFixed(5)}',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[850],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/destination-entry');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Acción rápida: toca para ubicar en mapa
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Establecer destino en el mapa'),
            onTap: () async {
              final LatLng? dest = await Navigator.pushNamed<LatLng>(
                context,
                '/select-on-map',
              );
              if (dest != null) {
                await rideVm.setDestination(dest);
              }
            },
          ),

          // Mapa (45% de la pantalla)
          Expanded(
            flex: 45,
            child:
                rideVm.origin == null || rideVm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: rideVm.origin!,
                        zoom: 14,
                      ),
                      myLocationEnabled: true,
                      markers: {
                        Marker(
                          markerId: const MarkerId('origin'),
                          position: rideVm.origin!,
                        ),
                        if (rideVm.destination != null)
                          Marker(
                            markerId: const MarkerId('dest'),
                            position: rideVm.destination!,
                          ),
                      },
                      polylines: {
                        if (rideVm.polylinePoints.isNotEmpty)
                          Polyline(
                            polylineId: const PolylineId('route'),
                            points: rideVm.polylinePoints,
                            width: 5,
                          ),
                      },
                    ),
          ),

          // Botón Continuar ($XX.XX)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: Text(
                rideVm.fare != null
                    ? 'Continuar (\$${rideVm.fare!.toStringAsFixed(2)})'
                    : 'Continuar',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: rideVm.fare != null ? Colors.red : Colors.grey,
              ),
              onPressed:
                  rideVm.fare == null
                      ? null
                      : () {
                        Navigator.pushNamed(context, '/choose-ride');
                      },
            ),
          ),
        ],
      ),
    );
  }
}
