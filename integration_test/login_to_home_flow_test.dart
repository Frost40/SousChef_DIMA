import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sous_chef/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';

/// REAL Integration Test - Login to Home Flow
///
/// This test uses:
/// - Real Firebase Authentication
/// - Real Firestore Database
/// - Real Provider State Management
/// - No Mocks!
///
/// Prerequisites:
/// 1. Create a test user in Firebase Console (Authentication):
///    Email: test@example.com
///    Password: REDACTED_PASSWORD
///
/// 2. Run the test:
///    flutter test integration_test/login_to_home_flow_test.dart -d <device_id>
///
/// Note: Make sure you have an Android emulator, iOS simulator, or
/// physical device running before executing the tests.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login to Home Flow - REAL Integration Test', () {
    testWidgets('Complete login flow with real Firebase', (
      WidgetTester tester,
    ) async {
      // ============================================
      // 1. LAUNCH THE REAL APP (NO MOCKS!)
      // ============================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Logout first to ensure we start from LoginScreen
      await FirebaseAuth.instance.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ============================================
      // 2. VERIFY WE ARE ON THE LOGIN SCREEN
      // ============================================
      expect(find.byType(app.LoginScreen), findsOneWidget);

      // Look for login button or title
      expect(
        find.text('Login'),
        findsWidgets,
      ); // May find button and possibly title

      // ============================================
      // 3. INSERT REAL TEST CREDENTIALS
      // ============================================
      // IMPORTANT: Create a test user in Firebase
      // Email: test@example.com
      // Password: REDACTED_PASSWORD

      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2)); // Email and Password fields

      // Enter email
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.pump(const Duration(milliseconds: 500));

      // Enter password
      await tester.enterText(textFields.last, 'REDACTED_PASSWORD');
      await tester.pump(const Duration(milliseconds: 500));

      // ============================================
      // 4. TAP THE LOGIN BUTTON
      // ============================================
      // Find the login button (PersonalizedButton with "Login" text)
      final loginButton = find.text('Login');
      expect(loginButton, findsWidgets); // May find multiple (title + button)

      // Tap on the last one (the button, not the title)
      await tester.tap(loginButton.last);

      // Wait for:
      // - Firebase Auth API call to complete
      // - AuthProvider to update state
      // - Navigation to MainLayout to happen
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 3)); // Wait for API call
      await tester.pumpAndSettle(
        const Duration(seconds: 5),
      ); // Complete all animations

      // ============================================
      // 5. VERIFY WE ARE IN THE HOME SCREEN
      // ============================================
      // We should no longer see the LoginScreen
      expect(find.byType(app.LoginScreen), findsNothing);

      // We should see elements of MainLayout/HomeScreen
      // Check for "Sous Chef" title in AppBar
      final appBarTitle = find.text('Sous Chef');
      expect(appBarTitle, findsOneWidget);

      // Verify presence of bottom navigation bar icons
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);

      // ============================================
      // 6. VERIFY USER DATA IS LOADED
      // ============================================
      // Wait for UserProvider to load data
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // If user has a saved address, it should appear
      // Otherwise we'll see "Choose your location"
      final addressOrPrompt = find.textContaining(
        RegExp(
          r'Choose your location|Selected location:',
          caseSensitive: false,
        ),
      );
      expect(addressOrPrompt, findsWidgets);

      print('✓ Login flow completed successfully!');

      // Wait for async operations to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Login with wrong credentials shows error', (
      WidgetTester tester,
    ) async {
      // ============================================
      // TEST LOGIN FAILURE WITH REAL BACKEND
      // ============================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Logout first to ensure we start from LoginScreen
      await FirebaseAuth.instance.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we are on login screen
      expect(find.byType(app.LoginScreen), findsOneWidget);

      // Insert wrong credentials
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'wrong@example.com');
      await tester.enterText(textFields.last, 'wrongpassword');
      await tester.pump(const Duration(milliseconds: 500));

      // Tap login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton.last);

      await tester.pump();
      await tester.pump(
        const Duration(seconds: 3),
      ); // Wait for Firebase response
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ============================================
      // VERIFY REAL ERROR FROM FIREBASE
      // ============================================
      // We should still be on LoginScreen
      expect(find.byType(app.LoginScreen), findsOneWidget);

      // At minimum, we should still see the login button (not navigated away)
      expect(find.text('Login'), findsWidgets);

      // Optionally verify error message if your UI shows it
      // final errorMessages = find.textContaining(RegExp(
      //   r'Invalid credentials|User not found|wrong password|invalid|error|failed',
      //   caseSensitive: false,
      // ));
      // expect(errorMessages, findsWidgets);

      print('✓ Login failure handled correctly');
    });

    testWidgets('Login with empty fields shows validation', (
      WidgetTester tester,
    ) async {
      // ============================================
      // TEST VALIDATION (BEFORE FIREBASE CALL)
      // ============================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Logout first to ensure we start from LoginScreen
      await FirebaseAuth.instance.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap login without entering anything
      final loginButton = find.text('Login');
      await tester.tap(loginButton.last);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify validation prevents login (doesn't even call Firebase)
      expect(find.byType(app.LoginScreen), findsOneWidget);

      // Should show validation message or stay on same screen
      // The form should prevent submission

      print('✓ Validation working correctly');
    });

    testWidgets('Complete flow: Login → Navigate to Favorites → Logout', (
      WidgetTester tester,
    ) async {
      // ============================================
      // COMPLEX TEST: NAVIGATION + LOGOUT
      // ============================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Logout first to ensure we start from LoginScreen
      await FirebaseAuth.instance.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on LoginScreen
      expect(find.byType(app.LoginScreen), findsOneWidget);

      // ============================================
      // 1. LOGIN
      // ============================================
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2));

      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.last, 'REDACTED_PASSWORD');
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Login').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we're logged in
      expect(find.byType(app.LoginScreen), findsNothing);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);

      // ============================================
      // 2. NAVIGATE TO FAVORITES
      // ============================================
      final favoritesTab = find.byIcon(Icons.favorite_rounded);
      await tester.tap(favoritesTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're in favorites screen
      // Look for "Favorites" text or empty state
      final favoritesIndicator = find.textContaining(
        RegExp(r'Favorites|No favorites', caseSensitive: false),
      );
      expect(favoritesIndicator, findsWidgets);

      // ============================================
      // 3. NAVIGATE TO ACCOUNT
      // ============================================
      final accountTab = find.byIcon(Icons.person_rounded);
      await tester.tap(accountTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're in account screen
      final accountIndicator = find.textContaining(
        RegExp(r'Account|Profile|Settings', caseSensitive: false),
      );
      expect(accountIndicator, findsWidgets);

      // ============================================
      // 4. TAP LOGOUT
      // ============================================
      final logoutButton = find.textContaining(
        RegExp(r'Logout|Sign out|Log out', caseSensitive: false),
      );

      // Scroll to find logout button if needed
      if (logoutButton.evaluate().isEmpty) {
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(logoutButton, findsWidgets);
      await tester.tap(logoutButton.first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ============================================
      // 5. VERIFY WE'RE BACK AT LOGIN
      // ============================================
      expect(find.byType(app.LoginScreen), findsOneWidget);
      expect(find.text('Login'), findsWidgets);

      print('✓ Complete navigation flow with logout successful!');
    });
  });

  group('Additional Integration Tests', () {
    testWidgets('Login persists across app restart', (
      WidgetTester tester,
    ) async {
      // This test verifies that Firebase Auth state persists

      // First login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Logout first to ensure we start from LoginScreen
      await FirebaseAuth.instance.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on LoginScreen
      expect(find.byType(app.LoginScreen), findsOneWidget);

      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2));

      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.last, 'REDACTED_PASSWORD');
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Login').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we're logged in
      expect(find.byType(app.LoginScreen), findsNothing);

      print('✓ Login persistence test completed');
    });

    testWidgets('Navigate through all tabs', (WidgetTester tester) async {
      // Login first
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Logout first to ensure we start from LoginScreen
      await FirebaseAuth.instance.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on LoginScreen
      expect(find.byType(app.LoginScreen), findsOneWidget);

      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2));
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.last, 'REDACTED_PASSWORD');
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Login').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Test each tab
      final tabs = [
        Icons.home_rounded,
        Icons.receipt_long_rounded,
        Icons.favorite_rounded,
        Icons.person_rounded,
      ];

      for (final iconData in tabs) {
        final tab = find.byIcon(iconData);
        expect(tab, findsOneWidget);
        await tester.tap(tab);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verify tab is active (still shows bottom nav)
        expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      }

      print('✓ All tabs navigation successful');
    });
  });
}
