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

  /// Registra un nuevo usuario (ahora con role)
  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role, // ← nuevo parámetro
    String? photoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = cred.user;

    // guardamos perfil con role
    await _db.createUserProfile(
      uid: user!.uid,
      name: name,
      phone: phone,
      photoUrl: photoUrl ?? '',
      role: role, // ← pasamos role
    );

    await loadUserProfile();
    _isLoading = false;
    notifyListeners();
  }

  /// Hace login y carga perfil
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

  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    profile = null;
    notifyListeners();
  }
}
