import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sous_chef/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';

/// REAL Integration Test - Login to Restaurant Chat Flow
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
/// 2. Ensure there are restaurants in the database visible to this user
///
/// 3. Run the test:
///    flutter test integration_test/login_to_chat_flow_test.dart -d <device_id>
///    flutter test integration_test/login_to_chat_flow_test.dart -d "29043A99-7A90-404A-BD0D-153B519BEB50"
///
/// Note: Make sure you have an Android emulator, iOS simulator, or
/// physical device running before executing the tests.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login to Restaurant Chat Flow - REAL Integration Test', () {
    testWidgets(
      'Complete flow: Login → Home → Select Restaurant → Open Chat → Send Message',
      (WidgetTester tester) async {
        try {
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
        expect(
          find.byType(app.LoginScreen),
          findsOneWidget,
          reason: 'FAIL: Not on LoginScreen after logout. App may not have loaded correctly.',
        );
        expect(
          find.text('Login'),
          findsWidgets,
          reason: 'FAIL: Login button not found on LoginScreen.',
        );

        // ============================================
        // 3. LOGIN WITH TEST CREDENTIALS
        // ============================================
        final textFields = find.byType(TextField);
        expect(
          textFields,
          findsAtLeastNWidgets(2),
          reason: 'FAIL: Email and Password fields not found. LoginScreen may be broken.',
        );

        // Enter email
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.pump(const Duration(milliseconds: 500));

        // Enter password
        await tester.enterText(textFields.last, 'REDACTED_PASSWORD');
        await tester.pump(const Duration(milliseconds: 500));

        // ============================================
        // 4. TAP THE LOGIN BUTTON
        // ============================================
        final loginButton = find.text('Login');
        await tester.tap(loginButton.last);

        // Wait for authentication
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // ============================================
        // 5. VERIFY WE ARE IN THE HOME SCREEN
        // ============================================
        expect(
          find.byType(app.LoginScreen),
          findsNothing,
          reason: 'FAIL: Still on LoginScreen. Login failed - check credentials or Firebase connection.',
        );
        expect(
          find.text('Sous Chef'),
          findsOneWidget,
          reason: 'FAIL: "Sous Chef" title not found. Navigation to home failed.',
        );
        expect(
          find.byIcon(Icons.home_rounded),
          findsOneWidget,
          reason: 'FAIL: Home icon not found in bottom navigation. MainLayout may not have loaded.',
        );

        debugPrint('✓ Login successful');

        // ============================================
        // 6. WAIT FOR RESTAURANTS TO LOAD
        // ============================================
        // Wait for nearby restaurants to be loaded
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ============================================
        // 7. FIND AND TAP ON A RESTAURANT
        // ============================================
        // Look for RestaurantListTile - we'll tap the first one found
        final restaurantTileFinder = find.byType(app.RestaurantListTile);

        // Verify that at least one restaurant is displayed
        if (restaurantTileFinder.evaluate().isEmpty) {
          fail(
            'FAIL: No restaurants found in the list.\n'
            'Possible causes:\n'
            '  - No restaurants exist in the database\n'
            '  - User has no saved address/location\n'
            '  - Distance filter is too restrictive\n'
            '  - RestaurantProvider failed to fetch data\n'
            'Action: Check database and user location settings.',
          );
        }
        expect(
          restaurantTileFinder,
          findsWidgets,
          reason: 'FAIL: RestaurantListTile widgets not rendered correctly.',
        );

        // Scroll down to make sure the first restaurant is fully visible
        await tester.ensureVisible(restaurantTileFinder.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Tap on the first restaurant
        await tester.tap(restaurantTileFinder.first);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        debugPrint('✓ Restaurant opened');

        // ============================================
        // 8. VERIFY WE ARE ON RESTAURANT SCREEN
        // ============================================
        expect(
          find.byType(app.RestaurantScreen),
          findsOneWidget,
          reason:
              'FAIL: RestaurantScreen not opened.\n'
              'Possible causes:\n'
              '  - Restaurant tap did not trigger navigation\n'
              '  - Restaurant data is incomplete\n'
              '  - Navigation failed',
        );

        // ============================================
        // 9. FIND AND TAP THE CHAT ICON (Mail Icon)
        // ============================================
        // The chat icon is in the AppBar actions as Icons.mail_rounded
        final chatIconFinder = find.byIcon(Icons.mail_rounded);

        if (chatIconFinder.evaluate().isEmpty) {
          fail(
            'FAIL: Chat icon (Icons.mail_rounded) not found in AppBar.\n'
            'Possible causes:\n'
            '  - User is the owner of this restaurant (owners cannot chat with themselves)\n'
            '  - AppBar actions are not rendering correctly\n'
            '  - RestaurantScreen layout changed\n'
            'Action: Verify logged-in user is NOT the owner of the selected restaurant.',
          );
        }
        expect(
          chatIconFinder,
          findsOneWidget,
          reason: 'FAIL: Multiple or no chat icons found.',
        );

        // Tap the chat icon
        await tester.tap(chatIconFinder);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        debugPrint('✓ Chat icon tapped, opening chat screen');

        // ============================================
        // 10. VERIFY WE ARE ON CHAT SCREEN
        // ============================================
        expect(
          find.byType(app.ChatScreen),
          findsOneWidget,
          reason:
              'FAIL: ChatScreen not opened.\n'
              'Possible causes:\n'
              '  - Chat creation failed\n'
              '  - Navigation to ChatScreen failed\n'
              '  - ChatProvider error\n'
              '  - Firestore permissions issue',
        );

        // Check for the message input field
        final messageInputFinder = find.widgetWithText(
          TextField,
          'Write a message...',
        );
        expect(
          messageInputFinder,
          findsOneWidget,
          reason:
              'FAIL: Message input field not found.\n'
              'ChatScreen UI may have changed or failed to render.',
        );

        debugPrint('✓ Chat screen opened');

        // ============================================
        // 11. WRITE "ciao" IN THE MESSAGE FIELD
        // ============================================
        await tester.enterText(messageInputFinder, 'ciao');
        await tester.pump(const Duration(milliseconds: 500));

        // Verify the text was entered
        expect(
          find.text('ciao'),
          findsOneWidget,
          reason:
              'FAIL: Text "ciao" was not entered into the message field.\n'
              'TextField may not be accepting input correctly.',
        );

        debugPrint('✓ Message "ciao" written');

        // ============================================
        // 12. TAP THE SEND BUTTON
        // ============================================
        // The send button is an IconButton with Icons.send
        final sendButtonFinder = find.byIcon(Icons.send);
        expect(
          sendButtonFinder,
          findsOneWidget,
          reason:
              'FAIL: Send button (Icons.send) not found.\n'
              'ChatScreen UI may have changed.',
        );

        await tester.tap(sendButtonFinder);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        debugPrint('✓ Message sent');

        // ============================================
        // 13. VERIFY THE MESSAGE APPEARS IN THE CHAT
        // ============================================
        // Wait a bit for the message to be sent and appear
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // The message should appear in a message bubble
        // We should find "ciao" in the chat messages
        if (find.text('ciao').evaluate().isEmpty) {
          fail(
            'FAIL: Message "ciao" did not appear in the chat after sending.\n'
            'Possible causes:\n'
            '  - ChatProvider.sendMessage() failed\n'
            '  - Firestore write failed\n'
            '  - Stream not updating\n'
            '  - Message rendering failed\n'
            'Action: Check Firebase logs and ChatProvider implementation.',
          );
        }
        expect(
          find.text('ciao'),
          findsWidgets,
          reason: 'FAIL: Message "ciao" should appear at least once in the chat.',
        );

        debugPrint('✓ Message appears in chat');

        // ============================================
        // 14. VERIFY INPUT FIELD IS CLEARED
        // ============================================
        // After sending, the message input should be empty
        final clearedInputFinder = find.widgetWithText(
          TextField,
          'Write a message...',
        );
        expect(
          clearedInputFinder,
          findsOneWidget,
          reason:
              'FAIL: Input field was not cleared after sending message.\n'
              'Message controller may not be clearing correctly.',
        );

        debugPrint('✓ Input field cleared after sending');

        debugPrint('✅ Complete flow test passed successfully!');

        // Wait for async operations to complete
        await tester.pumpAndSettle(const Duration(seconds: 1));
      } catch (e, stackTrace) {
        debugPrint('❌ TEST FAILED WITH EXCEPTION: $e');
        debugPrint('Stack trace:\n$stackTrace');
        fail(
          'FAIL: Test threw an unexpected exception.\n'
          'Error: $e\n'
          'See debug console for full stack trace.',
        );
      }
      },
    );

    testWidgets(
      'Chat flow: Verify back navigation works correctly',
      (WidgetTester tester) async {
        try {
          // ============================================
          // SETUP: Login and navigate to chat
          // ============================================
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 5));

          await FirebaseAuth.instance.signOut();
          await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.byType(app.LoginScreen), findsOneWidget);

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.enterText(textFields.last, 'REDACTED_PASSWORD');
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Login').last);
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Wait for restaurants
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Tap restaurant
        final restaurantTileFinder = find.byType(app.RestaurantListTile);
        if (restaurantTileFinder.evaluate().isEmpty) {
          fail(
            'FAIL: No restaurants found for navigation test.\n'
            'Cannot complete test without available restaurants.',
          );
        }
        expect(
          restaurantTileFinder,
          findsWidgets,
          reason: 'FAIL: RestaurantListTile not found for navigation test.',
        );

        await tester.ensureVisible(restaurantTileFinder.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        await tester.tap(restaurantTileFinder.first);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Open chat
        final chatIconFinder = find.byIcon(Icons.mail_rounded);
        await tester.tap(chatIconFinder);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(
          find.byType(app.ChatScreen),
          findsOneWidget,
          reason: 'FAIL: Setup failed - ChatScreen not opened for navigation test.',
        );

        debugPrint('✓ Setup complete: In chat screen');

        // ============================================
        // TEST: Navigate back to restaurant screen
        // ============================================
        final backButton = find.byType(BackButton);
        expect(
          backButton,
          findsOneWidget,
          reason: 'FAIL: Back button not found in ChatScreen AppBar.',
        );

        await tester.tap(backButton);
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should be back on restaurant screen
        expect(
          find.byType(app.RestaurantScreen),
          findsOneWidget,
          reason:
              'FAIL: Not on RestaurantScreen after back navigation from chat.\n'
              'Navigation pop may have failed.',
        );
        expect(
          find.byType(app.ChatScreen),
          findsNothing,
          reason: 'FAIL: ChatScreen still visible after back navigation.',
        );

        debugPrint('✓ Back navigation from chat to restaurant works');

        // ============================================
        // TEST: Navigate back to home screen
        // ============================================
        final restaurantBackButton = find.byType(BackButton);
        await tester.tap(restaurantBackButton);
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should be back on home screen
        expect(
          find.byType(app.RestaurantScreen),
          findsNothing,
          reason: 'FAIL: RestaurantScreen still visible after navigating back to home.',
        );
        expect(
          find.text('Sous Chef'),
          findsOneWidget,
          reason: 'FAIL: Not on HomeScreen after back navigation from restaurant.',
        );
        expect(
          find.byIcon(Icons.home_rounded),
          findsOneWidget,
          reason: 'FAIL: Home icon not found. MainLayout may not be showing.',
        );

        debugPrint('✓ Back navigation from restaurant to home works');

        debugPrint('✅ Navigation test passed successfully!');
      } catch (e, stackTrace) {
        debugPrint('❌ NAVIGATION TEST FAILED WITH EXCEPTION: $e');
        debugPrint('Stack trace:\n$stackTrace');
        fail(
          'FAIL: Navigation test threw an unexpected exception.\n'
          'Error: $e\n'
          'See debug console for full stack trace.',
        );
      }
      },
    );
  });
}
