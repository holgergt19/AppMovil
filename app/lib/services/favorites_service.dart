import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/favorite_location.dart';

class FavoritesService {
  final _db = FirebaseFirestore.instance;

  Future<void> addFavorite(String uid, String label, LatLng loc) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorite_locations')
        .add({
          'label': label,
          'lat': loc.latitude,
          'lng': loc.longitude,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> removeFavorite(String uid, String favId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorite_locations')
        .doc(favId)
        .delete();
  }

  Stream<List<FavoriteLocation>> favoritesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorite_locations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map(
                    (doc) => FavoriteLocation(
                      id: doc.id,
                      label: doc['label'],
                      location: LatLng(doc['lat'], doc['lng']),
                    ),
                  )
                  .toList(),
        );
  }
}
