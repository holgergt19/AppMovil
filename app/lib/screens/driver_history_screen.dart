import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/ride_request.dart';

class DriverHistoryScreen extends StatelessWidget {
  static const routeName = '/driver-history';
  const DriverHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Historial y Ganancias')),
        body: const Center(child: Text('No autenticado')),
      );
    }

    final stream =
        FirebaseFirestore.instance
            .collection('ride_requests')
            .where('driverId', isEqualTo: driverId)
            .where('status', isEqualTo: 'completed')
            .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial y Ganancias')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          final total = docs.fold<double>(
            0.0,
            (sum, d) => sum + (d.data()['fare'] as num).toDouble() * 0.75,
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ganancias Totales: \$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child:
                    docs.isEmpty
                        ? const Center(
                          child: Text('Aún no tienes viajes completados.'),
                        )
                        : ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (_, i) {
                            final data = docs[i].data();
                            final ride = RideRequest.fromMap(data, docs[i].id);
                            return ListTile(
                              leading: const Icon(Icons.directions_car),
                              title: Text(
                                '${ride.pickupAddress} → ${ride.dropoffAddress}',
                              ),
                              subtitle: Text(
                                'Importe: \$${ride.fare.toStringAsFixed(2)}',
                              ),
                              onTap: () {
                                // TODO: mostrar detalle o recibo
                              },
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
