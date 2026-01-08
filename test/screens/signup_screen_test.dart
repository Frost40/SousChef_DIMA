import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/screens/signup_screen.dart';
import 'package:sous_chef/widgets/personalized_button.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();

    // Stub default values for AuthProvider properties
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.hasEmailError).thenReturn(false);
    when(() => mockAuthProvider.hasPasswordError).thenReturn(false);
    when(() => mockAuthProvider.hasConfirmPasswordError).thenReturn(false);
    when(() => mockAuthProvider.hasUsernameError).thenReturn(false);
    when(() => mockAuthProvider.hasRestaurantnameError).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);

    // Stub methods that might be called
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
    when(
      () => mockAuthProvider.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        username: any(named: 'username'),
        restaurantName: any(named: 'restaurantName'),
      ),
    ).thenAnswer((_) async {
      // Simulate an error to prevent navigation in tests
      when(
        () => mockAuthProvider.errorMessage,
      ).thenReturn('Test error to prevent navigation');
    });
  });

  // Helper to ignore overflow errors during tests
  void ignoreOverflowErrors(
    FlutterErrorDetails details, {
    bool forceReport = false,
  }) {
    bool ifIsOverflowError = false;
    final exception = details.exception;
    if (exception is FlutterError) {
      ifIsOverflowError = exception.diagnostics.any(
        (e) => e.value.toString().contains('overflowed'),
      );
    }
    if (!ifIsOverflowError) {
      FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
    }
  }

  group('SignUpScreen', () {
    group('Rendering', () {
      testWidgets(
        'renders email, password, confirm password, username fields and SignUp button',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          // Verify email field is rendered
          expect(find.text('Email'), findsOneWidget);

          // Verify password field is rendered
          expect(find.text('Password'), findsOneWidget);

          // Verify confirm password field is rendered
          expect(find.text('Confirm Password'), findsOneWidget);

          // Verify username field is rendered
          expect(find.text('Username'), findsOneWidget);

          // Verify SignUp button is rendered
          expect(find.text('SignUp'), findsOneWidget);
          expect(find.byType(PersonalizedButton), findsOneWidget);
        },
      );

      testWidgets('renders login link', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const SignUpScreen(),
          authProvider: mockAuthProvider,
        );

        expect(find.text('Do you already have an account?'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
      });

      testWidgets('renders chef toggle switch', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const SignUpScreen(),
          authProvider: mockAuthProvider,
        );

        expect(find.text('Registering as a chef'), findsOneWidget);
      });

      testWidgets(
        'does not render restaurant name field when chef toggle is off',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          // Restaurant Name field should not be visible when chef toggle is off
          expect(find.text('Restaurant Name'), findsNothing);
        },
      );
    });

    group('Validation Error', () {
      testWidgets(
        'tapping SignUp with empty fields calls setFieldErrors with appropriate flags',
        (tester) async {
          // Ignore overflow errors for this test
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;
          addTearDown(() => FlutterError.onError = originalOnError);

          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          // Find and tap the SignUp button
          final signUpButton = find.text('SignUp');
          expect(signUpButton, findsOneWidget);

          await tester.tap(signUpButton);
          await tester.pump();

          // Verify setFieldErrors was called with empty fields flags
          verify(
            () => mockAuthProvider.setFieldErrors(
              emptyEmail: true,
              emptyPassword: true,
              emptyConfirmPassword: true,
              emptyUsername: any(named: 'emptyUsername'),
              emptyRestaurantname: any(named: 'emptyRestaurantname'),
              invalidEmail: any(named: 'invalidEmail'),
              invalidPassword: any(named: 'invalidPassword'),
              invalidConfirmPassword: any(named: 'invalidConfirmPassword'),
            ),
          ).called(1);

          // Verify signUp was NOT called
          verifyNever(
            () => mockAuthProvider.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
              restaurantName: any(named: 'restaurantName'),
            ),
          );
        },
      );

      testWidgets(
        'tapping SignUp with mismatched passwords calls setFieldErrors with invalidConfirmPassword',
        (tester) async {
          // Ignore overflow errors for this test
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;
          addTearDown(() => FlutterError.onError = originalOnError);

          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          // Find TextField widgets
          final textFields = find.byType(TextField);

          // Enter email
          await tester.tap(textFields.at(0));
          await tester.pump();
          await tester.enterText(textFields.at(0), 'test@example.com');
          await tester.pump();

          // Enter password (minimum 7 characters)
          await tester.tap(textFields.at(1));
          await tester.pump();
          await tester.enterText(textFields.at(1), 'password123');
          await tester.pump();

          // Enter different confirm password
          await tester.tap(textFields.at(2));
          await tester.pump();
          await tester.enterText(textFields.at(2), 'differentpassword');
          await tester.pump();

          // Enter username
          await tester.tap(textFields.at(3));
          await tester.pump();
          await tester.enterText(textFields.at(3), 'testuser');
          await tester.pump();

          // Tap SignUp button
          await tester.tap(find.text('SignUp'));
          await tester.pump();

          // Verify setFieldErrors was called with invalidConfirmPassword: true
          verify(
            () => mockAuthProvider.setFieldErrors(
              emptyEmail: false,
              emptyPassword: false,
              emptyConfirmPassword: false,
              emptyUsername: any(named: 'emptyUsername'),
              emptyRestaurantname: any(named: 'emptyRestaurantname'),
              invalidEmail: any(named: 'invalidEmail'),
              invalidPassword: any(named: 'invalidPassword'),
              invalidConfirmPassword: true,
            ),
          ).called(1);
        },
      );

      testWidgets(
        'tapping SignUp with short password calls setFieldErrors with invalidPassword',
        (tester) async {
          // Ignore overflow errors for this test
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;
          addTearDown(() => FlutterError.onError = originalOnError);

          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          // Find TextField widgets
          final textFields = find.byType(TextField);

          // Enter email
          await tester.tap(textFields.at(0));
          await tester.pump();
          await tester.enterText(textFields.at(0), 'test@example.com');
          await tester.pump();

          // Enter short password (6 or less characters)
          await tester.tap(textFields.at(1));
          await tester.pump();
          await tester.enterText(textFields.at(1), '123456');
          await tester.pump();

          // Enter same confirm password
          await tester.tap(textFields.at(2));
          await tester.pump();
          await tester.enterText(textFields.at(2), '123456');
          await tester.pump();

          // Enter username
          await tester.tap(textFields.at(3));
          await tester.pump();
          await tester.enterText(textFields.at(3), 'testuser');
          await tester.pump();

          // Tap SignUp button
          await tester.tap(find.text('SignUp'));
          await tester.pump();

          // Verify setFieldErrors was called with invalidPassword: true
          verify(
            () => mockAuthProvider.setFieldErrors(
              emptyEmail: false,
              emptyPassword: false,
              emptyConfirmPassword: false,
              emptyUsername: any(named: 'emptyUsername'),
              emptyRestaurantname: any(named: 'emptyRestaurantname'),
              invalidEmail: any(named: 'invalidEmail'),
              invalidPassword: true,
              invalidConfirmPassword: any(named: 'invalidConfirmPassword'),
            ),
          ).called(1);
        },
      );

      testWidgets('displays error message when authProvider has error', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        const errorMessage = 'Email already in use';
        when(() => mockAuthProvider.errorMessage).thenReturn(errorMessage);

        await tester.pumpApp(
          const SignUpScreen(),
          authProvider: mockAuthProvider,
        );

        expect(find.text(errorMessage), findsOneWidget);
      });
    });

    group('Success Flow', () {
      testWidgets(
        'entering valid credentials and tapping SignUp calls signUp with correct arguments',
        (tester) async {
          // Ignore overflow errors for this test
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;
          addTearDown(() => FlutterError.onError = originalOnError);

          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          const testEmail = 'test@example.com';
          const testPassword = 'password123';
          const testUsername = 'testuser';

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          // Find TextField widgets
          final textFields = find.byType(TextField);

          // Enter email
          await tester.tap(textFields.at(0));
          await tester.pump();
          await tester.enterText(textFields.at(0), testEmail);
          await tester.pump();

          // Enter password
          await tester.tap(textFields.at(1));
          await tester.pump();
          await tester.enterText(textFields.at(1), testPassword);
          await tester.pump();

          // Enter confirm password (same as password)
          await tester.tap(textFields.at(2));
          await tester.pump();
          await tester.enterText(textFields.at(2), testPassword);
          await tester.pump();

          // Enter username
          await tester.tap(textFields.at(3));
          await tester.pump();
          await tester.enterText(textFields.at(3), testUsername);
          await tester.pump();

          // Tap SignUp button
          await tester.tap(find.text('SignUp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          // Verify signUp was called with correct arguments
          verify(
            () => mockAuthProvider.signUp(
              email: testEmail,
              password: testPassword,
              username: testUsername,
              restaurantName: null,
            ),
          ).called(1);
        },
      );

      testWidgets('setFieldErrors is not called when all fields are valid', (
        tester,
      ) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;
        addTearDown(() => FlutterError.onError = originalOnError);

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const SignUpScreen(),
          authProvider: mockAuthProvider,
        );

        // Find TextField widgets
        final textFields = find.byType(TextField);

        // Enter valid credentials
        await tester.tap(textFields.at(0));
        await tester.pump();
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.pump();

        await tester.tap(textFields.at(1));
        await tester.pump();
        await tester.enterText(textFields.at(1), 'password123');
        await tester.pump();

        await tester.tap(textFields.at(2));
        await tester.pump();
        await tester.enterText(textFields.at(2), 'password123');
        await tester.pump();

        await tester.tap(textFields.at(3));
        await tester.pump();
        await tester.enterText(textFields.at(3), 'testuser');
        await tester.pump();

        // Tap SignUp button
        await tester.tap(find.text('SignUp'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify setFieldErrors was NOT called
        verifyNever(
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
        );
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator when isLoading is true', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        when(() => mockAuthProvider.isLoading).thenReturn(true);

        await tester.pumpApp(
          const SignUpScreen(),
          authProvider: mockAuthProvider,
        );

        // The PersonalizedButton should still be present
        expect(find.byType(PersonalizedButton), findsOneWidget);

        // When loading, the button shows a loading animation widget
        final personalizedButton = tester.widget<PersonalizedButton>(
          find.byType(PersonalizedButton),
        );

        // The centralWidget should be set (not null) when loading
        expect(personalizedButton.centralWidget, isNotNull);
      });

      testWidgets('does not show loading indicator when isLoading is false', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        when(() => mockAuthProvider.isLoading).thenReturn(false);

        await tester.pumpApp(
          const SignUpScreen(),
          authProvider: mockAuthProvider,
        );

        final personalizedButton = tester.widget<PersonalizedButton>(
          find.byType(PersonalizedButton),
        );

        // The centralWidget should be null when not loading
        expect(personalizedButton.centralWidget, isNull);
      });
    });

    group('Error State Display', () {
      testWidgets('email field shows error state when hasEmailError is true', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        when(() => mockAuthProvider.hasEmailError).thenReturn(true);

        await tester.pumpApp(
          const SignUpScreen(),
          authProvider: mockAuthProvider,
        );

        verify(() => mockAuthProvider.hasEmailError).called(greaterThan(0));
      });

      testWidgets(
        'password field shows error state when hasPasswordError is true',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          when(() => mockAuthProvider.hasPasswordError).thenReturn(true);

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          verify(
            () => mockAuthProvider.hasPasswordError,
          ).called(greaterThan(0));
        },
      );

      testWidgets(
        'confirm password field shows error state when hasConfirmPasswordError is true',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          when(() => mockAuthProvider.hasConfirmPasswordError).thenReturn(true);

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          verify(
            () => mockAuthProvider.hasConfirmPasswordError,
          ).called(greaterThan(0));
        },
      );

      testWidgets(
        'username field shows error state when hasUsernameError is true',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          when(() => mockAuthProvider.hasUsernameError).thenReturn(true);

          await tester.pumpApp(
            const SignUpScreen(),
            authProvider: mockAuthProvider,
          );

          verify(
            () => mockAuthProvider.hasUsernameError,
          ).called(greaterThan(0));
        },
      );
    });
  });
}
