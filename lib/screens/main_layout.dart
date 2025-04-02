// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'package:sous_chef/screens/home_screen.dart';
import '../widgets/custom_navigation_bar.dart';
import 'account_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          Widget page;
          TransitionType transitionType = TransitionType.fade;

          switch (settings.name) {
            case '/home':
              page = const HomeScreen();
              break;
            case '/orders':
              page = const OrdersScreen();
              break;
            case '/favorites':
              page = const FavoritesScreen();
              break;
            case '/account':
              page = const AccountScreen();
              break;
            default:
              page = const HomeScreen();
          }

          // Determina il tipo di transizione in base alla direzione
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
            final oldIndex = _currentIndex;
            setState(() {
              _currentIndex = index;
            });

            final transitionType = index > oldIndex
                ? TransitionType.slideRight
                : TransitionType.slideLeft;

            final routes = ['/home', '/orders', '/favorites', '/account'];
            navigatorKey.currentState?.pushReplacementNamed(
              routes[index],
              arguments: {'transitionType': transitionType},
            );
          }
        },
      ),
    );
  }
}