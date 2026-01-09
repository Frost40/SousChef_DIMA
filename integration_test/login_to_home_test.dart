import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/app_router.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/screens/login_screen.dart';
import 'package:sous_chef/models/user.dart';

/// Mock class for AuthProvider
class MockAuthProvider extends Mock implements AuthProvider {}

/// Mock class for ChatProvider
class MockChatProvider extends Mock implements ChatProvider {}

/// Mock class for UserProvider
class MockUserProvider extends Mock implements UserProvider {}

/// Mock class for RestaurantProvider
class MockRestaurantProvider extends Mock implements RestaurantProvider {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthProvider mockAuthProvider;
  late MockChatProvider mockChatProvider;
  late MockUserProvider mockUserProvider;
  late MockRestaurantProvider mockRestaurantProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();
    mockUserProvider = MockUserProvider();
    mockRestaurantProvider = MockRestaurantProvider();

    // Default AuthProvider stubs
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.hasEmailError).thenReturn(false);
    when(() => mockAuthProvider.hasPasswordError).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
    when(() => mockAuthProvider.user).thenReturn(null);
    when(() => mockAuthProvider.clearErrors()).thenReturn(null);
    when(
      () => mockAuthProvider.setFieldErrors(
        emptyEmail: any(named: 'emptyEmail'),
        emptyPassword: any(named: 'emptyPassword'),
        invalidEmail: any(named: 'invalidEmail'),
        invalidPassword: any(named: 'invalidPassword'),
        invalidConfirmPassword: any(named: 'invalidConfirmPassword'),
        emptyConfirmPassword: any(named: 'emptyConfirmPassword'),
        emptyUsername: any(named: 'emptyUsername'),
        emptyRestaurantname: any(named: 'emptyRestaurantname'),
      ),
    ).thenReturn(null);

    // Default ChatProvider stubs
    when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
    when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
    when(() => mockChatProvider.setCurrentUserId(any())).thenReturn(null);
    when(() => mockChatProvider.startListeningToChats()).thenReturn(null);

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
  });

  group('Login to Home Flow', () {
    testWidgets('should navigate to Home screen after successful login', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a mock user that will be returned after login
      final mockUser = User(
        id: 'test-user-123',
        email: 'test@example.com',
        username: 'testuser',
        name: 'Test',
        surname: 'User',
        phone: '1234567890',
      );

      // Stub signIn to simulate a successful login
      when(() => mockAuthProvider.signIn(any(), any())).thenAnswer((_) async {
        // After signIn is called, update isAuthenticated and user
        when(() => mockAuthProvider.isAuthenticated).thenReturn(true);
        when(() => mockAuthProvider.user).thenReturn(mockUser);
      });

      // Also stub init for MainLayout
      when(() => mockAuthProvider.init()).thenAnswer((_) async {});

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
            Provider<AppRouter>(create: (_) => AppRouter()),
          ],
          child: Consumer<AppRouter>(
            builder: (context, router, child) {
              return MaterialApp(
                home: const LoginScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act: Find email and password text fields and enter credentials
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      // Enter email in the first text field
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.pump();

      // Enter password in the second text field
      await tester.enterText(textFields.last, 'password123');
      await tester.pump();

      // Find and tap the Login button
      final loginButton = find.text('Login');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert: Verify signIn was called with correct credentials
      verify(
        () => mockAuthProvider.signIn('test@example.com', 'password123'),
      ).called(1);

      // Assert: Verify navigation to Home screen (MainLayout)
      // The MainLayout contains a HomeScreen, which has specific elements
      // After navigation, we should no longer see the Login button
      expect(find.text('Login'), findsNothing);

      // Verify we navigated away from login screen
      // The LoginScreen should no longer be visible
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('should show error and stay on Login screen when login fails', (
      WidgetTester tester,
    ) async {
      // Arrange: Stub signIn to simulate a failed login
      when(() => mockAuthProvider.signIn(any(), any())).thenAnswer((_) async {
        // Login fails - isAuthenticated stays false, set error message
        when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
        when(
          () => mockAuthProvider.errorMessage,
        ).thenReturn('Invalid credentials');
      });

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
            Provider<AppRouter>(create: (_) => AppRouter()),
          ],
          child: Consumer<AppRouter>(
            builder: (context, router, child) {
              return MaterialApp(
                home: const LoginScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act: Enter credentials and tap login
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'wrong@example.com');
      await tester.enterText(textFields.last, 'wrongpassword');
      await tester.pump();

      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert: Verify signIn was called
      verify(
        () => mockAuthProvider.signIn('wrong@example.com', 'wrongpassword'),
      ).called(1);

      // Assert: Should still be on Login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should not call signIn when email and password are empty', (
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
            Provider<AppRouter>(create: (_) => AppRouter()),
          ],
          child: Consumer<AppRouter>(
            builder: (context, router, child) {
              return MaterialApp(
                home: const LoginScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act: Tap login without entering credentials
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert: signIn should NOT be called
      verifyNever(() => mockAuthProvider.signIn(any(), any()));

      // Assert: setFieldErrors should be called with empty field flags
      verify(
        () => mockAuthProvider.setFieldErrors(
          emptyEmail: true,
          emptyPassword: true,
          invalidEmail: any(named: 'invalidEmail'),
          invalidPassword: any(named: 'invalidPassword'),
          invalidConfirmPassword: any(named: 'invalidConfirmPassword'),
          emptyConfirmPassword: any(named: 'emptyConfirmPassword'),
          emptyUsername: any(named: 'emptyUsername'),
          emptyRestaurantname: any(named: 'emptyRestaurantname'),
        ),
      ).called(1);

      // Assert: Should still be on Login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
