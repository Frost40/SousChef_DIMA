import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/restaurant_screen/dish_availability_button.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_providers.dart';

void main() {
  group('DishAvailabilityButton', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        const DishAvailabilityButton(initialValue: true),
      );

      expect(find.byType(DishAvailabilityButton), findsOneWidget);
    });

    testWidgets('shows check icon when available', (tester) async {
      await tester.pumpAppWithScaffold(
        const DishAvailabilityButton(initialValue: true),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows close icon when not available', (tester) async {
      await tester.pumpAppWithScaffold(
        const DishAvailabilityButton(initialValue: false),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('has green container when available', (tester) async {
      await tester.pumpAppWithScaffold(
        const DishAvailabilityButton(initialValue: true),
      );

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.check),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green);
    });

    testWidgets('has red container when not available', (tester) async {
      await tester.pumpAppWithScaffold(
        const DishAvailabilityButton(initialValue: false),
      );

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.close),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('toggles state when tapped and editable', (tester) async {
      final mockOnToggle = MockValueCallback<bool>();

      await tester.pumpAppWithScaffold(
        DishAvailabilityButton(
          initialValue: true,
          isEditable: true,
          onToggle: mockOnToggle.call,
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      verify(() => mockOnToggle.call(false)).called(1);
    });

    testWidgets('does not toggle when not editable', (tester) async {
      final mockOnToggle = MockValueCallback<bool>();

      await tester.pumpAppWithScaffold(
        DishAvailabilityButton(
          initialValue: true,
          isEditable: false,
          onToggle: mockOnToggle.call,
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      verifyNever(() => mockOnToggle.call(any()));
    });

    testWidgets('has default size of 24', (tester) async {
      const widget = DishAvailabilityButton(initialValue: true);

      expect(widget.size, 24);
    });

    testWidgets('accepts custom size', (tester) async {
      const widget = DishAvailabilityButton(initialValue: true, size: 32);

      expect(widget.size, 32);
    });

    testWidgets('is editable by default', (tester) async {
      const widget = DishAvailabilityButton(initialValue: true);

      expect(widget.isEditable, isTrue);
    });
  });
}
