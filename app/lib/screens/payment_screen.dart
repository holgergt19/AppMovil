import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/payment_view_model.dart';
import '../view_models/auth_view_model.dart';

class PaymentScreen extends StatelessWidget {
  static const routeName = '/payment';
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final payVm = context.watch<PaymentViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final rideId = args?['rideId'] as String?;
    final amount = args?['amount'] as double? ?? 0.0;
    final userId = authVm.user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Pagar viaje')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            userId == null || rideId == null
                ? const Center(child: Text('Datos incompletos'))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total a pagar: \$${amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon:
                          payVm.isProcessing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.payment),
                      label: Text(
                        payVm.isProcessing ? 'Procesando...' : 'Pagar ahora',
                      ),
                      onPressed:
                          payVm.isProcessing
                              ? null
                              : () {
                                payVm.pay(
                                  rideId: rideId,
                                  userId: userId,
                                  method: 'Efectivo',
                                  amount: amount,
                                  onSuccess: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Pago exitoso'),
                                      ),
                                    );
                                    Navigator.popUntil(
                                      context,
                                      ModalRoute.withName('/home'),
                                    );
                                  },
                                  onError: (msg) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $msg')),
                                    );
                                  },
                                );
                              },
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
