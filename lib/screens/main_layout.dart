// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/screens/home_screen.dart';
import 'package:sous_chef/screens/past_orders_screen.dart';
import 'package:sous_chef/screens/restaurant_screen.dart';
import '../providers/user_provider.dart';
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

  @override
  void initState() {
    super.initState();
    // Making sure the user data is fetched when the app starts
    Future.microtask(() =>
      Provider.of<UserProvider>(context, listen: false).fetchUserData()
    );
  }

  // lib/screens/main_layout.dart
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isRestaurantOwner = userProvider.userData?.restaurantId != null;

    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          Widget page;
          // Set default transition type
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
            case '/restaurant':
              page = const RestaurantScreen();
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

          return CustomPageRoute(page: page, transitionType: transitionType);
        },
        initialRoute: '/home',
      ),
      bottomNavigationBar: CustomNavBar(
        initialIndex: _currentIndex,
        restaurantOwner: isRestaurantOwner, // Passing the flag to the nav bar
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });

            // Defining the routes based on the user type
            final List<String> routes;
            if (isRestaurantOwner) {
              routes = ['/home', '/orders', '/restaurant', '/favorites', '/account'];
            } else {
              routes = ['/home', '/orders', '/favorites', '/account'];
            }

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
