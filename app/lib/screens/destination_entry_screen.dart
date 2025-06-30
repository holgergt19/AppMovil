import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/auth_view_model.dart';
import 'plan_trip_screen.dart';

class DestinationEntryScreen extends StatefulWidget {
  static const routeName = '/destination-entry';
  const DestinationEntryScreen({Key? key}) : super(key: key);

  @override
  State<DestinationEntryScreen> createState() => _DestinationEntryScreenState();
}

class _DestinationEntryScreenState extends State<DestinationEntryScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthViewModel>().user!.uid;
    context.read<FavoritesViewModel>().loadFavorites(uid);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesViewModel>().favorites;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF008000),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car, size: 28),
            SizedBox(width: 8),
            Text('Viajes'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              readOnly: true,
              onTap:
                  () => Navigator.pushNamed(context, PlanTripScreen.routeName),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                hintText: 'Ingresa el destino',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF202020),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (favorites.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Ubicaciones guardadas',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...favorites.map(
                    (fav) => ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: Text(
                        fav.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          PlanTripScreen.routeName,
                          arguments: fav.location,
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24),
                ],
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.white70),
                  title: const Text(
                    'Establecer ubicación en el mapa',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, PlanTripScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
