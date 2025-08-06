import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHelper {
  /// Pide permisos y devuelve la ubicación actual como LatLng
  static Future<LatLng> getCurrentLocation() async {
    // 1. Comprueba que el servicio de ubicación esté activo
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Activa el servicio de ubicación en ajustes.');
    }

    // 2. Comprueba permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permiso de ubicación denegado permanentemente.\n'
        'Ve a Ajustes y actívalo manualmente.',
      );
    }

    // 3. Ya tenemos permiso: obtenemos la posición
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  static Future<LatLng?> searchLocation(String address) async {
    // Aquí podrías usar una API externa o un mock para la ubicación por nombre.
    // Por simplicidad, devolvemos null o un valor de prueba:
    if (address.toLowerCase() == 'centro') {
      return const LatLng(-0.2299, -78.5249);
    }
    return null;
  }
}
