import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/home_screen/distance_selector.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_providers.dart';

void main() {
  group('DistanceSelector', () {
    late MockValueCallback<int> mockOnDistanceChanged;

    setUp(() {
      mockOnDistanceChanged = MockValueCallback<int>();
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(onDistanceChanged: mockOnDistanceChanged.call),
      );

      expect(find.byType(DistanceSelector), findsOneWidget);
    });

    testWidgets('displays default distance of 3 km', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(onDistanceChanged: mockOnDistanceChanged.call),
      );

      expect(find.text('3 km'), findsOneWidget);
    });

    testWidgets('displays initial distance', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(
          initialDistance: 5,
          onDistanceChanged: mockOnDistanceChanged.call,
        ),
      );

      expect(find.text('5 km'), findsOneWidget);
    });

    testWidgets('shows Max distance label', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(onDistanceChanged: mockOnDistanceChanged.call),
      );

      expect(find.text('Max distance:'), findsOneWidget);
    });

    testWidgets('shows arrow up and down icons', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(onDistanceChanged: mockOnDistanceChanged.call),
      );

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('increases distance when up arrow tapped', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(
          initialDistance: 3,
          onDistanceChanged: mockOnDistanceChanged.call,
        ),
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      await tester.pumpAndSettle();

      expect(find.text('4 km'), findsOneWidget);
      verify(() => mockOnDistanceChanged.call(4)).called(1);
    });

    testWidgets('decreases distance when down arrow tapped', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(
          initialDistance: 5,
          onDistanceChanged: mockOnDistanceChanged.call,
        ),
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();

      expect(find.text('4 km'), findsOneWidget);
      verify(() => mockOnDistanceChanged.call(4)).called(1);
    });

    testWidgets('does not decrease below 1 km', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(
          initialDistance: 1,
          onDistanceChanged: mockOnDistanceChanged.call,
        ),
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();

      // Should still be 1 km
      expect(find.text('1 km'), findsOneWidget);
      verifyNever(() => mockOnDistanceChanged.call(any()));
    });

    testWidgets('contains InkWell for tap interaction', (tester) async {
      await tester.pumpAppWithScaffold(
        DistanceSelector(onDistanceChanged: mockOnDistanceChanged.call),
      );

      expect(find.byType(InkWell), findsWidgets);
    });
  });
}
