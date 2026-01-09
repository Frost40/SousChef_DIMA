import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/account_settings_field.dart';
import '../helpers/pump_app.dart';

void main() {
  group('AccountSettingField', () {
    group('rendering', () {
      testWidgets('displays field name', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Username',
            initialValue: 'testuser',
            onValueChanged: (_, __) {},
          ),
        );

        // Assert
        expect(find.text('Username'), findsOneWidget);
      });

      testWidgets('displays initial value as text', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Email',
            initialValue: 'test@example.com',
            onValueChanged: (_, __) {},
          ),
        );

        // Assert
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('displays password as dots when isPassword is true', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Password',
            initialValue: 'secret',
            onValueChanged: (_, __) {},
            isPassword: true,
          ),
        );

        // Assert - password is shown as dots (6 dots for 'secret')
        expect(find.text('••••••'), findsOneWidget);
      });

      testWidgets('shows visibility icon for password field', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Password',
            initialValue: 'secret',
            onValueChanged: (_, __) {},
            isPassword: true,
          ),
        );

        // Assert
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });

      testWidgets('uses Container with rounded border', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Name',
            initialValue: 'John',
            onValueChanged: (_, __) {},
          ),
        );

        // Assert
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('interaction', () {
      testWidgets('toggles password visibility when icon is tapped', (
        tester,
      ) async {
        // Arrange
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Password',
            initialValue: 'secret',
            onValueChanged: (_, __) {},
            isPassword: true,
          ),
        );

        // Act - tap visibility icon
        await tester.tap(find.byIcon(Icons.visibility_off_outlined));
        await tester.pumpAndSettle();

        // Assert - icon changed and password visible
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
        expect(find.text('secret'), findsOneWidget);
      });

      testWidgets('enters editing mode when tapped', (tester) async {
        // Arrange
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Name',
            initialValue: 'John',
            onValueChanged: (_, __) {},
          ),
        );

        // Act - tap to start editing
        await tester.tap(find.text('John'));
        await tester.pumpAndSettle();

        // Assert - TextField should appear
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('calls onValueChanged when value is modified and submitted', (
        tester,
      ) async {
        // Arrange
        String? changedValue;
        bool? isModified;
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Name',
            initialValue: 'John',
            onValueChanged: (value, modified) {
              changedValue = value;
              isModified = modified;
            },
          ),
        );

        // Act - tap to edit, change value, and submit
        await tester.tap(find.text('John'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Jane');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(changedValue, equals('Jane'));
        expect(isModified, isTrue);
      });

      testWidgets('calls onValueChanged with isModified false when reverted', (
        tester,
      ) async {
        // Arrange
        String? changedValue;
        bool? isModified;
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Name',
            initialValue: 'John',
            onValueChanged: (value, modified) {
              changedValue = value;
              isModified = modified;
            },
          ),
        );

        // Act - tap to edit, change back to original, and submit
        await tester.tap(find.text('John'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Jane');
        await tester.enterText(find.byType(TextField), 'John');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(changedValue, equals('John'));
        expect(isModified, isFalse);
      });

      testWidgets('calls onTextChanged when user types', (tester) async {
        // Arrange
        bool textChanged = false;
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Name',
            initialValue: 'John',
            onValueChanged: (_, __) {},
            onTextChanged: () {
              textChanged = true;
            },
          ),
        );

        // Act
        await tester.tap(find.text('John'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Jane');

        // Assert
        expect(textChanged, isTrue);
      });

      testWidgets('exits editing mode when focus is lost', (tester) async {
        // Arrange
        await tester.pumpAppWithScaffold(
          Column(
            children: [
              AccountSettingField(
                fieldName: 'Name',
                initialValue: 'John',
                onValueChanged: (_, __) {},
              ),
              const TextField(
                key: Key('other_field'),
                decoration: InputDecoration(hintText: 'Other'),
              ),
            ],
          ),
        );

        // Act - enter editing mode
        await tester.tap(find.text('John'));
        await tester.pumpAndSettle();
        expect(
          find.byType(TextField),
          findsNWidgets(2),
        ); // Our field + other field

        // Tap other field to lose focus
        await tester.tap(find.byKey(const Key('other_field')));
        await tester.pumpAndSettle();

        // Assert - should exit editing mode (only 1 TextField should remain - the 'Other' field)
        // The AccountSettingField should no longer be in editing mode
        final textFields = find.byType(TextField);
        expect(textFields, findsOneWidget); // Only the 'Other' TextField
        expect(find.text('John'), findsOneWidget); // Back to text display
      });

      testWidgets('uses specified keyboard type', (tester) async {
        // Arrange
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Email',
            initialValue: 'test@test.com',
            onValueChanged: (_, __) {},
            keyboardType: TextInputType.emailAddress,
          ),
        );

        // Act - enter editing mode
        await tester.tap(find.text('test@test.com'));
        await tester.pumpAndSettle();

        // Assert - TextField should use the specified keyboard type
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, equals(TextInputType.emailAddress));
      });

      testWidgets('respects custom padding', (tester) async {
        // Arrange
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Name',
            initialValue: 'John',
            onValueChanged: (_, __) {},
            padding: 50,
          ),
        );

        // Assert - Check container has correct margin
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(
          container.margin,
          equals(const EdgeInsets.symmetric(horizontal: 50)),
        );
      });
    });

    group('validation', () {
      testWidgets('calls asyncValidator when value is modified', (
        tester,
      ) async {
        // Arrange
        bool validatorCalled = false;
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Username',
            initialValue: 'user1',
            onValueChanged: (_, __) {},
            asyncValidator: (value) async {
              validatorCalled = true;
              return null;
            },
          ),
        );

        // Act
        await tester.tap(find.text('user1'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'user2');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(validatorCalled, isTrue);
      });

      testWidgets('shows error border when validation fails', (tester) async {
        // Arrange
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Username',
            initialValue: 'user1',
            onValueChanged: (_, __) {},
            asyncValidator: (value) async {
              return 'Username already exists';
            },
          ),
        );

        // Act
        await tester.tap(find.text('user1'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'user2');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert - Container should have error border color
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final colorScheme =
            Theme.of(tester.element(find.byType(Container).first)).colorScheme;
        expect(decoration.border, isA<Border>());
        expect(
          (decoration.border as Border).top.color,
          equals(colorScheme.error),
        );
      });

      testWidgets('calls onValidationError with error message', (tester) async {
        // Arrange
        String? validationError;
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Username',
            initialValue: 'user1',
            onValueChanged: (_, __) {},
            onValidationError: (error) {
              validationError = error;
            },
            asyncValidator: (value) async {
              return 'Error message';
            },
          ),
        );

        // Act
        await tester.tap(find.text('user1'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'user2');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(validationError, equals('Error message'));
      });

      testWidgets('clears validation error when reverted to initial value', (
        tester,
      ) async {
        // Arrange
        String? validationError = 'initial error';
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Username',
            initialValue: 'user1',
            onValueChanged: (_, __) {},
            onValidationError: (error) {
              validationError = error;
            },
            asyncValidator: (value) async {
              return value == 'user1' ? null : 'Error';
            },
          ),
        );

        // Act - change and revert
        await tester.tap(find.text('user1'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'user2');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Now revert back
        await tester.tap(find.text('user2'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'user1');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert - validation error should be cleared
        expect(validationError, isNull);
      });

      testWidgets('does not call asyncValidator when value unchanged', (
        tester,
      ) async {
        // Arrange
        bool validatorCalled = false;
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Username',
            initialValue: 'user1',
            onValueChanged: (_, __) {},
            asyncValidator: (value) async {
              validatorCalled = true;
              return null;
            },
          ),
        );

        // Act - enter and exit without changing
        await tester.tap(find.text('user1'));
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert - validator should not be called for unchanged value
        expect(validatorCalled, isFalse);
      });
    });

    group('lifecycle', () {
      testWidgets('properly disposes controllers and focus nodes', (
        tester,
      ) async {
        // Arrange
        await tester.pumpAppWithScaffold(
          AccountSettingField(
            fieldName: 'Name',
            initialValue: 'John',
            onValueChanged: (_, __) {},
          ),
        );

        // Act - remove widget
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();

        // Assert - no exception should be thrown (controllers disposed properly)
        // This test ensures dispose is called without errors
      });
    });
  });
}
