import 'package:flutter/material.dart';

class PaymentButton extends StatelessWidget {
  final String method; // 'cash' o 'card'
  final VoidCallback onPressed;

  const PaymentButton({Key? key, required this.method, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = method == 'card' ? Icons.credit_card : Icons.money;
    final label = method == 'card' ? 'Tarjeta' : 'Efectivo';

    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
