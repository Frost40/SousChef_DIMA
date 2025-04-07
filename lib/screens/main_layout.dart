// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'package:sous_chef/screens/home_screen.dart';
import 'package:sous_chef/screens/past_orders_screen.dart';
import '../widgets/custom_navigation_bar.dart';
import 'account_screen.dart';
import 'account_settings_screen.dart';
import 'favorites_screen.dart';
import 'orders_screen.dart';
import '../transition_type.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final navigatorKey = GlobalKey<NavigatorState>();

  // lib/screens/main_layout.dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          Widget page;
          // Imposta la transizione predefinita per le pagine interne come slideRight
          TransitionType transitionType = TransitionType.slideRight;

          switch (settings.name) {
            case '/home':
              page = const HomeScreen();
              // Usa transizione Spotify tra le schede principali
              transitionType = TransitionType.spotify;
              break;
            case '/orders':
              page = const OrdersScreen();
              transitionType = TransitionType.spotify;
              break;
            case '/favorites':
              page = const FavoritesScreen();
              transitionType = TransitionType.spotify;
              break;
            case '/account':
              page = const AccountScreen();
              transitionType = TransitionType.spotify;
              break;
            // Pagine interne mantengono slideRight di default
            case '/account-settings':
              page = const AccountSettingsScreen();
              break;
            case '/past-orders':
              page = const PastOrdersScreen();
              break;
            default:
              page = const HomeScreen();
              transitionType = TransitionType.spotify;
          }

          // Sovrascrivi il tipo di transizione se specificato negli argomenti
          if (settings.arguments is Map) {
            final args = settings.arguments as Map;
            if (args.containsKey('transitionType')) {
              transitionType = args['transitionType'] as TransitionType;
            }
          }

          return CustomPageRoute(
            page: page,
            transitionType: transitionType,
          );
        },
        initialRoute: '/home',
      ),
      bottomNavigationBar: CustomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });

            // Usa sempre la transizione Spotify per le schede principali
            final routes = ['/home', '/orders', '/favorites', '/account'];
            navigatorKey.currentState?.pushReplacementNamed(
              routes[index],
              arguments: {'transitionType': TransitionType.spotify},
            );
          }
        },
      ),
    );
  }
}