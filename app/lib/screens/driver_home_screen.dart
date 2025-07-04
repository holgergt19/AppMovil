import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/driver_view_model.dart';
import '../models/ride_request.dart';
import '../widget/bottom_nav_bar.dart';
import 'profile_screen.dart'; // ahora exporta solo el contenido

class DriverHomeScreen extends StatefulWidget {
  static const String routeName = DriverViewModel.driverHomeRoute;

  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DriverViewModel>().fetchAvailableRides();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DriverViewModel>();
    final rides = vm.availableRides;

    // Vistas de cada pestaña
    final pages = [
      // Inicio
      rides.isEmpty
          ? const Center(child: Text('No hay viajes disponibles'))
          : ListView.builder(
            itemCount: rides.length,
            itemBuilder: (_, i) {
              final r = rides[i];
              return ListTile(
                title: Text('Destino: ${r.destinationName}'),
                subtitle: Text('Usuario: ${r.userName}'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DriverViewModel.driverTripDetailRoute,
                    arguments: r,
                  );
                },
              );
            },
          ),

      // Perfil conductor (sin Scaffold)
      const ProfileContent(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Inicio Conductor' : 'Mi Perfil'),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
      ),
    );
  }
}
