import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/ride_view_model.dart';
import '../models/ride_request.dart';
import 'ride_tracking_screen.dart';
import 'user_home_screen.dart';

class WaitingForDriverScreen extends StatefulWidget {
  static const String routeName = '/waiting-for-driver';
  const WaitingForDriverScreen({Key? key}) : super(key: key);

  @override
  _WaitingForDriverScreenState createState() => _WaitingForDriverScreenState();
}

class _WaitingForDriverScreenState extends State<WaitingForDriverScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<RideViewModel>();
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: StreamBuilder<RideRequest>(
        stream: vm.currentRideStream(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final ride = snap.data!;
          switch (ride.status) {
            case 'pending':
              return _buildPending(context);
            case 'accepted':
              return _buildAccepted(context, ride);
            case 'on_the_way':
            case 'in_progress':
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(
                  context,
                  RideTrackingScreen.routeName,
                  arguments: ride,
                );
              });
              return const SizedBox.shrink();
            case 'cancelled':
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  UserHomeScreen.routeName,
                  (_) => false,
                );
              });
              return const SizedBox.shrink();
            default:
              return _buildPending(context);
          }
        },
      ),
    );
  }

  Widget _buildPending(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Buscando un conductor disponible…',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              context.read<RideViewModel>().cancelRide();
              Navigator.pop(context);
            },
            child: const Text('Cancelar solicitud'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccepted(BuildContext context, RideRequest ride) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.security, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Conductor asignado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'PIN de recogida: ${ride.pinCode}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                RideTrackingScreen.routeName,
                arguments: ride,
              );
            },
            child: const Text('Confirmar recogida'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}
