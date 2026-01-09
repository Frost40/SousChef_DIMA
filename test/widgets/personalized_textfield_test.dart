import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/personalized_textfield.dart';

import '../helpers/pump_app.dart';

void main() {
  group('PersonalizedTextField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('rendering', () {
      testWidgets('displays the hint text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Enter your email',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Assert
        expect(find.text('Enter your email'), findsOneWidget);
      });

      testWidgets('renders as a TextFormField', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Test',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Assert
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('is wrapped in Padding with horizontal 25', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Padded',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Assert
        final padding = tester.widget<Padding>(
          find.descendant(
            of: find.byType(PersonalizedTextField),
            matching: find.byType(Padding),
          ),
        );
        expect(
          padding.padding,
          equals(const EdgeInsets.symmetric(horizontal: 25.0)),
        );
      });
    });

    group('text input', () {
      testWidgets('accepts text input', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Type here',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextFormField), 'Hello World');
        await tester.pump();

        // Assert
        expect(controller.text, equals('Hello World'));
      });

      testWidgets('displays text from controller', (tester) async {
        // Arrange
        controller.text = 'Pre-filled text';

        // Act
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Hint',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Assert
        expect(find.text('Pre-filled text'), findsOneWidget);
      });

      testWidgets('clears text when controller is cleared', (tester) async {
        // Arrange
        controller.text = 'Initial text';

        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Hint',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Act
        controller.clear();
        await tester.pump();

        // Assert
        expect(find.text('Initial text'), findsNothing);
      });
    });

    group('obscureText', () {
      testWidgets('hides text when obscureText is true', (tester) async {
        // Arrange
        controller.text = 'secret';

        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Password',
              obscureText: true,
              hasError: false,
            ),
          ),
        );

        // Assert - the EditableText should have obscureText property
        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.obscureText, isTrue);
      });

      testWidgets('shows text when obscureText is false', (tester) async {
        // Arrange
        controller.text = 'visible';

        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Email',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Assert
        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.obscureText, isFalse);
      });
    });

    group('error state', () {
      testWidgets('widget builds correctly with hasError true', (tester) async {
        // Arrange & Act - should not throw
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Error field',
              obscureText: false,
              hasError: true,
            ),
          ),
        );

        // Assert - widget renders without error
        expect(find.byType(PersonalizedTextField), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('widget builds correctly with hasError false', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Normal field',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Assert
        expect(find.byType(PersonalizedTextField), findsOneWidget);
      });
    });

    group('validation', () {
      testWidgets('validator returns Required for empty input', (tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget_(
          Scaffold(
            body: Form(
              key: formKey,
              child: PersonalizedTextField(
                controller: controller,
                hintText: 'Required field',
                obscureText: false,
                hasError: false,
              ),
            ),
          ),
        );

        // Act
        formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(find.text('Required'), findsOneWidget);
      });

      testWidgets('validator returns null for non-empty input', (tester) async {
        // Arrange
        controller.text = 'Valid input';
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget_(
          Scaffold(
            body: Form(
              key: formKey,
              child: PersonalizedTextField(
                controller: controller,
                hintText: 'Required field',
                obscureText: false,
                hasError: false,
              ),
            ),
          ),
        );

        // Act
        final isValid = formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(isValid, isTrue);
        expect(find.text('Required'), findsNothing);
      });
    });

    group('focus', () {
      testWidgets('can receive focus when tapped', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Focus me',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(TextFormField));
        await tester.pump();

        // Assert - field should be tappable without error
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('can enter text after focus', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: PersonalizedTextField(
              controller: controller,
              hintText: 'Focus and type',
              obscureText: false,
              hasError: false,
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(TextFormField));
        await tester.pump();
        await tester.enterText(find.byType(TextFormField), 'Typed text');
        await tester.pump();

        // Assert
        expect(controller.text, equals('Typed text'));
      });
    });
  });
}
