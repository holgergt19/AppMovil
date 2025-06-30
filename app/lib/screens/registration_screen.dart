import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';

class RegistrationScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body:
          authVm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator:
                            (v) =>
                                v != null && v.isNotEmpty
                                    ? null
                                    : 'Ingresa tu nombre',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                        ),
                        keyboardType: TextInputType.phone,
                        validator:
                            (v) =>
                                v != null && v.isNotEmpty
                                    ? null
                                    : 'Ingresa tu teléfono',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Correo'),
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (v) =>
                                v != null && v.contains('@')
                                    ? null
                                    : 'Email inválido',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                        validator:
                            (v) =>
                                v != null && v.length >= 6
                                    ? null
                                    : 'Mínimo 6 caracteres',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          await authVm.register(
                            name: _nameCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                            email: _emailCtrl.text.trim(),
                            password: _passCtrl.text,
                          );
                          if (authVm.user != null) {
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al registrarse'),
                              ),
                            );
                          }
                        },
                        child: const Text('Registrarse'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
