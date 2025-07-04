import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';

/// Este widget es **solo** el contenido de perfil, sin Scaffold.
/// Lo reutilizamos dentro de DriverHomeScreen y también podemos
/// seguir usándolo como pantalla independiente si queremos:
class ProfileContent extends StatelessWidget {
  const ProfileContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final profile = authVm.profile ?? {};

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nombre: ${profile['name'] ?? ''}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Teléfono: ${profile['phone'] ?? ''}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Email: ${authVm.user?.email ?? ''}',
            style: const TextStyle(fontSize: 18),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await authVm.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Si todavía quieres ruta independiente para perfil:
class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const ProfileContent(),
    );
  }
}
