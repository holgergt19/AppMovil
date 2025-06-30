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
}
