import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _db = FirestoreService();

  User? user;
  Map<String, dynamic>? profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Registra un nuevo usuario
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = cred.user;
    await _db.createUserProfile(
      uid: user!.uid,
      name: name,
      phone: phone,
      photoUrl: photoUrl ?? '',
    );
    await loadUserProfile();
    _isLoading = false;
    notifyListeners();
  }

  /// Hace login (antes lo llamabas login)
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = cred.user;
    await loadUserProfile();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    if (user == null) return;
    final snap = await _db.getUserProfile(user!.uid);
    profile = snap.data();
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    if (user == null) return;
    await _db.updateUserProfile(
      uid: user!.uid,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
    );
    await loadUserProfile();
  }

  /// Cierra sesión
  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    profile = null;
    notifyListeners();
  }
}
