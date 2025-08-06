import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import 'plan_trip_screen.dart';

class RideOptionsScreen extends StatelessWidget {
  static const String routeName = '/ride-options';
  const RideOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RideViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Opciones del Viaje')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precio estimado: \$${vm.estimatedFare.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Empresa (25 %): \$${vm.companyShare.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Conductor (75 %): \$${vm.driverShare.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            DropdownButton<String>(
              value: vm.paymentMethod,
              items: const [
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
              ],
              onChanged: (value) {
                if (value != null) vm.paymentMethod = value;
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // En lugar de pedir el viaje aquí, vamos a seleccionar pickup
                Navigator.pushNamed(
                  context,
                  PlanTripScreen.routeName,
                  arguments:
                      true, // true = pantalla de selección de punto de partida
                );
              },
              child: const Text('Confirmar viaje'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
