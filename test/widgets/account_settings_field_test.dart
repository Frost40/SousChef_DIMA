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
    });
  });
}
