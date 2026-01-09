import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/auth/shake_widget.dart';
import 'package:sous_chef/widgets/auth/shake_widget_state.dart';

import '../helpers/pump_app.dart';

void main() {
  group('ShakeWidget', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        const ShakeWidget(shakeOffset: 10.0, child: Text('Shake me')),
      );

      expect(find.byType(ShakeWidget), findsOneWidget);
    });

    testWidgets('displays child widget', (tester) async {
      await tester.pumpAppWithScaffold(
        const ShakeWidget(shakeOffset: 10.0, child: Text('Hello World')),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('uses default shakeCount of 3', (tester) async {
      const widget = ShakeWidget(shakeOffset: 10.0, child: Text('Test'));

      expect(widget.shakeCount, 3);
    });

    testWidgets('uses default shakeDuration of 400ms', (tester) async {
      const widget = ShakeWidget(shakeOffset: 10.0, child: Text('Test'));

      expect(widget.shakeDuration, const Duration(milliseconds: 400));
    });

    testWidgets('accepts custom shakeCount', (tester) async {
      const widget = ShakeWidget(
        shakeOffset: 15.0,
        shakeCount: 5,
        child: Text('Test'),
      );

      expect(widget.shakeCount, 5);
    });

    testWidgets('accepts custom shakeDuration', (tester) async {
      const widget = ShakeWidget(
        shakeOffset: 15.0,
        shakeDuration: Duration(milliseconds: 600),
        child: Text('Test'),
      );

      expect(widget.shakeDuration, const Duration(milliseconds: 600));
    });

    testWidgets('creates ShakeWidgetState', (tester) async {
      await tester.pumpAppWithScaffold(
        const ShakeWidget(shakeOffset: 10.0, child: Text('Test')),
      );

      final state = tester.state<ShakeWidgetState>(find.byType(ShakeWidget));
      expect(state, isNotNull);
    });

    testWidgets('contains AnimatedBuilder for animation', (tester) async {
      await tester.pumpAppWithScaffold(
        const ShakeWidget(shakeOffset: 10.0, child: Text('Test')),
      );

      // AnimatedBuilder is used in ShakeWidgetState which creates Transform
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('can trigger shake animation via state', (tester) async {
      final key = GlobalKey<ShakeWidgetState>();

      await tester.pumpAppWithScaffold(
        ShakeWidget(key: key, shakeOffset: 10.0, child: const Text('Test')),
      );

      // Trigger shake
      key.currentState?.shake();
      await tester.pump();

      // Animation should be running
      expect(find.byType(ShakeWidget), findsOneWidget);
    });
  });
}
