import 'package:flutter/material.dart';
import '../widget/location_input.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF008000),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car, size: 24),
            SizedBox(width: 8),
            Text('Viajes'),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LocationInput(
              // ahora usamos "label" en lugar de "hint" o "controller"
              label: 'Ingresa el destino',
              onSelect: () {
                Navigator.pushNamed(context, '/plan-trip');
              },
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.map_outlined, color: Colors.white70),
            title: const Text(
              'Establecer ubicación en el mapa',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () => Navigator.pushNamed(context, '/plan-trip'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.red),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: Colors.white54),
            label: 'Cuenta',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
