import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/auth/password_field_signup.dart';

import '../helpers/pump_app.dart';

void main() {
  group('PasswordFieldSignup', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        PasswordFieldSignup(
          textEditingController: controller,
          hintText: 'Password',
          hasError: false,
        ),
      );

      expect(find.byType(PasswordFieldSignup), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpAppWithScaffold(
        PasswordFieldSignup(
          textEditingController: controller,
          hintText: 'Enter password',
          hasError: false,
        ),
      );

      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('obscures text by default', (tester) async {
      await tester.pumpAppWithScaffold(
        PasswordFieldSignup(
          textEditingController: controller,
          hintText: 'Password',
          hasError: false,
        ),
      );

      // Check that visibility_off icon is shown (indicating text is obscured)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('toggles password visibility on icon tap', (tester) async {
      await tester.pumpAppWithScaffold(
        PasswordFieldSignup(
          textEditingController: controller,
          hintText: 'Password',
          hasError: false,
        ),
      );

      // Initially visibility_off icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // Now visibility icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpAppWithScaffold(
        PasswordFieldSignup(
          textEditingController: controller,
          hintText: 'Password',
          hasError: false,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test123');
      expect(controller.text, 'test123');
    });

    testWidgets('renders with error state', (tester) async {
      await tester.pumpAppWithScaffold(
        PasswordFieldSignup(
          textEditingController: controller,
          hintText: 'Password',
          hasError: true,
        ),
      );

      expect(find.byType(PasswordFieldSignup), findsOneWidget);
      // Widget should still render with error state
    });

    testWidgets('has visibility toggle icon', (tester) async {
      await tester.pumpAppWithScaffold(
        PasswordFieldSignup(
          textEditingController: controller,
          hintText: 'Password',
          hasError: false,
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
