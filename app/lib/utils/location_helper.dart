import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHelper {
  static Future<LatLng> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
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
