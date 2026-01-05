import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/auth/auth_input_field.dart';

import '../helpers/pump_app.dart';

void main() {
  group('AuthInputField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(textEditingController: controller, hintText: 'Email'),
      );

      expect(find.byType(AuthInputField), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(
          textEditingController: controller,
          hintText: 'Enter your email',
        ),
      );

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(textEditingController: controller, hintText: 'Email'),
      );

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('renders with leftIcon', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(
          textEditingController: controller,
          hintText: 'Email',
          leftIcon: Icons.email,
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('obscures text when isPassword is true', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(
          textEditingController: controller,
          hintText: 'Password',
          isPassword: true,
        ),
      );

      // Check that visibility_off icon is shown (indicating text is obscured)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('does not obscure text by default', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(textEditingController: controller, hintText: 'Email'),
      );

      // Non-password fields don't have visibility toggle icons
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets('shows visibility toggle for password field', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(
          textEditingController: controller,
          hintText: 'Password',
          isPassword: true,
        ),
      );

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('toggles password visibility on icon tap', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(
          textEditingController: controller,
          hintText: 'Password',
          isPassword: true,
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

    testWidgets('renders with hasError true', (tester) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(
          textEditingController: controller,
          hintText: 'Email',
          hasError: true,
        ),
      );

      expect(find.byType(AuthInputField), findsOneWidget);
    });

    testWidgets('renders without visibility toggle for non-password field', (
      tester,
    ) async {
      await tester.pumpAppWithScaffold(
        AuthInputField(
          textEditingController: controller,
          hintText: 'Email',
          isPassword: false,
        ),
      );

      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });
  });
}
