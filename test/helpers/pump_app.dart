import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/dish_provider.dart';
import 'package:sous_chef/providers/order_provider.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/providers/stripe_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';

import 'mock_providers.dart';

/// Extension on [WidgetTester] to simplify widget testing setup.
///
/// Provides a [pumpApp] method that wraps widgets with necessary providers
/// and MaterialApp for testing.
extension PumpApp on WidgetTester {
  /// Pumps a widget wrapped in [MaterialApp] and [MultiProvider].
  ///
  /// All providers are optional and default to mock implementations.
  /// Use [navigatorObserver] to verify navigation events with [MockNavigatorObserver].
  ///
  Future<void> pumpApp(
    Widget widget, {
    AuthProvider? authProvider,
    ChatProvider? chatProvider,
    DishProvider? dishProvider,
    OrderProvider? orderProvider,
    RestaurantProvider? restaurantProvider,
    StripeProvider? stripeProvider,
    UserProvider? userProvider,
    NavigatorObserver? navigatorObserver,
    ThemeData? theme,
    List<NavigatorObserver>? additionalObservers,
  }) async {
    final observers = <NavigatorObserver>[
      if (navigatorObserver != null) navigatorObserver,
      ...?additionalObservers,
    ];

    await pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider ?? MockAuthProvider(),
          ),
          ChangeNotifierProvider<ChatProvider>.value(
            value: chatProvider ?? MockChatProvider(),
          ),
          if (dishProvider != null)
            ChangeNotifierProvider<DishProvider>.value(value: dishProvider),
          if (orderProvider != null)
            ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
          if (restaurantProvider != null)
            ChangeNotifierProvider<RestaurantProvider>.value(
              value: restaurantProvider,
            ),
          if (stripeProvider != null)
            ChangeNotifierProvider<StripeProvider>.value(value: stripeProvider),
          if (userProvider != null)
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ],
        child: MaterialApp(
          theme: theme ?? ThemeData.light(),
          home: widget,
          navigatorObservers: observers,
        ),
      ),
    );
  }

  /// Pumps a widget wrapped only in [MaterialApp] without providers.
  ///
  /// Use this for testing simple widgets that don't require providers.
  Future<void> pumpWidget_(
    Widget widget, {
    NavigatorObserver? navigatorObserver,
    ThemeData? theme,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: theme ?? ThemeData.light(),
        home: widget,
        navigatorObservers: [if (navigatorObserver != null) navigatorObserver],
      ),
    );
  }

  /// Pumps a widget with Scaffold wrapper for widgets that need a Scaffold ancestor.
  Future<void> pumpAppWithScaffold(
    Widget widget, {
    AuthProvider? authProvider,
    ChatProvider? chatProvider,
    NavigatorObserver? navigatorObserver,
    ThemeData? theme,
  }) async {
    await pumpApp(
      Scaffold(body: widget),
      authProvider: authProvider,
      chatProvider: chatProvider,
      navigatorObserver: navigatorObserver,
      theme: theme,
    );
  }
}
