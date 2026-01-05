import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/restaurant_screen/open_close_button.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_providers.dart';

void main() {
  group('OpenCloseButton', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        const OpenCloseButton(initialValue: true),
      );

      expect(find.byType(OpenCloseButton), findsOneWidget);
    });

    testWidgets('displays Open when isOpen is true', (tester) async {
      await tester.pumpAppWithScaffold(
        const OpenCloseButton(initialValue: true),
      );

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('displays Closed when isOpen is false', (tester) async {
      await tester.pumpAppWithScaffold(
        const OpenCloseButton(initialValue: false),
      );

      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('toggles state when tapped and editable', (tester) async {
      final mockOnToggle = MockValueCallback<bool>();

      await tester.pumpAppWithScaffold(
        OpenCloseButton(
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
        OpenCloseButton(
          initialValue: true,
          isEditable: false,
          onToggle: mockOnToggle.call,
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      verifyNever(() => mockOnToggle.call(any()));
    });

    testWidgets('is not editable by default', (tester) async {
      const widget = OpenCloseButton(initialValue: true);

      expect(widget.isEditable, isFalse);
    });

    testWidgets('contains AnimatedContainer', (tester) async {
      await tester.pumpAppWithScaffold(
        const OpenCloseButton(initialValue: true),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('contains Row with indicator and text', (tester) async {
      await tester.pumpAppWithScaffold(
        const OpenCloseButton(initialValue: true),
      );

      expect(find.byType(Row), findsOneWidget);
    });
  });
}
