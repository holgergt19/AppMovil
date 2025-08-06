import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../view_models/ride_view_model.dart';
import '../screens/ride_options_screen.dart';
import '../screens/favorite_locations_screen.dart';
import '../screens/waiting_for_driver_screen.dart';
import '../utils/location_helper.dart';
import '../services/directions_service.dart';
import '../services/places_service.dart';

class PlanTripScreen extends StatefulWidget {
  static const String routeName = '/plan-trip';
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final PlacesService _placesService = PlacesService();

  LatLng? _origin;
  LatLng? _destination;
  final Set<Polyline> _polylines = {};

  late bool selectPickup;
  bool _isInitialized = false;

  /// BitmapDescriptor cargado y redimensionado.
  BitmapDescriptor? _blackPin;

  @override
  void initState() {
    super.initState();
    _loadAndResizeMarker();
  }

  /// Carga el asset PNG y lo escala a [targetWidth] píxeles de ancho.
  Future<Uint8List> _getBytesFromAsset(String path, int targetWidth) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetWidth,
    );
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  /// Invocada en initState: carga y redimensiona el pin.
  Future<void> _loadAndResizeMarker() async {
    const int markerWidth = 40; // <— prueba 32, 24, 16, etc hasta que te guste
    final bytes = await _getBytesFromAsset(
      'assets/images/marker_black.png',
      markerWidth,
    );
    setState(() {
      _blackPin = BitmapDescriptor.fromBytes(bytes);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final arg = ModalRoute.of(context)!.settings.arguments;
      selectPickup = arg is bool && arg;
      // Centrar en ubicación actual siempre
      _setInitialLocation();
      if (selectPickup) {
        final vm = context.read<RideViewModel>();
        _destination = vm.destination;
      }
    }
  }

  Future<void> _setInitialLocation() async {
    try {
      final loc = await LocationHelper.getCurrentLocation();
      setState(() => _origin = loc);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  Future<void> _onPointSelected(LatLng loc) async {
    setState(() {
      if (selectPickup) {
        _origin = loc;
      } else {
        _destination = loc;
      }
      _polylines.clear();
    });
    if (!selectPickup && _origin != null && _destination != null) {
      await _drawRoute();
    }
  }

  Future<void> _drawRoute() async {
    if (_origin == null || _destination == null) return;
    final result = await DirectionsService().getDirections(
      origin: _origin!,
      destination: _destination!,
    );
    final poly = Polyline(
      polylineId: const PolylineId('route'),
      points: result.points,
      width: 5,
      color: Colors.blue,
    );
    final ctrl = await _mapController.future;
    // Ajustar cámara para encuadrar ruta
    final bounds = LatLngBounds(
      southwest: LatLng(
        _origin!.latitude < _destination!.latitude
            ? _origin!.latitude
            : _destination!.latitude,
        _origin!.longitude < _destination!.longitude
            ? _origin!.longitude
            : _destination!.longitude,
      ),
      northeast: LatLng(
        _origin!.latitude > _destination!.latitude
            ? _origin!.latitude
            : _destination!.latitude,
        _origin!.longitude > _destination!.longitude
            ? _origin!.longitude
            : _destination!.longitude,
      ),
    );
    ctrl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    setState(() => _polylines.add(poly));
  }

  Future<void> _onContinue() async {
    final vm = context.read<RideViewModel>();
    if (selectPickup) {
      await vm.requestRideSilent();
      Navigator.pushReplacementNamed(context, WaitingForDriverScreen.routeName);
    } else {
      if (_origin != null && _destination != null) {
        await vm.setTripLocations(origin: _origin!, destination: _destination!);
        Navigator.pushNamed(context, RideOptionsScreen.routeName);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona un destino')));
      }
    }
  }

  Future<void> _onSearchTap() async {
    final p = await _placesService.showAutocomplete(context);
    if (p != null) {
      final loc = await _placesService.getLocationFromPlaceId(p.placeId!);
      if (loc != null) _onPointSelected(loc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{};
    if (_origin != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: _origin!,
          icon: _blackPin ?? BitmapDescriptor.defaultMarker,
        ),
      );
    }
    if (_destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination!,
          icon: _blackPin ?? BitmapDescriptor.defaultMarker,
        ),
      );
    }

    final promptText =
        selectPickup ? 'Fija el punto de partida' : '¿A dónde vas?';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectPickup ? 'Selecciona tu punto de partida' : 'Planificar viaje',
        ),
      ),
      body: Column(
        children: [
          // Input + buscador + favoritos
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: selectPickup ? null : _onSearchTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Text(
                        selectPickup
                            ? promptText
                            : (_destination != null
                                ? '${_destination!.latitude.toStringAsFixed(5)}, '
                                    '${_destination!.longitude.toStringAsFixed(5)}'
                                : promptText),
                        style: TextStyle(
                          color:
                              selectPickup
                                  ? Colors.white54
                                  : _destination != null
                                  ? Colors.white
                                  : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!selectPickup) ...[
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: _onSearchTap,
                    child: const Icon(Icons.search),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FavoriteLocationsScreen(
                                onLocationSelected: _onPointSelected,
                              ),
                        ),
                      );
                    },
                    child: const Icon(Icons.star),
                  ),
                ],
              ],
            ),
          ),

          // Mapa
          Expanded(
            flex: 5,
            child:
                (_origin == null)
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _origin!,
                        zoom: 14,
                      ),
                      markers: markers,
                      polylines: _polylines,
                      onTap: _onPointSelected,
                    ),
          ),

          // Botón continuar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _onContinue,
              icon: Icon(
                selectPickup ? Icons.check_circle : Icons.arrow_forward,
              ),
              label: Text(selectPickup ? 'Confirmar punto' : 'Continuar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor:
                    selectPickup
                        ? Theme.of(context).colorScheme.primary
                        : Colors.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
