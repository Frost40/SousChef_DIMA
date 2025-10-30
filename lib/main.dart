import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/dish_provider.dart';
import 'package:sous_chef/providers/order_provider.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/providers/stripe_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/screens/login_screen.dart';
import 'package:sous_chef/screens/main_layout.dart';
import 'package:sous_chef/services/orientation_manager.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_router.dart';
import 'firebase_options.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => DishProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => StripeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        Provider<AppRouter>(create: (_) => AppRouter()),
      ],
      child: Consumer2<AppRouter, ThemeProvider>(
        builder: (context, router, themeProvider, child) {
          return MaterialApp(
            title: 'sous_chef',
            theme:
                themeProvider
                    .themeData, // This will now update when theme changes
            home: const AuthenticationWrapper(),
            onGenerateRoute: router.onGenerateRoute,
            builder: (context, child) {
              // Use ResponsiveLayout to enforce orientations
              OrientationManager().enforceOrientations(context);

              return child!;
            },
          );
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: Authentication().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          firebase_auth.User? user = snapshot.data;
          if (user == null) {
            // user not logged in
            return LoginScreen();
          } else {
            // user already logged in
            return MainLayout();
          }
        }
        // waiting for authentication state
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
