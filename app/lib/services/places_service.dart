import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesService {
  static const _apiKey = 'AIzaSyBT7hduil6J4mWt_S0bYYa8f7YrkVWSqI4';
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: _apiKey);

  /// Muestra el autocomplete y devuelve la predicción seleccionada
  Future<Prediction?> showAutocomplete(BuildContext context) {
    return PlacesAutocomplete.show(
      context: context,
      apiKey: _apiKey,
      mode: Mode.overlay, // o fullscreen
      language: 'es',
      components: [Component(Component.country, 'ec')],
      hint: 'Buscar ubicación',
    );
  }

  /// Convierte placeId a LatLng
  Future<LatLng?> getLocationFromPlaceId(String placeId) async {
    final detail = await _places.getDetailsByPlaceId(placeId);
    if (detail.status == 'OK' && detail.result.geometry != null) {
      final loc = detail.result.geometry!.location;
      return LatLng(loc.lat, loc.lng);
    }
    return null;
  }
}
