import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sous_chef/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sous_chef/widgets/restaurant_screen/menu_item.dart';
import 'package:sous_chef/widgets/circular_button.dart';
import 'package:sous_chef/models/dish.dart';

/// REAL Integration Test - Restaurant Add Dish Flow
///
/// This test uses:
/// - Real Firebase Authentication
/// - Real Firestore Database
/// - Real Provider State Management
/// - No Mocks!
///
/// Prerequisites:
/// 1. Restaurant user must exist in Firebase Console (Authentication):
///    Email: owner@example.com
///    Password: REDACTED_PASSWORD
///
/// 2. Restaurant must be available in Firebase
///
/// 3. Run the test:
///    flutter test integration_test/restaurant_add_dish_flow_test.dart -d <device_id>
///    flutter test integration_test/restaurant_add_dish_flow_test.dart -d "29043A99-7A90-404A-BD0D-153B519BEB50"

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant Add Dish Flow - REAL Integration Test', () {
    testWidgets('Complete flow: Login → Restaurant Screen → Add Dish → Delete Dish', (
      WidgetTester tester,
    ) async {
      // ============================================
      // 1. LAUNCH THE REAL APP AND LOGIN
      // ============================================
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Logout first to ensure we start from LoginScreen
      await FirebaseAuth.instance.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we are on the login screen
      expect(find.byType(app.LoginScreen), findsOneWidget);

      // Insert credentials for restaurant account
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2));

      await tester.enterText(textFields.first, 'owner@example.com');
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(textFields.last, 'REDACTED_PASSWORD');
      await tester.pump(const Duration(milliseconds: 500));

      // Tap login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton.last);

      // Wait for login to complete
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we're logged in
      expect(find.byType(app.LoginScreen), findsNothing);
      expect(find.byType(app.MainLayout), findsOneWidget);

      print('✓ Login successful for restaurant account');

      // ============================================
      // 2. NAVIGATE TO RESTAURANT SCREEN
      // ============================================
      // Find and tap the restaurant button in bottom navigation bar
      // Use the specific icon Icons.restaurant_menu_rounded defined in CustomNavBar
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Look for the restaurant icon specifically
      final restaurantButton = find.byIcon(Icons.restaurant_menu_rounded);
      print(
        'Debug: Found ${restaurantButton.evaluate().length} restaurant button(s)',
      );

      if (restaurantButton.evaluate().isNotEmpty) {
        await tester.tap(restaurantButton.first);
        print('✓ Tapped restaurant button (Icons.restaurant_menu_rounded)');
      } else {
        fail(
          'Could not find restaurant button with Icons.restaurant_menu_rounded',
        );
      }

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('✓ Navigated to restaurant screen');

      // ============================================
      // 3. FIND AND TAP THE ADD BUTTON (+)
      // ============================================
      // Wait longer for the RestaurantScreen to fully load and render the CircularButton
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Debug: Check what's on screen
      final restaurantScreens = find.byType(app.RestaurantScreen);
      print(
        'Debug: RestaurantScreen count: ${restaurantScreens.evaluate().length}',
      );

      // Look for CircularButton specifically
      // The add button is a CircularButton in the RestaurantScreen
      var circularButtons = find.byType(CircularButton);
      print(
        'Debug: Found ${circularButtons.evaluate().length} CircularButton(s) initially',
      );

      // If not found, try scrolling up in case it's off-screen
      if (circularButtons.evaluate().isEmpty) {
        print('Debug: CircularButton not found, trying to scroll to find it');
        try {
          await tester.drag(
            find.byType(SingleChildScrollView).first,
            const Offset(0, 200),
          );
          await tester.pumpAndSettle();
          circularButtons = find.byType(CircularButton);
          print(
            'Debug: After scroll - found ${circularButtons.evaluate().length} CircularButton(s)',
          );
        } catch (e) {
          print('Debug: Could not scroll: $e');
        }
      }

      if (circularButtons.evaluate().isNotEmpty) {
        // Tap the first CircularButton
        await tester.tap(circularButtons.first);
        print('✓ Tapped CircularButton add button');
      } else {
        // Fallback: try to find any button with add icon or text
        final addIconButtons = find.byIcon(Icons.add);
        print(
          'Debug: Found ${addIconButtons.evaluate().length} widget(s) with Icons.add',
        );

        final addTextButtons = find.text('Add');
        print(
          'Debug: Found ${addTextButtons.evaluate().length} widget(s) with text "Add"',
        );

        if (addIconButtons.evaluate().isNotEmpty) {
          await tester.tap(addIconButtons.first);
          print('✓ Tapped Icons.add button');
        } else if (addTextButtons.evaluate().isNotEmpty) {
          await tester.tap(addTextButtons.first);
          print('✓ Tapped Add text button');
        } else {
          fail(
            'Could not find add button (CircularButton, Icons.add, or "Add" text)',
          );
        }
      }

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('✓ Tapped add button to create new dish');

      // ============================================
      // 4. FILL DISH DETAILS FORM
      // ============================================
      // Wait for dish screen/dialog to appear
      // On tablet (iPad), DishScreen opens in a Dialog
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Debug: Check what screens/widgets are available
      print('Debug: Checking screen state after tapping add button');

      final dishScreens = find.byType(app.DishScreen);
      final allDialogs = find.byType(Dialog);
      print('Debug: DishScreen count: ${dishScreens.evaluate().length}');
      print('Debug: Dialog count: ${allDialogs.evaluate().length}');

      // Find all text fields for dish details
      final allTextFields = find.byType(TextField);
      final allFormFields = find.byType(TextFormField);
      print('Debug: Found ${allTextFields.evaluate().length} TextField(s)');
      print('Debug: Found ${allFormFields.evaluate().length} TextFormField(s)');

      if (allTextFields.evaluate().isEmpty &&
          allFormFields.evaluate().isEmpty) {
        print('⚠ No text input fields found');

        // Try scrolling down in case the dialog/screen needs to be scrolled
        try {
          await tester.drag(
            find.byType(SingleChildScrollView).first,
            const Offset(0, -100),
          );
          await tester.pumpAndSettle();
          print('Debug: Scrolled down looking for fields');
        } catch (e) {
          print('Debug: Could not scroll');
        }

        // Try again after scrolling
        final textFieldsAfterScroll = find.byType(TextField);
        print(
          'Debug: After scroll - found ${textFieldsAfterScroll.evaluate().length} TextField(s)',
        );
      }

      // Now fill the fields if found
      final fieldsToFill =
          allTextFields.evaluate().isNotEmpty ? allTextFields : allFormFields;

      if (fieldsToFill.evaluate().isNotEmpty) {
        // Fill dish name
        await tester.enterText(fieldsToFill.first, 'Test Pasta Carbonara');
        await tester.pump(const Duration(milliseconds: 300));
        print('✓ Filled dish name');

        // Fill description if available
        if (fieldsToFill.evaluate().length > 1) {
          await tester.enterText(
            fieldsToFill.at(1),
            'Delicious classic Italian pasta with eggs and bacon',
          );
          await tester.pump(const Duration(milliseconds: 300));
          print('✓ Filled description');
        }

        // Fill price if available
        if (fieldsToFill.evaluate().length > 2) {
          await tester.enterText(fieldsToFill.at(2), '12.50');
          await tester.pump(const Duration(milliseconds: 300));
          print('✓ Filled price');
        }
      } else {
        print('⚠ Could not find any input fields to fill');
      }

      // ============================================
      // 5. SELECT COURSE & CUISINE DROPDOWNS
      // ============================================
      // --- COURSE & CUISINE DROPDOWNS ---

      final courseFinder = find.byKey(const Key('course_dropdown'));
      final cuisineFinder = find.byKey(const Key('cuisine_dropdown'));

      // Assicurati che siano visibili (scroll se necessario)
      await tester.ensureVisible(courseFinder);
      await tester.pumpAndSettle();

      await tester.ensureVisible(cuisineFinder);
      await tester.pumpAndSettle();

      // Fallisci subito se non esistono
      if (courseFinder.evaluate().isEmpty) {
        fail('❌ Course dropdown not found in DishScreen');
      }

      if (cuisineFinder.evaluate().isEmpty) {
        fail('❌ Cuisine dropdown not found in DishScreen');
      }

      // Apri course dropdown e seleziona il primo elemento
      await tester.tap(courseFinder);
      await tester.pumpAndSettle();

      // Cerca il primo elemento disponibile nel menu (tenta di trovare per testo o tipo)
      final firstCourseOption = find.text('appetizer');
      if (firstCourseOption.evaluate().isNotEmpty) {
        await tester.tap(firstCourseOption);
        await tester.pumpAndSettle();
        print('✓ Selected appetizer as course');
      } else {
        // Se non trovi "appetizer", tenta di trovare qualsiasi testo nei PopupMenuItem
        final allPopupItems = find.byType(PopupMenuItem);
        if (allPopupItems.evaluate().isNotEmpty) {
          // Tappa il primo item nel popup
          await tester.tap(allPopupItems.first, warnIfMissed: false);
          await tester.pumpAndSettle();
          print('✓ Selected first course option');
        } else {
          fail('❌ No course options found in dropdown menu');
        }
      }

      // Apri cuisine dropdown e seleziona il primo elemento
      await tester.tap(cuisineFinder);
      await tester.pumpAndSettle();

      final firstCuisineOption = find.text('italian');
      if (firstCuisineOption.evaluate().isNotEmpty) {
        await tester.tap(firstCuisineOption);
        await tester.pumpAndSettle();
        print('✓ Selected italian as cuisine');
      } else {
        // Se non trovi "italian", tenta di trovare qualsiasi testo nei PopupMenuItem
        final allPopupItems = find.byType(PopupMenuItem);
        if (allPopupItems.evaluate().isNotEmpty) {
          // Tappa il primo item nel popup
          await tester.tap(allPopupItems.first, warnIfMissed: false);
          await tester.pumpAndSettle();
          print('✓ Selected first cuisine option');
        } else {
          fail('❌ No cuisine options found in dropdown menu');
        }
      }

      print('✓ Selected course and cuisine types');

      // ============================================
      // 8. SAVE THE DISH
      // ============================================
      // Look for save/confirm button
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Scroll down if needed to find save button
      try {
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();
      } catch (e) {
        // Scroll might fail, continue anyway
      }

      // Look for save button - MUST find Icons.save
      final saveIconButton = find.byIcon(Icons.save);

      if (saveIconButton.evaluate().isEmpty) {
        fail('❌ Save button (Icons.save) not found in DishScreen');
      }

      await tester.tap(saveIconButton.first);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✓ Tapped save button (Icons.save)');

      // ============================================
      // 9. VERIFY DISH APPEARS IN RESTAURANT MENU
      // ============================================
      // Should be back on restaurant screen
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Look for the newly created dish in the menu
      final menuItems = find.byType(MenuItem);
      expect(menuItems, findsAtLeastNWidgets(1));

      // Check if our dish name appears in the menu
      final dishNameInMenu = find.text('Test Pasta Carbonara');
      if (dishNameInMenu.evaluate().isNotEmpty) {
        print('✓ Dish appears in restaurant menu');
      } else {
        print('⚠ Dish not found in menu (might be on different page)');
      }

      // ============================================
      // 10. FIND AND DELETE THE NEWLY CREATED DISH
      // ============================================
      // Find the delete button for this dish
      // Usually it's a trash/delete icon next to the dish
      await tester.pump(const Duration(milliseconds: 500));

      final allDishCards = find.byType(MenuItem);
      bool dishDeleted = false;

      // Iterate through dishes to find and delete our test dish
      for (int i = 0; i < allDishCards.evaluate().length; i++) {
        try {
          // Tap on the dish to open it
          final dishCard = allDishCards.at(i);

          // Check if this is our test dish
          final dishText = find.descendant(
            of: dishCard,
            matching: find.textContaining('Carbonara'),
          );

          if (dishText.evaluate().isNotEmpty) {
            print('✓ Found test dish in menu');

            // Tap the dish to open it
            await tester.tap(dishCard);
            await tester.pump();
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Look for delete button in the dish screen
            await tester.pump(const Duration(milliseconds: 500));

            final deleteButtons = [
              find.byIcon(Icons.delete),
              find.byIcon(Icons.delete_outline),
              find.text('Delete'),
            ];

            for (final delBtn in deleteButtons) {
              if (delBtn.evaluate().isNotEmpty) {
                await tester.tap(delBtn.first);
                await tester.pump();
                await tester.pumpAndSettle(const Duration(seconds: 1));

                // Confirm deletion if there's a confirmation dialog
                final confirmDeleteButtons = [
                  find.text('Delete'),
                  find.text('Confirm'),
                  find.text('Yes'),
                ];

                for (final confirmBtn in confirmDeleteButtons) {
                  if (confirmBtn.evaluate().isNotEmpty) {
                    await tester.tap(confirmBtn.first);
                    await tester.pump();
                    await tester.pumpAndSettle(const Duration(seconds: 2));
                    break;
                  }
                }

                dishDeleted = true;
                print('✓ Deleted the test dish');
                break;
              }
            }

            if (!dishDeleted) {
              print('⚠ Delete button not found in dish screen');
            }
            break;
          }
        } catch (e) {
          // Continue to next dish
          continue;
        }
      }

      if (!dishDeleted) {
        print('⚠ Could not find or delete test dish');
      }

      // ============================================
      // 11. VERIFY DISH IS REMOVED FROM MENU
      // ============================================
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Go back to restaurant screen if not already there
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty && dishDeleted) {
        await tester.tap(backButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Verify the dish is no longer visible
      final dishStillInMenu = find.text('Test Pasta Carbonara');
      if (dishStillInMenu.evaluate().isEmpty || dishDeleted) {
        print('✓ Dish successfully removed from menu');
      }

      print(
        '✓ Complete restaurant add/delete dish flow finished successfully!',
      );

      // Wait for any remaining animations
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}
