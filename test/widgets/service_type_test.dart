import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/restaurant_screen/service_type.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_providers.dart';

void main() {
  group('ServiceType', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        const ServiceType(initialValue: true, serviceType: 'Fixed Menu'),
      );

      expect(find.byType(ServiceType), findsOneWidget);
    });

    testWidgets('displays service type text', (tester) async {
      await tester.pumpAppWithScaffold(
        const ServiceType(initialValue: true, serviceType: 'On Request'),
      );

      expect(find.text('On Request'), findsOneWidget);
    });

    testWidgets('toggles state when tapped and editable', (tester) async {
      final mockOnToggle = MockValueCallback<bool>();

      await tester.pumpAppWithScaffold(
        ServiceType(
          initialValue: true,
          serviceType: 'Fixed Menu',
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
        ServiceType(
          initialValue: true,
          serviceType: 'Fixed Menu',
          isEditable: false,
          onToggle: mockOnToggle.call,
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      verifyNever(() => mockOnToggle.call(any()));
    });

    testWidgets('is not editable by default', (tester) async {
      const widget = ServiceType(initialValue: true, serviceType: 'Test');

      expect(widget.isEditable, isFalse);
    });

    testWidgets('contains AnimatedContainer', (tester) async {
      await tester.pumpAppWithScaffold(
        const ServiceType(initialValue: true, serviceType: 'Fixed Menu'),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('contains GestureDetector for tap', (tester) async {
      await tester.pumpAppWithScaffold(
        const ServiceType(initialValue: true, serviceType: 'Fixed Menu'),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}
