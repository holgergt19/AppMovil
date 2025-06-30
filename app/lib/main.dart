import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';

import 'view_models/auth_view_model.dart';
import 'view_models/home_view_model.dart';
import 'view_models/ride_view_model.dart';
import 'view_models/driver_view_model.dart';
import 'view_models/payment_view_model.dart';
import 'view_models/rating_view_model.dart';
import 'view_models/favorites_view_model.dart';

import 'screens/destination_entry_screen.dart';

import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/plan_trip_screen.dart';
import 'screens/ride_options_screen.dart';
import 'screens/ride_request_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/ride_tracking_screen.dart';
import 'screens/ride_history_screen.dart';
import 'screens/favorite_locations_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/driver_trip_detail_screen.dart';
import 'screens/driver_active_trip_screen.dart';
import 'screens/driver_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TaxiApp());
}

class TaxiApp extends StatelessWidget {
  const TaxiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => RideViewModel()),
        ChangeNotifierProvider(create: (_) => DriverViewModel()),
        ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        ChangeNotifierProvider(create: (_) => RatingViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Taxi App',
        theme: AppTheme.lightTheme,
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegistrationScreen.routeName: (_) => const RegistrationScreen(),
          UserHomeScreen.routeName: (_) => const UserHomeScreen(),
          PlanTripScreen.routeName: (_) => const PlanTripScreen(),
          RideOptionsScreen.routeName: (_) => const RideOptionsScreen(),
          RideRequestScreen.routeName: (_) => const RideRequestScreen(),
          PaymentScreen.routeName: (_) => const PaymentScreen(),
          RatingScreen.routeName: (_) => const RatingScreen(),
          DestinationEntryScreen.routeName:
              (_) => const DestinationEntryScreen(),

          RideTrackingScreen.routeName: (_) => const RideTrackingScreen(),
          RideHistoryScreen.routeName: (_) => const RideHistoryScreen(),
          FavoriteLocationsScreen.routeName:
              (_) => const FavoriteLocationsScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          DriverHomeScreen.routeName: (_) => const DriverHomeScreen(),
          DriverTripDetailScreen.routeName:
              (_) => const DriverTripDetailScreen(),
          DriverActiveTripScreen.routeName:
              (_) => const DriverActiveTripScreen(),
          DriverHistoryScreen.routeName: (_) => const DriverHistoryScreen(),
        },
      ),
    );
  }
}
