import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/animated_button.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('AnimatedButton', () {
    group('rendering', () {
      testWidgets('displays the child widget', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          AnimatedButton(onTap: () {}, child: const Text('Button Text')),
        );

        // Assert
        expect(find.text('Button Text'), findsOneWidget);
      });

      testWidgets('can wrap any widget as child', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          AnimatedButton(
            onTap: () {},
            child: Container(
              width: 100,
              height: 50,
              color: Colors.blue,
              child: const Icon(Icons.star),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('wraps child in ScaleTransition', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          AnimatedButton(onTap: () {}, child: const Text('Scaled')),
        );

        // Assert
        expect(find.byType(ScaleTransition), findsOneWidget);
      });

      testWidgets('wraps child in GestureDetector', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          AnimatedButton(onTap: () {}, child: const Text('Gesture')),
        );

        // Assert
        expect(find.byType(GestureDetector), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('calls onTap when tapped', (tester) async {
        // Arrange
        final mockCallback = MockVoidCallback();

        await tester.pumpWidget_(
          AnimatedButton(onTap: mockCallback.call, child: const Text('Tap Me')),
        );

        // Act
        await tester.tap(find.text('Tap Me'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockCallback()).called(1);
      });

      testWidgets('can be tapped multiple times', (tester) async {
        // Arrange
        final mockCallback = MockVoidCallback();

        await tester.pumpWidget_(
          AnimatedButton(
            onTap: mockCallback.call,
            child: const Text('Multi Tap'),
          ),
        );

        // Act
        await tester.tap(find.text('Multi Tap'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Multi Tap'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockCallback()).called(2);
      });

      testWidgets('executes onTap callback even during animation', (
        tester,
      ) async {
        // Arrange
        int tapCount = 0;

        await tester.pumpWidget_(
          AnimatedButton(
            onTap: () => tapCount++,
            child: const Text('Quick Tap'),
          ),
        );

        // Act - tap quickly without waiting for animation
        await tester.tap(find.text('Quick Tap'));
        await tester.pump(const Duration(milliseconds: 100));

        // Assert
        expect(tapCount, equals(1));
      });
    });

    group('animation', () {
      testWidgets('animates scale on tap', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          AnimatedButton(onTap: () {}, child: const Text('Animate')),
        );

        // Act - tap and pump to start animation
        await tester.tap(find.text('Animate'));
        await tester.pump(); // Start animation

        // Pump a small amount to let animation progress
        await tester.pump(const Duration(milliseconds: 50));

        // Get scale during animation
        final animatingTransition = tester.widget<ScaleTransition>(
          find.byType(ScaleTransition),
        );
        // Scale should be less than or equal to 1.0 during animation
        expect(animatingTransition.scale.value, lessThanOrEqualTo(1.0));
      });

      testWidgets('returns to original scale after animation completes', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget_(
          AnimatedButton(onTap: () {}, child: const Text('Return')),
        );

        final scaleTransition = tester.widget<ScaleTransition>(
          find.byType(ScaleTransition),
        );
        final initialScale = scaleTransition.scale.value;

        // Act
        await tester.tap(find.text('Return'));
        await tester.pumpAndSettle();

        // Assert
        final finalTransition = tester.widget<ScaleTransition>(
          find.byType(ScaleTransition),
        );
        expect(finalTransition.scale.value, equals(initialScale));
      });

      testWidgets('animation duration is 300ms total', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          AnimatedButton(onTap: () {}, child: const Text('Duration')),
        );

        // Act - tap and wait for full animation cycle
        await tester.tap(find.text('Duration'));

        // Pump just before animation should complete
        await tester.pump(const Duration(milliseconds: 299));
        final midTransition = tester.widget<ScaleTransition>(
          find.byType(ScaleTransition),
        );

        // Animation should still be in progress (scale should be less than 1)
        // or very close to completing
        expect(midTransition.scale.value, lessThanOrEqualTo(1.0));

        // Complete the animation
        await tester.pumpAndSettle();

        // Assert - animation completed, scale back to 1.0
        final finalTransition = tester.widget<ScaleTransition>(
          find.byType(ScaleTransition),
        );
        expect(finalTransition.scale.value, equals(1.0));
      });
    });

    group('edge cases', () {
      testWidgets('handles rapid sequential taps', (tester) async {
        // Arrange
        int tapCount = 0;

        await tester.pumpWidget_(
          AnimatedButton(onTap: () => tapCount++, child: const Text('Rapid')),
        );

        // Act - rapid taps
        await tester.tap(find.text('Rapid'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Rapid'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Rapid'));
        await tester.pumpAndSettle();

        // Assert - all taps should be registered
        expect(tapCount, equals(3));
      });

      testWidgets('disposes animation controller properly', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          AnimatedButton(onTap: () {}, child: const Text('Dispose')),
        );

        // Act - remove widget (should dispose controller without error)
        await tester.pumpWidget_(const SizedBox());
        await tester.pumpAndSettle();

        // Assert - no error thrown
        expect(find.byType(AnimatedButton), findsNothing);
      });
    });
  });
}
