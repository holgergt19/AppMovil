import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/favorite_location.dart';

class FavoriteLocationsScreen extends StatelessWidget {
  static const String routeName = '/favoriteLocations';
  final void Function(LatLng) onLocationSelected;

  const FavoriteLocationsScreen({Key? key, required this.onLocationSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ejemplo estático; podrías cargar de tu ViewModel o un servicio
    final List<FavoriteLocation> locations = [
      FavoriteLocation(
        id: '1',
        label: 'Casa',
        location: const LatLng(-0.2299, -78.5249),
      ),
      FavoriteLocation(
        id: '2',
        label: 'Trabajo',
        location: const LatLng(-0.1807, -78.4678),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicaciones Favoritas')),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final loc = locations[index];
          return ListTile(
            title: Text(loc.label),
            subtitle: Text(
              '${loc.location.latitude}, ${loc.location.longitude}',
            ),
            onTap: () {
              onLocationSelected(loc.location);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
