import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/personalized_button.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('PersonalizedButton', () {
    group('rendering', () {
      testWidgets('displays the provided text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          const PersonalizedButton(text: 'Click Me', onPressed: null),
        );

        // Assert
        expect(find.text('Click Me'), findsOneWidget);
      });

      testWidgets('displays centralWidget when provided instead of text', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget_(
          PersonalizedButton(
            text: 'Hidden Text',
            onPressed: () {},
            centralWidget: const Icon(Icons.add),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('Hidden Text'), findsNothing);
      });

      testWidgets('renders with correct theme colors', (tester) async {
        // Arrange
        final customTheme = ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
          ),
        );

        // Act
        await tester.pumpWidget_(
          const PersonalizedButton(text: 'Themed Button', onPressed: null),
          theme: customTheme,
        );

        // Assert
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(PersonalizedButton),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.blue));
      });

      testWidgets('has correct border radius', (tester) async {
        // Act
        await tester.pumpWidget_(
          const PersonalizedButton(text: 'Rounded Button', onPressed: null),
        );

        // Assert
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(PersonalizedButton),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, equals(BorderRadius.circular(25.0)));
      });
    });

    group('interaction', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        // Arrange
        final mockCallback = MockVoidCallback();

        await tester.pumpWidget_(
          PersonalizedButton(text: 'Tap Me', onPressed: mockCallback.call),
        );

        // Act
        await tester.tap(find.text('Tap Me'));
        await tester.pump();

        // Assert
        verify(() => mockCallback()).called(1);
      });

      testWidgets('does not crash when onPressed is null', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          const PersonalizedButton(text: 'Disabled Button', onPressed: null),
        );

        // Act & Assert - should not throw
        await tester.tap(find.text('Disabled Button'));
        await tester.pump();
      });

      testWidgets('can be tapped multiple times', (tester) async {
        // Arrange
        final mockCallback = MockVoidCallback();

        await tester.pumpWidget_(
          PersonalizedButton(text: 'Multi Tap', onPressed: mockCallback.call),
        );

        // Act
        await tester.tap(find.text('Multi Tap'));
        await tester.pump();
        await tester.tap(find.text('Multi Tap'));
        await tester.pump();
        await tester.tap(find.text('Multi Tap'));
        await tester.pump();

        // Assert
        verify(() => mockCallback()).called(3);
      });
    });

    group('accessibility', () {
      testWidgets('text is centered', (tester) async {
        // Act
        await tester.pumpWidget_(
          const PersonalizedButton(text: 'Centered Text', onPressed: null),
        );

        // Assert
        expect(
          find.descendant(
            of: find.byType(PersonalizedButton),
            matching: find.byType(Center),
          ),
          findsOneWidget,
        );
      });

      testWidgets('text has bold font weight', (tester) async {
        // Act
        await tester.pumpWidget_(
          const PersonalizedButton(text: 'Bold Text', onPressed: null),
        );

        // Assert
        final textWidget = tester.widget<Text>(find.text('Bold Text'));
        expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
      });
    });
  });
}
