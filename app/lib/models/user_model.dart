import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String role; // 'user' o 'driver'
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    this.role = 'user',
    this.photoUrl,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String uid,
    String email,
  ) {
    return UserModel(
      uid: uid,
      email: email,
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
