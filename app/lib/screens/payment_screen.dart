import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/payment_view_model.dart';
import '../view_models/auth_view_model.dart';

class PaymentScreen extends StatelessWidget {
  static const routeName = '/payments';
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final payVm = context.watch<PaymentViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final userId = authVm.user!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Ganancias')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Tus ganancias'),
                trailing: Text(
                  '\$${payVm.driverEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Ganancia empresa'),
                trailing: Text(
                  '\$${payVm.companyEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // ejemplo de recálculo o fetch de ganancias
                // payVm.fetchEarnings(userId);
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
