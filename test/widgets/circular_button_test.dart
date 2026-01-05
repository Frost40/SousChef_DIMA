import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/circular_button.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('CircularButton', () {
    group('rendering', () {
      testWidgets('displays the provided icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, onPressed: () {}),
        );

        // Assert
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('renders with default size of 40', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, onPressed: () {}),
        );

        // Assert
        final ink = tester.widget<Ink>(find.byType(Ink));
        expect(ink.width, equals(40.0));
        expect(ink.height, equals(40.0));
      });

      testWidgets('renders with custom size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, size: 60.0, onPressed: () {}),
        );

        // Assert
        final ink = tester.widget<Ink>(find.byType(Ink));
        expect(ink.width, equals(60.0));
        expect(ink.height, equals(60.0));
      });

      testWidgets('uses custom icon color when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(
            icon: Icons.add,
            iconColor: Colors.red,
            onPressed: () {},
          ),
        );

        // Assert
        final icon = tester.widget<Icon>(find.byIcon(Icons.add));
        expect(icon.color, equals(Colors.red));
      });

      testWidgets('uses custom background color when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(
            icon: Icons.add,
            backgroundColor: Colors.green,
            onPressed: () {},
          ),
        );

        // Assert
        final ink = tester.widget<Ink>(find.byType(Ink));
        final decoration = ink.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.green));
      });

      testWidgets('has circular shape', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, onPressed: () {}),
        );

        // Assert
        final ink = tester.widget<Ink>(find.byType(Ink));
        final decoration = ink.decoration as BoxDecoration;
        expect(decoration.shape, equals(BoxShape.circle));
      });

      testWidgets('renders with custom elevation', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, elevation: 8.0, onPressed: () {}),
        );

        // Assert
        final material = tester.widget<Material>(find.byType(Material));
        expect(material.elevation, equals(8.0));
      });

      testWidgets('has bottom padding', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(
            icon: Icons.add,
            bottomPadding: 16.0,
            onPressed: () {},
          ),
        );

        // Assert - find the Padding that is direct child of CircularButton
        final paddingFinder = find.descendant(
          of: find.byType(CircularButton),
          matching: find.byType(Padding),
        );
        final padding = tester.widget<Padding>(paddingFinder.first);
        expect(padding.padding, equals(const EdgeInsets.only(bottom: 16.0)));
      });
    });

    group('interaction', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        // Arrange
        final mockCallback = MockVoidCallback();

        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, onPressed: mockCallback.call),
        );

        // Act
        await tester.tap(find.byType(CircularButton));
        await tester.pump();

        // Assert
        verify(() => mockCallback()).called(1);
      });

      testWidgets('does not crash when onPressed is null', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          const CircularButton(icon: Icons.add, onPressed: null),
        );

        // Act & Assert - should not throw
        await tester.tap(find.byType(CircularButton));
        await tester.pump();
      });

      testWidgets('can be tapped multiple times', (tester) async {
        // Arrange
        final mockCallback = MockVoidCallback();

        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, onPressed: mockCallback.call),
        );

        // Act
        await tester.tap(find.byType(CircularButton));
        await tester.pump();
        await tester.tap(find.byType(CircularButton));
        await tester.pump();

        // Assert
        verify(() => mockCallback()).called(2);
      });
    });

    group('theming', () {
      testWidgets('uses theme primary color as default background', (
        tester,
      ) async {
        // Arrange
        final theme = ThemeData(
          colorScheme: const ColorScheme.light(primary: Colors.purple),
        );

        // Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, onPressed: () {}),
          theme: theme,
        );

        // Assert
        final ink = tester.widget<Ink>(find.byType(Ink));
        final decoration = ink.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.purple));
      });

      testWidgets('uses theme onPrimary color as default icon color', (
        tester,
      ) async {
        // Arrange
        final theme = ThemeData(
          colorScheme: const ColorScheme.light(onPrimary: Colors.yellow),
        );

        // Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, onPressed: () {}),
          theme: theme,
        );

        // Assert
        final icon = tester.widget<Icon>(find.byIcon(Icons.add));
        expect(icon.color, equals(Colors.yellow));
      });
    });

    group('icon sizing', () {
      testWidgets('icon size is 60% of button size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, size: 100.0, onPressed: () {}),
        );

        // Assert
        final icon = tester.widget<Icon>(find.byIcon(Icons.add));
        expect(icon.size, equals(60.0)); // 100 * 0.6
      });

      testWidgets('icon size scales with button size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          CircularButton(icon: Icons.add, size: 50.0, onPressed: () {}),
        );

        // Assert
        final icon = tester.widget<Icon>(find.byIcon(Icons.add));
        expect(icon.size, equals(30.0)); // 50 * 0.6
      });
    });
  });
}
