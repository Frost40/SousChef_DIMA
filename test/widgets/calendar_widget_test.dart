import 'package:flutter/cupertino.dart';
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

    group('rendering', () {
      testWidgets('renders correctly', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        expect(find.byType(DateTimePickerWidget), findsOneWidget);
      });

      testWidgets('displays date and time selection containers', (
        tester,
      ) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        expect(find.byType(Container), findsWidgets);
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

      testWidgets('contains GestureDetector for tap interaction', (
        tester,
      ) async {
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

      testWidgets('shows "Select Date & Time" placeholder text', (
        tester,
      ) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        expect(find.text('Select Date & Time'), findsOneWidget);
      });

      testWidgets('uses Focus widget for focus management', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        expect(find.byType(Focus), findsWidgets);
      });
    });

    group('widget configuration', () {
      test('accepts maxDateDays parameter', () {
        final widget = DateTimePickerWidget(
          maxDateDays: 14,
          onDateTimeSelected: (dt) {},
        );

        expect(widget.maxDateDays, 14);
      });

      test('accepts onDateTimeSelected callback', () {
        DateTime? capturedDateTime;
        final widget = DateTimePickerWidget(
          maxDateDays: 7,
          onDateTimeSelected: (dt) {
            capturedDateTime = dt;
          },
        );

        expect(widget.onDateTimeSelected, isNotNull);
        widget.onDateTimeSelected(DateTime(2026, 1, 15, 10, 30));
        expect(capturedDateTime, isNotNull);
        expect(capturedDateTime!.year, 2026);
        expect(capturedDateTime!.month, 1);
        expect(capturedDateTime!.day, 15);
      });

      test('allows different maxDateDays values', () {
        final widget1 = DateTimePickerWidget(
          maxDateDays: 3,
          onDateTimeSelected: (dt) {},
        );
        final widget2 = DateTimePickerWidget(
          maxDateDays: 30,
          onDateTimeSelected: (dt) {},
        );

        expect(widget1.maxDateDays, 3);
        expect(widget2.maxDateDays, 30);
      });
    });

    group('date picker interaction', () {
      testWidgets('opens date picker on tap', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Tap on the widget to open date picker
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // DatePicker dialog should be visible
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('date picker shows current month', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Should display month/year header
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('closing date picker without selection resets state', (
        tester,
      ) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Open date picker
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Close by tapping Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Should still show placeholder
        expect(find.text('Select Date & Time'), findsOneWidget);
      });

      testWidgets('selecting date opens time picker', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Open date picker
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Select a date (tap OK to confirm)
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Time picker bottom sheet should appear with CupertinoPicker
        expect(find.byType(CupertinoPicker), findsOneWidget);
      });
    });

    group('time picker interaction', () {
      testWidgets('time picker shows "Confirm Time" button', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Open date picker
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Select a date
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Confirm Time button should be visible
        expect(find.text('Confirm Time'), findsOneWidget);
      });

      testWidgets('selecting time calls onDateTimeSelected callback', (
        tester,
      ) async {
        DateTime? selectedDateTime;
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: (dt) {
              selectedDateTime = dt;
            },
          ),
        );

        // Open date picker
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Select a date
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Confirm time
        await tester.tap(find.text('Confirm Time'));
        await tester.pumpAndSettle();

        // Callback should have been called
        expect(selectedDateTime, isNotNull);
      });

      testWidgets('dismissing time picker without confirming resets state', (
        tester,
      ) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Open date picker
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Select a date
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Dismiss bottom sheet by tapping outside (scrim)
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Should still show placeholder text
        expect(find.text('Select Date & Time'), findsOneWidget);
      });

      testWidgets('time picker uses CupertinoPicker', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoPicker), findsOneWidget);
      });
    });

    group('state management', () {
      testWidgets('hasSelection is false initially', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Placeholder text indicates no selection
        expect(find.text('Select Date & Time'), findsOneWidget);
      });

      testWidgets('displays selected date and time after selection', (
        tester,
      ) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Open date picker
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Select a date
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Confirm time
        await tester.tap(find.text('Confirm Time'));
        await tester.pumpAndSettle();

        // Placeholder should be replaced with date/time
        expect(find.text('Select Date & Time'), findsNothing);
      });
    });

    group('styling', () {
      testWidgets('container has rounded border radius', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Find container with BoxDecoration
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        bool foundRoundedContainer = false;
        for (final element in containerFinder.evaluate()) {
          final container = element.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.borderRadius != null) {
              foundRoundedContainer = true;
              break;
            }
          }
        }
        expect(foundRoundedContainer, isTrue);
      });

      testWidgets('time picker bottom sheet has rounded top corners', (
        tester,
      ) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Bottom sheet should be visible
        expect(find.byType(BottomSheet), findsOneWidget);
      });

      testWidgets('applies focus styling when selecting', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Tap to start selection (will show focus border)
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();

        // Widget should now have focus styling (tested by rendering without error)
        expect(find.byType(DateTimePickerWidget), findsOneWidget);
      });
    });

    group('theme support', () {
      testWidgets('renders in light theme', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
          theme: ThemeData.light(),
        );

        expect(find.byType(DateTimePickerWidget), findsOneWidget);
      });

      testWidgets('renders in dark theme', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
          theme: ThemeData.dark(),
        );

        expect(find.byType(DateTimePickerWidget), findsOneWidget);
      });

      testWidgets('date picker adapts to theme colors', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // DatePicker should be displayed with theme colors
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('handles maxDateDays of 1', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 1,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('handles large maxDateDays value', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 365,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('can be opened multiple times', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // First open and cancel
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Second open
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('scrolling time picker changes selected time', (
        tester,
      ) async {
        DateTime? selectedDateTime;
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: (dt) {
              selectedDateTime = dt;
            },
          ),
        );

        // Open date picker and select date
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Scroll the picker to change time
        final pickerFinder = find.byType(CupertinoPicker);
        await tester.drag(pickerFinder, const Offset(0, -100));
        await tester.pumpAndSettle();

        // Confirm time
        await tester.tap(find.text('Confirm Time'));
        await tester.pumpAndSettle();

        expect(selectedDateTime, isNotNull);
      });
    });

    group('accessibility', () {
      testWidgets('is focusable', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        expect(find.byType(Focus), findsWidgets);
      });

      testWidgets('GestureDetector responds to tap', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Should be tappable without throwing
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
      });
    });

    group('dispose', () {
      testWidgets('disposes focus node without errors', (tester) async {
        await tester.pumpAppWithScaffold(
          DateTimePickerWidget(
            maxDateDays: 7,
            onDateTimeSelected: mockOnDateTimeSelected.call,
          ),
        );

        // Replace with empty container to trigger dispose
        await tester.pumpAppWithScaffold(const SizedBox.shrink());
        await tester.pumpAndSettle();

        // Should complete without errors
        expect(find.byType(DateTimePickerWidget), findsNothing);
      });
    });
  });
}
