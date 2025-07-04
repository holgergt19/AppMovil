import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// Estructura de respuesta mínima para direcciones
class DirectionsResult {
  final List<LatLng> points;
  final double distanceMeters;

  DirectionsResult({required this.points, required this.distanceMeters});
}

class DirectionsService {
  // Reemplaza con tu clave de API o preferiblemente usa variables de entorno
  static const _apiKey = 'AIzaSyBT7hduil6J4mWt_S0bYYa8f7YrkVWSqI4';

  /// Consulta la Directions API de Google
  Future<DirectionsResult> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al obtener direcciones: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final route = (data['routes'] as List).first as Map<String, dynamic>;
    final leg = (route['legs'] as List).first as Map<String, dynamic>;

    // Obtener distancia en metros
    final distanceMeters = (leg['distance']['value'] as num).toDouble();

    // Decodificar polyline
    final encodedPoints = route['overview_polyline']['points'] as String;
    final points = _decodePolyline(encodedPoints);

    return DirectionsResult(points: points, distanceMeters: distanceMeters);
  }

  // Decodifica el string polyline de Google en List<LatLng>
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return poly;
  }
}
