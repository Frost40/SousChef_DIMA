import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/screens/login_screen.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'app_router.dart';
import 'firebase_options.dart';
import 'package:sous_chef/screens/home_screen.dart';
import 'package:sous_chef/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        Provider<AppRouter>(create: (_) => AppRouter()),
      ],
      child: Consumer<AppRouter>(
        builder: (context, router, child) {
          return MaterialApp(
            title: 'sous_chef',
            theme: ThemeProvider().themeData,
            home: const AuthenticationWrapper(),
            onGenerateRoute: router.onGenerateRoute,
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
            return const HomeScreen();
          }
        }
        // waiting for authentication state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}