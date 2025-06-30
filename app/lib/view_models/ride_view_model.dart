import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/directions_service.dart';
import '../services/firestore_service.dart';

class RideViewModel extends ChangeNotifier {
  final DirectionsService _directionsService = DirectionsService();
  final FirestoreService _db = FirestoreService();

  LatLng? _origin;
  LatLng? get origin => _origin;

  LatLng? _destination;
  LatLng? get destination => _destination;

  List<LatLng> _polylinePoints = [];
  List<LatLng> get polylinePoints => _polylinePoints;

  double? _distanceMeters;
  double? get distanceMeters => _distanceMeters;

  double? _fare;
  double? get fare => _fare;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Inicializa el origen (p. ej. posición actual)
  void setOrigin(LatLng origin) {
    _origin = origin;
    notifyListeners();
  }

  /// Usuario selecciona destino, calcula ruta automáticamente
  Future<void> setDestination(LatLng dest) async {
    _destination = dest;
    _isLoading = true;
    notifyListeners();

    await _computeRoute();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _computeRoute() async {
    if (_origin == null || _destination == null) return;

    final result = await _directionsService.getDirections(
      origin: _origin!,
      destination: _destination!,
    );

    _polylinePoints = result.points;
    _distanceMeters = result.distanceMeters;

    // Tarifa base + $1 por km
    final km = (_distanceMeters! / 1000.0);
    _fare = 1.5 + km * 1.0;
  }

  /// Crea la solicitud de viaje en Firestore
  Future<void> requestRide({required String userId}) async {
    if (_origin == null || _destination == null || _fare == null) return;

    await _db.createRideRequest(
      userId: userId,
      origin: _origin!,
      destination: _destination!,
      distanceMeters: _distanceMeters!,
      fare: _fare!,
    );
  }
}
