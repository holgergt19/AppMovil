import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavoriteLocation {
  final String id;
  final String label; // e.g. 'Casa', 'Trabajo'
  final LatLng location;

  FavoriteLocation({
    required this.id,
    required this.label,
    required this.location,
  });
}
