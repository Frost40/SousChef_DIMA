import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/dish_screen/calendar_widget.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_providers.dart';

void main() {
  group('DateTimePickerWidget', () {
    late MockValueCallback<DateTime> mockOnDateTimeSelected;

    setUp(() {
      mockOnDateTimeSelected = MockValueCallback<DateTime>();
    });

    setUpAll(() {
      registerFallbackValue(DateTime.now());
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        DateTimePickerWidget(
          maxDateDays: 7,
          onDateTimeSelected: mockOnDateTimeSelected.call,
        ),
      );

      expect(find.byType(DateTimePickerWidget), findsOneWidget);
    });

    testWidgets('displays date and time selection containers', (tester) async {
      await tester.pumpAppWithScaffold(
        DateTimePickerWidget(
          maxDateDays: 7,
          onDateTimeSelected: mockOnDateTimeSelected.call,
        ),
      );

      // Should have containers for date and time selection
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('accepts maxDateDays parameter', (tester) async {
      final widget = DateTimePickerWidget(
        maxDateDays: 14,
        onDateTimeSelected: (dt) {},
      );

      expect(widget.maxDateDays, 14);
    });

    testWidgets('uses Row layout', (tester) async {
      await tester.pumpAppWithScaffold(
        DateTimePickerWidget(
          maxDateDays: 7,
          onDateTimeSelected: mockOnDateTimeSelected.call,
        ),
      );

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('contains GestureDetector for tap interaction', (tester) async {
      await tester.pumpAppWithScaffold(
        DateTimePickerWidget(
          maxDateDays: 7,
          onDateTimeSelected: mockOnDateTimeSelected.call,
        ),
      );

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('shows calendar icon', (tester) async {
      await tester.pumpAppWithScaffold(
        DateTimePickerWidget(
          maxDateDays: 7,
          onDateTimeSelected: mockOnDateTimeSelected.call,
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });
  });
}
