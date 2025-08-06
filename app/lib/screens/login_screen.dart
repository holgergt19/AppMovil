import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../view_models/auth_view_model.dart';
import '../widget/role_selector.dart';
import 'registration_screen.dart';
import 'user_home_screen.dart';
import 'driver_home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _selectedRole = 'user';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: SafeArea(
          child:
              authVm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        // ----------------------------
                        // Logo animado con pedestal
                        // ----------------------------
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // pedestal circular semitransparente
                            Container(
                              width: size.width * 0.35,
                              height: size.width * 0.35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.08),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            // animación Lottie
                            Lottie.asset(
                              'assets/animations/home.json',
                              height: size.height * 0.15,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ----------------------------
                        // Tarjeta glass
                        // ----------------------------
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.surfaceVariant,
                              width: 1.2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  'Iniciar sesión',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),

                                // ----------------------------
                                // Selector de rol
                                // ----------------------------
                                RoleSelector(
                                  onRoleSelected:
                                      (r) => setState(() => _selectedRole = r),
                                ),
                                const SizedBox(height: 24),

                                // ----------------------------
                                // Formulario
                                // ----------------------------
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      // Email
                                      TextFormField(
                                        controller: _emailCtrl,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: theme.textTheme.bodyMedium,
                                        decoration: const InputDecoration(
                                          hintText: 'Correo',
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                          ),
                                        ),
                                        validator:
                                            (v) =>
                                                v != null && v.contains('@')
                                                    ? null
                                                    : 'Email inválido',
                                      ),
                                      const SizedBox(height: 16),
                                      // Contraseña
                                      TextFormField(
                                        controller: _passCtrl,
                                        obscureText: true,
                                        style: theme.textTheme.bodyMedium,
                                        decoration: const InputDecoration(
                                          hintText: 'Contraseña',
                                          prefixIcon: Icon(Icons.lock_outline),
                                        ),
                                        validator:
                                            (v) =>
                                                v != null && v.length >= 6
                                                    ? null
                                                    : 'Mínimo 6 caracteres',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ----------------------------
                                // Botón Entrar
                                // ----------------------------
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  onPressed: () async {
                                    final form = _formKey.currentState;
                                    if (form == null || !form.validate())
                                      return;
                                    final nav = Navigator.of(context);
                                    await authVm.login(
                                      email: _emailCtrl.text.trim(),
                                      password: _passCtrl.text,
                                    );
                                    if (!mounted) return;
                                    if (authVm.user != null) {
                                      final role =
                                          authVm.profile?['role'] as String? ??
                                          'user';
                                      if (role != _selectedRole) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Rol incorrecto'),
                                          ),
                                        );
                                        return;
                                      }
                                      nav.pushReplacementNamed(
                                        role == 'driver'
                                            ? DriverHomeScreen.routeName
                                            : UserHomeScreen.routeName,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Error al iniciar sesión',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Entrar',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // ----------------------------
                                // Link registro
                                // ----------------------------
                                TextButton(
                                  onPressed:
                                      () => Navigator.pushNamed(
                                        context,
                                        RegistrationScreen.routeName,
                                      ),
                                  child: Text(
                                    '¿No tienes cuenta? Regístrate',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
