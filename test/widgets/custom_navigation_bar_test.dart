import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/custom_navigation_bar.dart';
import '../helpers/pump_app.dart';

class MockCallback extends Mock {
  void call(int index);
}

void main() {
  group('CustomNavBar', () {
    late MockCallback mockOnTap;

    setUp(() {
      mockOnTap = MockCallback();
    });

    group('rendering', () {
      testWidgets('displays all navigation items for regular user', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            bottomNavigationBar: CustomNavBar(
              restaurantOwner: false,
              onTap: mockOnTap.call,
            ),
          ),
        );

        // Assert - 4 items: Home, Orders, Favorites, Account (no Restaurant)
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Orders'), findsOneWidget);
        expect(find.text('Favorites'), findsOneWidget);
        expect(find.text('Account'), findsOneWidget);
      });

      testWidgets('displays restaurant item for restaurant owner', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            bottomNavigationBar: CustomNavBar(
              restaurantOwner: true,
              onTap: mockOnTap.call,
            ),
          ),
        );

        // Assert - 5 items including Restaurant
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Orders'), findsOneWidget);
        expect(find.text('Restaurant'), findsOneWidget);
        expect(find.text('Favorites'), findsOneWidget);
        expect(find.text('Account'), findsOneWidget);
      });

      testWidgets('uses initial index', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            bottomNavigationBar: CustomNavBar(
              restaurantOwner: false,
              onTap: mockOnTap.call,
              initialIndex: 2,
            ),
          ),
        );

        // Assert - verifica rendering
        expect(find.byType(CustomNavBar), findsOneWidget);
      });
    });

    group('icons', () {
      testWidgets('displays correct icons', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          Scaffold(
            bottomNavigationBar: CustomNavBar(
              restaurantOwner: false,
              onTap: mockOnTap.call,
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.home_rounded), findsWidgets);
        expect(find.byIcon(Icons.receipt_long_rounded), findsWidgets);
        expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
        expect(find.byIcon(Icons.person_rounded), findsWidgets);
      });
    });
  });
}
