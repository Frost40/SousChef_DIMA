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
import 'package:sous_chef/screens/signup_screen.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/widgets/animated_button.dart';

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
    when(() => mockAuthProvider.hasConfirmPasswordError).thenReturn(false);
    when(() => mockAuthProvider.hasUsernameError).thenReturn(false);
    when(() => mockAuthProvider.hasRestaurantnameError).thenReturn(false);
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

  group('SignUp to Home Flow', () {
    testWidgets('should navigate to Home screen after successful sign up', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a mock user that will be returned after sign up
      final mockUser = User(
        id: 'new-user-123',
        email: 'newuser@example.com',
        username: 'newuser',
        name: 'New',
        surname: 'User',
        phone: '1234567890',
      );

      // Stub signUp to simulate a successful registration
      when(
        () => mockAuthProvider.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
          restaurantName: any(named: 'restaurantName'),
        ),
      ).thenAnswer((_) async {
        // After signUp is called, update user (errorMessage stays null for success)
        when(() => mockAuthProvider.user).thenReturn(mockUser);
        when(() => mockAuthProvider.isAuthenticated).thenReturn(true);
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
                home: const SignUpScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act: Find text fields and enter credentials
      // SignUpScreen has: Email, Password, Confirm Password, Username
      final textFields = find.byType(TextField);
      expect(
        textFields,
        findsNWidgets(4),
      ); // Email, Password, ConfirmPassword, Username

      // Enter email (first field)
      await tester.enterText(textFields.at(0), 'newuser@example.com');
      await tester.pump();

      // Enter password (second field)
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pump();

      // Enter confirm password (third field)
      await tester.enterText(textFields.at(2), 'password123');
      await tester.pump();

      // Enter username (fourth field)
      await tester.enterText(textFields.at(3), 'newuser');
      await tester.pump();

      // Dismiss keyboard to reveal the SignUp button
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Scroll down to make the SignUp button visible and tap it
      final signUpButton = find.byType(AnimatedButton);
      await tester.scrollUntilVisible(
        signUpButton,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(signUpButton, findsOneWidget);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Assert: Verify signUp was called with correct parameters
      verify(
        () => mockAuthProvider.signUp(
          email: 'newuser@example.com',
          password: 'password123',
          username: 'newuser',
          restaurantName: null,
        ),
      ).called(1);

      // Assert: Verify navigation to Home screen
      // After navigation, we should no longer see the SignUp button
      expect(find.text('SignUp'), findsNothing);

      // Verify we navigated away from signup screen
      expect(find.byType(SignUpScreen), findsNothing);
    });

    testWidgets(
      'should show error and stay on SignUp screen when sign up fails',
      (WidgetTester tester) async {
        // Arrange: Stub signUp to simulate a failed registration
        when(
          () => mockAuthProvider.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            username: any(named: 'username'),
            restaurantName: any(named: 'restaurantName'),
          ),
        ).thenAnswer((_) async {
          // Sign up fails - set error message
          when(
            () => mockAuthProvider.errorMessage,
          ).thenReturn('Email already in use');
        });

        // Build the app with mock providers
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: mockAuthProvider,
              ),
              ChangeNotifierProvider<ChatProvider>.value(
                value: mockChatProvider,
              ),
              ChangeNotifierProvider<UserProvider>.value(
                value: mockUserProvider,
              ),
              ChangeNotifierProvider<RestaurantProvider>.value(
                value: mockRestaurantProvider,
              ),
              Provider<AppRouter>(create: (_) => AppRouter()),
            ],
            child: Consumer<AppRouter>(
              builder: (context, router, child) {
                return MaterialApp(
                  home: const SignUpScreen(),
                  onGenerateRoute: router.onGenerateRoute,
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Act: Enter all required fields
        final textFields = find.byType(TextField);

        await tester.enterText(textFields.at(0), 'existing@example.com');
        await tester.enterText(textFields.at(1), 'password123');
        await tester.enterText(textFields.at(2), 'password123');
        await tester.enterText(textFields.at(3), 'existinguser');
        await tester.pump();

        // Dismiss keyboard to reveal the SignUp button
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Scroll down to make the SignUp button visible and tap it
        final signUpButton = find.byType(AnimatedButton);
        await tester.scrollUntilVisible(
          signUpButton,
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        // Assert: Verify signUp was called
        verify(
          () => mockAuthProvider.signUp(
            email: 'existing@example.com',
            password: 'password123',
            username: 'existinguser',
            restaurantName: null,
          ),
        ).called(1);

        // Assert: Should still be on SignUp screen
        expect(find.byType(SignUpScreen), findsOneWidget);
      },
    );

    testWidgets('should not call signUp when required fields are empty', (
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
                home: const SignUpScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act: Tap SignUp without entering credentials
      final signUpButton = find.byType(AnimatedButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Assert: signUp should NOT be called
      verifyNever(
        () => mockAuthProvider.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
          restaurantName: any(named: 'restaurantName'),
        ),
      );

      // Assert: setFieldErrors should be called
      verify(
        () => mockAuthProvider.setFieldErrors(
          emptyEmail: true,
          emptyPassword: true,
          invalidEmail: any(named: 'invalidEmail'),
          invalidPassword: any(named: 'invalidPassword'),
          invalidConfirmPassword: any(named: 'invalidConfirmPassword'),
          emptyConfirmPassword: true,
          emptyUsername: any(named: 'emptyUsername'),
          emptyRestaurantname: any(named: 'emptyRestaurantname'),
        ),
      ).called(1);

      // Assert: Should still be on SignUp screen
      expect(find.byType(SignUpScreen), findsOneWidget);
    });

    testWidgets('should not call signUp when passwords do not match', (
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
                home: const SignUpScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act: Enter credentials with mismatched passwords
      final textFields = find.byType(TextField);

      await tester.enterText(textFields.at(0), 'user@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(
        textFields.at(2),
        'differentpassword',
      ); // Mismatch!
      await tester.enterText(textFields.at(3), 'username');
      await tester.pump();

      // Dismiss keyboard to reveal the SignUp button
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Scroll down to make the SignUp button visible and tap it
      final signUpButton = find.byType(AnimatedButton);
      await tester.scrollUntilVisible(
        signUpButton,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Assert: signUp should NOT be called due to password mismatch
      verifyNever(
        () => mockAuthProvider.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
          restaurantName: any(named: 'restaurantName'),
        ),
      );

      // Assert: setFieldErrors should be called with invalidConfirmPassword
      verify(
        () => mockAuthProvider.setFieldErrors(
          emptyEmail: false,
          emptyPassword: false,
          invalidEmail: any(named: 'invalidEmail'),
          invalidPassword: any(named: 'invalidPassword'),
          invalidConfirmPassword: true,
          emptyConfirmPassword: false,
          emptyUsername: false,
          emptyRestaurantname: any(named: 'emptyRestaurantname'),
        ),
      ).called(1);

      // Assert: Should still be on SignUp screen
      expect(find.byType(SignUpScreen), findsOneWidget);
    });

    testWidgets('should not call signUp when password is too short', (
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
                home: const SignUpScreen(),
                onGenerateRoute: router.onGenerateRoute,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act: Enter credentials with password <= 6 characters
      final textFields = find.byType(TextField);

      await tester.enterText(textFields.at(0), 'user@example.com');
      await tester.enterText(
        textFields.at(1),
        '123456',
      ); // Only 6 chars, needs > 6
      await tester.enterText(textFields.at(2), '123456');
      await tester.enterText(textFields.at(3), 'username');
      await tester.pump();

      // Dismiss keyboard to reveal the SignUp button
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Scroll down to make the SignUp button visible and tap it
      final signUpButton = find.byType(AnimatedButton);
      await tester.scrollUntilVisible(
        signUpButton,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Assert: signUp should NOT be called due to short password
      verifyNever(
        () => mockAuthProvider.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
          restaurantName: any(named: 'restaurantName'),
        ),
      );

      // Assert: setFieldErrors should be called with invalidPassword
      verify(
        () => mockAuthProvider.setFieldErrors(
          emptyEmail: false,
          emptyPassword: false,
          invalidEmail: any(named: 'invalidEmail'),
          invalidPassword: true,
          invalidConfirmPassword: any(named: 'invalidConfirmPassword'),
          emptyConfirmPassword: false,
          emptyUsername: false,
          emptyRestaurantname: any(named: 'emptyRestaurantname'),
        ),
      ).called(1);

      // Assert: Should still be on SignUp screen
      expect(find.byType(SignUpScreen), findsOneWidget);
    });
  });
}
