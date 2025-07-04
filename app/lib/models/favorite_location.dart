import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavoriteLocation {
  final String id;
  final String label;
  final LatLng location;

  FavoriteLocation({
    required this.id,
    required this.label,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
  }

  factory FavoriteLocation.fromMap(Map<String, dynamic> map) {
    return FavoriteLocation(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      location: LatLng(
        map['latitude']?.toDouble() ?? 0.0,
        map['longitude']?.toDouble() ?? 0.0,
      ),
    );
  }
}
