import 'package:flutter/material.dart';
import 'package:sous_chef/screens/account_settings_screen.dart';
import 'package:sous_chef/screens/login_screen.dart';
import 'package:sous_chef/screens/past_orders_screen.dart';
import 'package:sous_chef/screens/signup_screen.dart';
import 'package:sous_chef/screens/main_layout.dart';
import 'package:sous_chef/screens/restaurant_screen.dart';
import 'package:sous_chef/screens/cart_screen.dart';
import 'package:sous_chef/transition_type.dart';
import 'package:sous_chef/screens/allChats_screen.dart';
import 'package:sous_chef/screens/chat_screen.dart';

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    TransitionType? transitionType;
    if (settings.arguments is Map) {
      final args = settings.arguments as Map;
      if (args.containsKey('transitionType')) {
        transitionType = args['transitionType'] as TransitionType;
      }
    }

    switch (settings.name) {
      case '/login':
        return CustomPageRoute(
          page: LoginScreen(),
          transitionType: transitionType ?? TransitionType.fade,
        );
      case '/signup':
        return CustomPageRoute(
          page: const SignUpScreen(),
          transitionType: transitionType ?? TransitionType.fade,
        );
      case '/main':
        return CustomPageRoute(
          page: const MainLayout(),
          transitionType: transitionType ?? TransitionType.fade,
        );
      case '/allChats':
        return CustomPageRoute(
          page: const AllChatsScreen(),
          transitionType: transitionType ?? TransitionType.fade,
        );
      case '/chat':
        final args = settings.arguments as Map<String, dynamic>?;
        final String chatId = args?['chatId'] ?? '';
        final String otherUserName = args?['otherUserName'] ?? '';
        return CustomPageRoute(
          page: ChatScreen(chatId: chatId, otherUserName: otherUserName),
          transitionType: transitionType ?? TransitionType.fade,
        );
      case '/restaurant':
        final args = settings.arguments as Map<String, dynamic>?;
        final String restaurantId = args?['restaurantId'];
        return CustomPageRoute(
          page: RestaurantScreen(restaurantId: restaurantId),
          transitionType: transitionType ?? TransitionType.fade,
        );
      case '/cart':
        return CustomPageRoute(
          page: const CartScreen(),
          transitionType: transitionType ?? TransitionType.fade,
        );
      // Aggiungi in lib/app_router.dart
      case '/account-settings':
        return CustomPageRoute(
          page: const AccountSettingsScreen(),
          transitionType: transitionType ?? TransitionType.fade,
        );
      case '/past-orders':
        return CustomPageRoute(
          page: const PastOrdersScreen(),
          transitionType: transitionType ?? TransitionType.fade,
        );
      default:
        return CustomPageRoute(
          page: const MainLayout(),
          transitionType: transitionType ?? TransitionType.fade,
        );
    }
  }
}
