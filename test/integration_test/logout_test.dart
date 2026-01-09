import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/app_router.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/screens/account_screen.dart';
import 'package:sous_chef/screens/login_screen.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/themes/light_mode.dart';
import 'package:sous_chef/widgets/animated_button.dart';

/// Mock class for AuthProvider
class MockAuthProvider extends Mock implements AuthProvider {}

/// Mock class for ChatProvider
class MockChatProvider extends Mock implements ChatProvider {}

/// Mock class for UserProvider
class MockUserProvider extends Mock implements UserProvider {}

/// Mock class for RestaurantProvider
class MockRestaurantProvider extends Mock implements RestaurantProvider {}

/// Mock class for ThemeProvider
class MockThemeProvider extends Mock implements ThemeProvider {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthProvider mockAuthProvider;
  late MockChatProvider mockChatProvider;
  late MockUserProvider mockUserProvider;
  late MockRestaurantProvider mockRestaurantProvider;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();
    mockUserProvider = MockUserProvider();
    mockRestaurantProvider = MockRestaurantProvider();
    mockThemeProvider = MockThemeProvider();

    // Create a mock user (user is logged in initially)
    final mockUser = User(
      id: 'test-user-123',
      email: 'test@example.com',
      username: 'testuser',
      name: 'Test',
      surname: 'User',
      phone: '1234567890',
    );

    // Default AuthProvider stubs - user is authenticated
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.hasEmailError).thenReturn(false);
    when(() => mockAuthProvider.hasPasswordError).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(true);
    when(() => mockAuthProvider.user).thenReturn(mockUser);
    when(() => mockAuthProvider.clearErrors()).thenReturn(null);

    // Default ChatProvider stubs
    when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
    when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
    when(() => mockChatProvider.setCurrentUserId(any())).thenReturn(null);
    when(() => mockChatProvider.startListeningToChats()).thenReturn(null);
    when(() => mockChatProvider.clearAllChats()).thenReturn(null);

    // Default UserProvider stubs
    when(() => mockUserProvider.userData).thenReturn(null);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});

    // Default RestaurantProvider stubs
    when(() => mockRestaurantProvider.isLoading).thenReturn(false);
    when(
      () => mockRestaurantProvider.fetchNearbyRestaurants(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radiusInKm: any(named: 'radiusInKm'),
      ),
    ).thenAnswer((_) async => []);

    // Default ThemeProvider stubs
    when(() => mockThemeProvider.themeData).thenReturn(lightMode);
    when(() => mockThemeProvider.isDarkMode).thenReturn(false);
  });

  group('Logout Flow', () {
    testWidgets('should navigate to Login screen after successful logout', (
      WidgetTester tester,
    ) async {
      // Arrange: Stub signOut to simulate a successful logout
      when(
        () => mockAuthProvider.signOut(onSignOut: any(named: 'onSignOut')),
      ).thenAnswer((invocation) async {
        // Call the onSignOut callback if provided
        final onSignOut =
            invocation.namedArguments[const Symbol('onSignOut')] as Function?;
        if (onSignOut != null) {
          onSignOut();
        }

        // After signOut, user is no longer authenticated
        when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
        when(() => mockAuthProvider.user).thenReturn(null);
      });

      // Build the app with mock providers starting from AccountScreen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<RestaurantProvider>.value(
              value: mockRestaurantProvider,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: mockThemeProvider,
            ),
            Provider<AppRouter>(create: (_) => AppRouter()),
          ],
          child: Consumer<AppRouter>(
            builder: (context, router, child) {
              return MaterialApp(
                home: const AccountScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verify we're on the Account screen
      expect(find.byType(AccountScreen), findsOneWidget);

      // Act: Find the Logout button and tap it
      // The Logout text is inside PersonalizedButton inside AnimatedButton
      final logoutButton = find.text('Logout');
      expect(logoutButton, findsOneWidget);

      // Find the AnimatedButton that contains the Logout text
      final animatedButton = find.ancestor(
        of: logoutButton,
        matching: find.byType(AnimatedButton),
      );
      expect(animatedButton, findsOneWidget);

      await tester.tap(animatedButton);
      await tester.pumpAndSettle();

      // Assert: Verify signOut was called
      verify(
        () => mockAuthProvider.signOut(onSignOut: any(named: 'onSignOut')),
      ).called(1);

      // Assert: Verify clearAllChats was called (via onSignOut callback)
      verify(() => mockChatProvider.clearAllChats()).called(1);

      // Assert: Verify navigation to Login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AccountScreen), findsNothing);
    });

    testWidgets('should show Logout button on Account screen', (
      WidgetTester tester,
    ) async {
      // Build the app with mock providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<RestaurantProvider>.value(
              value: mockRestaurantProvider,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: mockThemeProvider,
            ),
            Provider<AppRouter>(create: (_) => AppRouter()),
          ],
          child: Consumer<AppRouter>(
            builder: (context, router, child) {
              return MaterialApp(
                home: const AccountScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verify we're on the Account screen
      expect(find.byType(AccountScreen), findsOneWidget);

      // Assert: Verify Logout button exists
      final logoutButton = find.text('Logout');
      expect(logoutButton, findsOneWidget);
    });

    testWidgets('should display account options on Account screen', (
      WidgetTester tester,
    ) async {
      // Build the app with mock providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<RestaurantProvider>.value(
              value: mockRestaurantProvider,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: mockThemeProvider,
            ),
            Provider<AppRouter>(create: (_) => AppRouter()),
          ],
          child: Consumer<AppRouter>(
            builder: (context, router, child) {
              return MaterialApp(
                home: const AccountScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verify we're on the Account screen
      expect(find.byType(AccountScreen), findsOneWidget);

      // Assert: Verify account screen elements are displayed
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Past Orders'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
