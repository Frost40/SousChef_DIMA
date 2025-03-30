import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/screens/login_screen.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_router.dart';
import 'firebase_options.dart';
import 'package:sous_chef/screens/home_screen.dart';

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
    return StreamBuilder<User?>(
      stream: Authentication().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            // l'utente non è loggato, mostra la schermata di login
            return LoginScreen();
          } else {
            // l'utente è già loggato, mostra la home screen
            return const HomeScreen();
          }
        }
        // in attesa che la connessione venga stabilita
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}