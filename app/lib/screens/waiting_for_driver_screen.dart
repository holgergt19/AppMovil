import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import 'ride_tracking_screen.dart';
import '../models/ride_request.dart';

class WaitingForDriverScreen extends StatefulWidget {
  static const String routeName = '/waiting-for-driver';

  const WaitingForDriverScreen({Key? key}) : super(key: key);

  @override
  _WaitingForDriverScreenState createState() => _WaitingForDriverScreenState();
}

class _WaitingForDriverScreenState extends State<WaitingForDriverScreen> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<RideViewModel>();
    // En cuanto el status cambie a "accepted", navegamos a la pantalla de tracking
    vm.currentRideStream().listen((ride) {
      if (ride.status == 'accepted') {
        Navigator.pushReplacementNamed(
          context,
          RideTrackingScreen.routeName,
          arguments: ride,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esperando conductor')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Buscando conductor disponible...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
