import 'package:flutter/material.dart';

class MapMarkerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const MapMarkerButton({Key? key, required this.icon, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
