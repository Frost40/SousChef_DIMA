import 'package:flutter/material.dart';
import 'package:sous_chef/screens/login_screen.dart';
import 'package:sous_chef/screens/signup_screen.dart';
import 'package:sous_chef/screens/home_screen.dart';
import 'package:sous_chef/screens/orders_screen.dart';
import 'package:sous_chef/screens/restaurant_screen.dart';
import 'package:sous_chef/screens/favorites_screen.dart';
import 'package:sous_chef/screens/account_screen.dart';
import 'package:sous_chef/screens/cart_screen.dart';
import 'package:sous_chef/screens/messages_screen.dart';

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case '/restaurant':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RestaurantScreen(restaurantId: args?['restaurantId'] ?? ''),
        );
      case '/favorites':
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case '/account':
        return MaterialPageRoute(builder: (_) => const AccountScreen());
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case '/messages':
        return MaterialPageRoute(builder: (_) => const MessagesScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}