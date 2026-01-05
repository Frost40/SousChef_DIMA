import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/dish_provider.dart';
import 'package:sous_chef/providers/order_provider.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/providers/stripe_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/themes/theme_provider.dart';

/// Mock class for AuthProvider
///
/// Use with mocktail to stub authentication methods:
/// ```dart
/// final mockAuthProvider = MockAuthProvider();
/// when(() => mockAuthProvider.user).thenReturn(mockUser);
/// when(() => mockAuthProvider.isLoading).thenReturn(false);
/// ```
class MockAuthProvider extends Mock implements AuthProvider {}

/// Mock class for ChatProvider
///
/// Use with mocktail to stub chat methods:
/// ```dart
/// final mockChatProvider = MockChatProvider();
/// when(() => mockChatProvider.chats).thenReturn([]);
/// when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
/// ```
class MockChatProvider extends Mock implements ChatProvider {}

/// Mock class for DishProvider
class MockDishProvider extends Mock implements DishProvider {}

/// Mock class for OrderProvider
class MockOrderProvider extends Mock implements OrderProvider {}

/// Mock class for RestaurantProvider
class MockRestaurantProvider extends Mock implements RestaurantProvider {}

/// Mock class for StripeProvider
class MockStripeProvider extends Mock implements StripeProvider {}

/// Mock class for UserProvider
class MockUserProvider extends Mock implements UserProvider {}

/// Mock class for ThemeProvider
class MockThemeProvider extends Mock implements ThemeProvider {}

/// Mock class for NavigatorObserver
///
/// Use to verify navigation events in widget tests:
/// ```dart
/// final mockObserver = MockNavigatorObserver();
/// await tester.pumpApp(
///   const MyWidget(),
///   navigatorObserver: mockObserver,
/// );
///
/// await tester.tap(find.text('Go to Settings'));
/// await tester.pumpAndSettle();
///
/// verify(() => mockObserver.didPush(any(), any())).called(1);
/// ```
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

/// Mock class for VoidCallback functions
///
/// Use to verify callback invocations:
/// ```dart
/// final mockCallback = MockVoidCallback();
/// await tester.pumpApp(
///   PersonalizedButton(
///     text: 'Click me',
///     onPressed: mockCallback.call,
///   ),
/// );
///
/// await tester.tap(find.text('Click me'));
/// verify(() => mockCallback()).called(1);
/// ```
class MockVoidCallback extends Mock {
  void call();
}

/// Mock class for value callbacks (e.g., onChanged)
class MockValueCallback<T> extends Mock {
  void call(T value);
}

/// Fake BuildContext for mocktail fallback values
class FakeBuildContext extends Fake implements BuildContext {}

/// Registers fallback values for mocktail.
///
/// Call this in setUpAll() when using verify() with any() matchers:
/// ```dart
/// setUpAll(() {
///   registerFallbackValues();
/// });
/// ```
void registerFallbackValues() {
  registerFallbackValue(MaterialPageRoute<void>(builder: (_) => Container()));
  registerFallbackValue(const RouteSettings());
  registerFallbackValue(FakeBuildContext());
}
