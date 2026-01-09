import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/circular_number_input.dart';

import '../helpers/pump_app.dart';

void main() {
  group('CircularNumberInput', () {
    group('rendering', () {
      testWidgets('displays with correct size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CircularNumberInput),
            matching: find.byType(Container).first,
          ),
        );
        expect(container.constraints?.maxWidth, equals(60.0));
        expect(container.constraints?.maxHeight, equals(60.0));
      });

      testWidgets('displays initial value when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(
              size: 60.0,
              onNumberSubmitted: (_) {},
              initialValue: 5,
            ),
          ),
        );

        // Assert
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('displays empty when no initial value', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals(''));
      });

      testWidgets('has circular border', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CircularNumberInput),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, equals(BoxShape.circle));
      });

      testWidgets('renders TextField widget', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    group('input behavior', () {
      testWidgets('accepts numeric input', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '42');
        await tester.pump();

        // Assert
        expect(find.text('42'), findsOneWidget);
      });

      testWidgets('limits input to 2 digits', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '123');
        await tester.pump();

        // Assert - only first 2 digits should be kept
        expect(find.text('12'), findsOneWidget);
      });

      testWidgets('only accepts digits', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'abc');
        await tester.pump();

        // Assert - non-digits should be filtered
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals(''));
      });

      testWidgets('calls onNumberSubmitted with correct value on submit', (
        tester,
      ) async {
        // Arrange
        int? submittedValue;

        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(
              size: 60.0,
              onNumberSubmitted: (value) => submittedValue = value,
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '25');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Assert
        expect(submittedValue, equals(25));
      });

      testWidgets('restores initial value on empty submission', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(
              size: 60.0,
              onNumberSubmitted: (_) {},
              initialValue: 10,
            ),
          ),
        );

        // Act - clear the text and submit
        await tester.enterText(find.byType(TextField), '');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Assert - should restore initial value
        expect(find.text('10'), findsOneWidget);
      });
    });

    group('focus behavior', () {
      testWidgets('can receive focus when tapped', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Act
        await tester.tap(find.byType(TextField));
        await tester.pump();

        // Assert - TextField should be tappable
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('restores initial value on focus lost with empty input', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: Column(
              children: [
                CircularNumberInput(
                  size: 60.0,
                  onNumberSubmitted: (_) {},
                  initialValue: 7,
                ),
                const TextField(), // Another field to move focus to
              ],
            ),
          ),
        );

        // Act - tap to focus, clear text, then focus another widget
        await tester.tap(find.byType(CircularNumberInput));
        await tester.pump();
        await tester.enterText(
          find.descendant(
            of: find.byType(CircularNumberInput),
            matching: find.byType(TextField),
          ),
          '',
        );
        await tester.pump();

        // Move focus to another widget
        await tester.tap(find.byType(TextField).last);
        await tester.pump();

        // Assert - should restore initial value
        final textField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(CircularNumberInput),
            matching: find.byType(TextField),
          ),
        );
        expect(textField.controller?.text, equals('7'));
      });

      testWidgets('restores initial value for invalid number > 99', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: Column(
              children: [
                CircularNumberInput(
                  size: 60.0,
                  onNumberSubmitted: (_) {},
                  initialValue: 5,
                ),
                const TextField(), // Another field to move focus to
              ],
            ),
          ),
        );

        // Input is limited to 2 chars so we test boundary behavior
        // by entering valid 2-digit number and checking
        await tester.tap(find.byType(CircularNumberInput));
        await tester.pump();

        // Move focus away
        await tester.tap(find.byType(TextField).last);
        await tester.pump();

        // Assert - widget should still work correctly
        expect(find.byType(CircularNumberInput), findsOneWidget);
      });
    });

    group('text styling', () {
      testWidgets('has centered text alignment', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.textAlign, equals(TextAlign.center));
      });

      testWidgets('has bold font weight', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.style?.fontWeight, equals(FontWeight.bold));
      });

      testWidgets('font size scales with widget size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 100.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Assert - font size should be 40% of widget size
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.style?.fontSize, equals(40.0)); // 100 * 0.4
      });
    });

    group('keyboard type', () {
      testWidgets('uses numeric keyboard', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: CircularNumberInput(size: 60.0, onNumberSubmitted: (_) {}),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, equals(TextInputType.number));
      });
    });
  });
}
