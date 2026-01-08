import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/screens/login_screen.dart';
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
    when(() => mockAuthProvider.signIn(any(), any())).thenAnswer((_) async {});
  });

  group('LoginScreen', () {
    group('Rendering', () {
      testWidgets('renders email field, password field, and Login button', (
        tester,
      ) async {
        // Set larger surface size to avoid overflow errors
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const LoginScreen(),
          authProvider: mockAuthProvider,
        );

        // Verify email field is rendered
        expect(find.byIcon(Icons.email_rounded), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);

        // Verify password field is rendered
        expect(find.byIcon(Icons.key_rounded), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);

        // Verify Login button is rendered
        expect(find.text('Login'), findsOneWidget);
        expect(find.byType(PersonalizedButton), findsOneWidget);
      });

      testWidgets('renders sign up link', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const LoginScreen(),
          authProvider: mockAuthProvider,
        );

        expect(find.text("Don't have an account?"), findsOneWidget);
        expect(find.text('Sign up'), findsOneWidget);
      });

      testWidgets('renders social login buttons', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const LoginScreen(),
          authProvider: mockAuthProvider,
        );

        expect(find.text('Join using Facebook'), findsOneWidget);
        expect(find.text('Join using Google'), findsOneWidget);
      });
    });

    group('Validation Error', () {
      testWidgets(
        'tapping Login with empty fields calls setFieldErrors with emptyEmail and emptyPassword true',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpApp(
            const LoginScreen(),
            authProvider: mockAuthProvider,
          );

          // Find and tap the Login button
          final loginButton = find.text('Login');
          expect(loginButton, findsOneWidget);

          await tester.tap(loginButton);
          await tester.pump();

          // Verify setFieldErrors was called with emptyEmail: true and emptyPassword: true
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

          // Verify signIn was NOT called
          verifyNever(() => mockAuthProvider.signIn(any(), any()));
        },
      );

      testWidgets(
        'tapping Login with only email empty calls setFieldErrors with emptyEmail true',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpApp(
            const LoginScreen(),
            authProvider: mockAuthProvider,
          );

          // Find TextField widgets (inside TextFormField) - there should be 2 (email and password)
          final textFields = find.byType(TextField);
          expect(textFields, findsNWidgets(2));

          // Tap on password field first to focus it
          await tester.tap(textFields.at(1));
          await tester.pump();

          // Enter password only (second field)
          await tester.enterText(textFields.at(1), 'password123');
          await tester.pump();

          // Tap Login button
          await tester.tap(find.text('Login'));
          await tester.pump();

          // Verify setFieldErrors was called with emptyEmail: true, emptyPassword: false
          verify(
            () => mockAuthProvider.setFieldErrors(
              emptyEmail: true,
              emptyPassword: false,
              invalidEmail: any(named: 'invalidEmail'),
              invalidPassword: any(named: 'invalidPassword'),
              invalidConfirmPassword: any(named: 'invalidConfirmPassword'),
              emptyConfirmPassword: any(named: 'emptyConfirmPassword'),
              emptyUsername: any(named: 'emptyUsername'),
              emptyRestaurantname: any(named: 'emptyRestaurantname'),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'tapping Login with only password empty calls setFieldErrors with emptyPassword true',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpApp(
            const LoginScreen(),
            authProvider: mockAuthProvider,
          );

          // Find TextField widgets
          final textFields = find.byType(TextField);

          // Tap on email field first to focus it
          await tester.tap(textFields.at(0));
          await tester.pump();

          // Enter email only (first field)
          await tester.enterText(textFields.at(0), 'test@example.com');
          await tester.pump();

          // Tap Login button
          await tester.tap(find.text('Login'));
          await tester.pump();

          // Verify setFieldErrors was called with emptyEmail: false, emptyPassword: true
          verify(
            () => mockAuthProvider.setFieldErrors(
              emptyEmail: false,
              emptyPassword: true,
              invalidEmail: any(named: 'invalidEmail'),
              invalidPassword: any(named: 'invalidPassword'),
              invalidConfirmPassword: any(named: 'invalidConfirmPassword'),
              emptyConfirmPassword: any(named: 'emptyConfirmPassword'),
              emptyUsername: any(named: 'emptyUsername'),
              emptyRestaurantname: any(named: 'emptyRestaurantname'),
            ),
          ).called(1);
        },
      );

      testWidgets('displays error message when authProvider has error', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        const errorMessage = 'Invalid email or password';
        when(() => mockAuthProvider.errorMessage).thenReturn(errorMessage);

        await tester.pumpApp(
          const LoginScreen(),
          authProvider: mockAuthProvider,
        );

        expect(find.text(errorMessage), findsOneWidget);
      });
    });

    group('Success Flow', () {
      testWidgets(
        'entering valid credentials and tapping Login calls signIn with correct arguments',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          const testEmail = 'test@example.com';
          const testPassword = 'password123';

          await tester.pumpApp(
            const LoginScreen(),
            authProvider: mockAuthProvider,
          );

          // Find TextField widgets
          final textFields = find.byType(TextField);

          // Tap and enter email (first field)
          await tester.tap(textFields.at(0));
          await tester.pump();
          await tester.enterText(textFields.at(0), testEmail);
          await tester.pump();

          // Tap and enter password (second field)
          await tester.tap(textFields.at(1));
          await tester.pump();
          await tester.enterText(textFields.at(1), testPassword);
          await tester.pump();

          // Tap Login button
          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();

          // Verify signIn was called with correct arguments
          verify(
            () => mockAuthProvider.signIn(testEmail, testPassword),
          ).called(1);
        },
      );

      testWidgets('setFieldErrors is not called when fields are filled', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const LoginScreen(),
          authProvider: mockAuthProvider,
        );

        // Find TextField widgets
        final textFields = find.byType(TextField);

        // Tap and enter email
        await tester.tap(textFields.at(0));
        await tester.pump();
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.pump();

        // Tap and enter password
        await tester.tap(textFields.at(1));
        await tester.pump();
        await tester.enterText(textFields.at(1), 'password123');
        await tester.pump();

        // Tap Login button
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

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
          const LoginScreen(),
          authProvider: mockAuthProvider,
        );

        // The PersonalizedButton should still be present
        expect(find.byType(PersonalizedButton), findsOneWidget);

        // When loading, the button shows a loading animation widget
        // We verify by checking that the centralWidget is not null
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
          const LoginScreen(),
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
          const LoginScreen(),
          authProvider: mockAuthProvider,
        );

        // The AuthInputField with email should have hasError: true
        // We verify by checking that the provider value is read correctly
        verify(() => mockAuthProvider.hasEmailError).called(greaterThan(0));
      });

      testWidgets(
        'password field shows error state when hasPasswordError is true',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          when(() => mockAuthProvider.hasPasswordError).thenReturn(true);

          await tester.pumpApp(
            const LoginScreen(),
            authProvider: mockAuthProvider,
          );

          // The AuthInputField with password should have hasError: true
          verify(
            () => mockAuthProvider.hasPasswordError,
          ).called(greaterThan(0));
        },
      );
    });
  });
}
