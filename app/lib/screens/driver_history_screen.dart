import 'package:flutter/material.dart';

class DriverHistoryScreen extends StatelessWidget {
  static const routeName = '/driver-history';
  const DriverHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: obtener lista de viajes completados y comisiones
    return Scaffold(
      appBar: AppBar(title: const Text('Historial y Ganancias')),
      body: const Center(child: Text('Listado de viajes completados')),
    );
  }
}
