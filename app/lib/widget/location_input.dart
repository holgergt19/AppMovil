import 'package:flutter/material.dart';

class LocationInput extends StatelessWidget {
  /// Texto que se muestra como hint dentro del campo
  final String label;

  /// Callback que se ejecuta al tocar el campo
  final VoidCallback onSelect;

  const LocationInput({Key? key, required this.label, required this.onSelect})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white54),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
