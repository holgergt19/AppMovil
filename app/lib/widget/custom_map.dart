import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMap extends StatelessWidget {
  final LatLng? initialPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(LatLng)? onTap;
  final String? mapStyle;

  const CustomMap({
    Key? key,
    this.initialPosition,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
    this.onTap,
    this.mapStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition ?? const LatLng(0, 0),
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: markers,
      polylines: polylines,
      onMapCreated: (ctrl) {
        if (mapStyle != null) ctrl.setMapStyle(mapStyle);
        onMapCreated(ctrl);
      },
      onTap: onTap,
    );
  }
}
