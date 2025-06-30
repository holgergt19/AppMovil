import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class HomeViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  LatLng? currentLocation;

  Future<void> initLocation() async {
    final granted = await _locationService.requestPermission();
    if (!granted) return;
    final pos = await _locationService.getCurrentLocation();
    currentLocation = LatLng(pos.latitude, pos.longitude);
    notifyListeners();
  }

  void centerMap(GoogleMapController controller) {
    if (currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 15),
      );
    }
  }
}
