import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child:
            authVm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    // AppBar verde
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF008000),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Center(
                        child: Text(
                          'Iniciar sesión',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animación Lottie (o cualquier logo)
                    Lottie.asset('assets/animations/home.json', height: 180),

                    const SizedBox(height: 16),

                    // Formulario
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildField(
                              controller: _emailCtrl,
                              hintText: 'Correo',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator:
                                  (v) =>
                                      v != null && v.contains('@')
                                          ? null
                                          : 'Email inválido',
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              controller: _passCtrl,
                              hintText: 'Contraseña',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator:
                                  (v) =>
                                      v != null && v.length >= 6
                                          ? null
                                          : 'Mínimo 6 caracteres',
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  await authVm.login(
                                    email: _emailCtrl.text.trim(),
                                    password: _passCtrl.text,
                                  );
                                  if (authVm.user != null) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Error al iniciar sesión',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Entrar'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed:
                                  () =>
                                      Navigator.pushNamed(context, '/register'),
                              child: const Text(
                                '¿No tienes cuenta? Regístrate',
                                style: TextStyle(color: Colors.yellow),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
