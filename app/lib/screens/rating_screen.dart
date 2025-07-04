import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/rating_view_model.dart';
import '../view_models/ride_view_model.dart';
import '../widget/loading_indicator.dart';
import 'user_home_screen.dart';

class RatingScreen extends StatefulWidget {
  static const routeName = '/rating';
  const RatingScreen({Key? key}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 5;
  final _commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final rateVm = context.watch<RatingViewModel>();
    final rideVm = context.read<RideViewModel>();

    // Usamos null-aware para evitar String? → String error
    final rideId = rideVm.rideId ?? '';
    final driverId = rideVm.assignedDriverId ?? '';

    // Si no tenemos IDs válidos, mostramos un mensaje
    if (rideId.isEmpty || driverId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Califica tu viaje')),
        body: const Center(
          child: Text('No hay un viaje activo para calificar.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Califica tu viaje')),
      body:
          rateVm.isSubmitting
              ? const LoadingIndicator()
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('¿Cómo fue tu viaje?'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final idx = i + 1;
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: idx <= _stars ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () => setState(() => _stars = idx),
                        );
                      }),
                    ),
                    TextField(
                      controller: _commentCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Comentario (opcional)',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          () => rateVm.submitRating(
                            rideId: rideId,
                            driverId: driverId,
                            stars: _stars,
                            comment: _commentCtrl.text.trim(),
                            onSuccess:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  UserHomeScreen.routeName,
                                ),
                            onError:
                                (msg) => ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(msg))),
                          ),
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ),
    );
  }
}
