import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import '../view_models/auth_view_model.dart';

class RideOptionsScreen extends StatelessWidget {
  static const routeName = '/ride-options';
  const RideOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rideVm = context.watch<RideViewModel>();
    final authVm = context.read<AuthViewModel>();
    final fare = rideVm.estimatedFare ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF008000),
        title: const Text('Elige tu viaje'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.local_taxi, color: Colors.white),
                title: const Text(
                  'Taxi Estándar',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '\$${fare.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Selector Efectivo / Tarjeta
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        rideVm.paymentMethod == 'cash'
                            ? Colors.green
                            : Colors.grey[800],
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => rideVm.paymentMethod = 'cash',
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Efectivo'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => rideVm.paymentMethod = 'card',
                  child: const Text(
                    'Tarjeta',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Botón Continuar
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: const StadiumBorder(),
              ),
              onPressed:
                  rideVm.isLoading
                      ? null
                      : () async {
                        await rideVm.requestRide(userId: authVm.user!.uid);
                        Navigator.pushNamed(context, '/ride-request');
                      },
              icon: const Icon(Icons.check),
              label: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
