import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  static const routeName = '/ride-history';
  const RideHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: obtener lista desde Firestore
    final sample = [
      {'date': '2025-06-01', 'price': 7.5, 'status': 'completed'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de viajes')),
      body: ListView.builder(
        itemCount: sample.length,
        itemBuilder: (_, i) {
          final r = sample[i];
          return ListTile(
            leading: const Icon(Icons.directions_car),
            title: Text(r['date'] as String),
            subtitle: Text('\$${(r['price'] as double).toStringAsFixed(2)}'),
            trailing: Text(r['status'] as String),
            onTap: () {}, // detalles
          );
        },
      ),
    );
  }
}
