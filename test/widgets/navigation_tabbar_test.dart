import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';

import '../helpers/pump_app.dart';

void main() {
  group('NavigationTabbar', () {
    group('rendering', () {
      testWidgets('displays all tab labels', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: NavigationTabbar(
              tabCount: 3,
              tabLabels: const ['First', 'Second', 'Third'],
            ),
          ),
        );

        // Assert
        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsOneWidget);
        expect(find.text('Third'), findsOneWidget);
      });

      testWidgets('renders with custom height', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: NavigationTabbar(
              tabCount: 2,
              tabLabels: const ['Tab1', 'Tab2'],
              height: 60.0,
            ),
          ),
        );

        // Assert - verifica solo il rendering
        expect(find.byType(NavigationTabbar), findsOneWidget);
      });

      testWidgets('uses TabBar widget', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: NavigationTabbar(
              tabCount: 2,
              tabLabels: const ['Tab1', 'Tab2'],
            ),
          ),
        );

        // Assert
        expect(find.byType(TabBar), findsOneWidget);
      });

      testWidgets('creates correct number of tabs', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: NavigationTabbar(
              tabCount: 4,
              tabLabels: const ['A', 'B', 'C', 'D'],
            ),
          ),
        );

        // Assert
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
        expect(find.text('D'), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('calls callback when tab is selected', (tester) async {
        // Arrange
        int? selectedIndex;

        await tester.pumpWidget_(
          Scaffold(
            body: NavigationTabbar(
              tabCount: 3,
              tabLabels: const ['First', 'Second', 'Third'],
              onTabSelected: (index) => selectedIndex = index,
            ),
          ),
        );

        // Act - tap on second tab
        await tester.tap(find.text('Second'));
        await tester.pumpAndSettle();

        // Assert
        expect(selectedIndex, equals(1));
      });

      testWidgets('can switch between tabs', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          Scaffold(
            body: NavigationTabbar(
              tabCount: 3,
              tabLabels: const ['First', 'Second', 'Third'],
            ),
          ),
        );

        // Act - tap different tabs
        await tester.tap(find.text('Second'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Third'));
        await tester.pumpAndSettle();

        // Assert - should not throw
        expect(find.text('Third'), findsOneWidget);
      });

      testWidgets('respects initialIndex', (tester) async {
        // Arrange
        int? selectedIndex;

        await tester.pumpWidget_(
          Scaffold(
            body: NavigationTabbar(
              tabCount: 3,
              tabLabels: const ['First', 'Second', 'Third'],
              initialIndex: 1,
              onTabSelected: (index) => selectedIndex = index,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Second tab should be initially selected
        final tabController = DefaultTabController.of(
          tester.element(find.byType(TabBar)),
        );
        expect(tabController.index, equals(1));
      });
    });

    group('customization', () {
      testWidgets('applies custom margin', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            body: NavigationTabbar(
              tabCount: 2,
              tabLabels: const ['Tab1', 'Tab2'],
              margin: const EdgeInsets.all(16),
            ),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(NavigationTabbar),
            matching: find.byType(Container).first,
          ),
        );
        expect(container.margin, equals(const EdgeInsets.all(16)));
      });
    });
  });
}
