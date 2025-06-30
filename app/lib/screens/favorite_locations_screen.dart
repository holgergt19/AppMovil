import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/ride_view_model.dart';
import '../models/favorite_location.dart';
import 'plan_trip_screen.dart';

class FavoriteLocationsScreen extends StatefulWidget {
  static const routeName = '/favorites';
  const FavoriteLocationsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteLocationsScreen> createState() =>
      _FavoriteLocationsScreenState();
}

class _FavoriteLocationsScreenState extends State<FavoriteLocationsScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthViewModel>().user!.uid;
    context.read<FavoritesViewModel>().loadFavorites(uid);
  }

  @override
  Widget build(BuildContext context) {
    final favVm = context.watch<FavoritesViewModel>();
    final uid = context.read<AuthViewModel>().user!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: ListView.builder(
        itemCount: favVm.favorites.length,
        itemBuilder: (_, i) {
          final fav = favVm.favorites[i];
          return ListTile(
            title: Text(fav.label),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PlanTripScreen()),
              ).then((_) {
                context.read<RideViewModel>().setDestination(fav.location);
              });
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => favVm.removeFavorite(uid, fav.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final rideVm = context.read<RideViewModel>();
          final dest = rideVm.destination;
          if (dest == null) return;

          String label = '';
          await showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('Etiqueta'),
                  content: TextField(
                    onChanged: (v) => label = v,
                    decoration: const InputDecoration(
                      hintText: 'Casa, Trabajo...',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          );
          if (label.isNotEmpty) {
            await favVm.addFavorite(uid, label, dest);
          }
        },
        label: const Text('Agregar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
