import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/favorite_location.dart';
import '../services/favorites_service.dart';

class FavoritesViewModel extends ChangeNotifier {
  final _svc = FavoritesService();
  List<FavoriteLocation> favorites = [];
  StreamSubscription? _sub;

  void loadFavorites(String uid) {
    _sub?.cancel();
    _sub = _svc.favoritesStream(uid).listen((list) {
      favorites = list;
      notifyListeners();
    });
  }

  Future<void> addFavorite(String uid, String label, LatLng loc) {
    return _svc.addFavorite(uid, label, loc);
  }

  Future<void> removeFavorite(String uid, String favId) {
    return _svc.removeFavorite(uid, favId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
