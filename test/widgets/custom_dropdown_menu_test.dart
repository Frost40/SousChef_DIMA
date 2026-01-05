import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/custom_dropdown_menu.dart';
import '../helpers/pump_app.dart';

void main() {
  group('CustomDropdownMenu', () {
    group('rendering', () {
      testWidgets('displays hint when no item selected', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          CustomDropdownMenu<String>(
            items: const ['Option 1', 'Option 2', 'Option 3'],
            isEditable: true,
            onChanged: (_) {},
            hint: 'Select an option',
          ),
        );

        // Assert
        expect(find.text('Select an option'), findsOneWidget);
      });

      testWidgets('displays selected item', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          CustomDropdownMenu<String>(
            items: const ['Option 1', 'Option 2', 'Option 3'],
            isEditable: true,
            onChanged: (_) {},
            selectedItem: 'Option 2',
          ),
        );

        // Assert
        expect(find.text('Option 2'), findsOneWidget);
      });

      testWidgets('shows dropdown icon', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          CustomDropdownMenu<String>(
            items: const ['A', 'B', 'C'],
            isEditable: true,
            onChanged: (_) {},
          ),
        );

        // Assert
        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      });

      testWidgets('renders with different types', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          CustomDropdownMenu<int>(
            items: const [1, 2, 3, 4, 5],
            isEditable: true,
            onChanged: (_) {},
            selectedItem: 3,
          ),
        );

        // Assert
        expect(find.text('3'), findsOneWidget);
      });
    });

    group('state', () {
      testWidgets('is tappable when editable', (tester) async {
        // Arrange
        await tester.pumpAppWithScaffold(
          CustomDropdownMenu<String>(
            items: const ['Option 1', 'Option 2'],
            isEditable: true,
            onChanged: (_) {},
            selectedItem: 'Option 1',
          ),
        );

        // Act & Assert - should not throw
        await tester.tap(find.text('Option 1'));
        await tester.pump();

        expect(find.byType(CustomDropdownMenu<String>), findsOneWidget);
      });

      testWidgets('shows GestureDetector for tapping', (tester) async {
        // Arrange & Act
        await tester.pumpAppWithScaffold(
          CustomDropdownMenu<String>(
            items: const ['A', 'B'],
            isEditable: true,
            onChanged: (_) {},
          ),
        );

        // Assert
        expect(find.byType(GestureDetector), findsWidgets);
      });
    });
  });
}
