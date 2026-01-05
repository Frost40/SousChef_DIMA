import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/models/order.dart';
import 'package:sous_chef/widgets/order_screen/order.dart';

import '../helpers/pump_app.dart';

void main() {
  group('OrderTile', () {
    late List<OrderItem> testDishes;
    late DateTime testDateTime;

    setUp(() {
      testDishes = [
        OrderItem(dishId: 'dish-1', name: 'Pizza', quantity: 2, price: 10.0),
        OrderItem(dishId: 'dish-2', name: 'Pasta', quantity: 1, price: 8.0),
      ];
      testDateTime = DateTime(2026, 1, 2, 12, 30);
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        OrderTile(
          orderId: 'order-1',
          displayName: 'Test Restaurant',
          isClickable: false,
          restaurantId: 'rest-1',
          dishes: testDishes,
          dateTime: testDateTime,
          price: 28.0,
          verificationCode: '123456',
        ),
      );

      expect(find.byType(OrderTile), findsOneWidget);
    });

    testWidgets('displays restaurant name', (tester) async {
      await tester.pumpAppWithScaffold(
        OrderTile(
          orderId: 'order-1',
          displayName: 'My Restaurant',
          isClickable: false,
          restaurantId: 'rest-1',
          dishes: testDishes,
          dateTime: testDateTime,
          price: 28.0,
          verificationCode: '123456',
        ),
      );

      expect(find.text('My Restaurant'), findsOneWidget);
    });

    testWidgets('contains Card widget', (tester) async {
      await tester.pumpAppWithScaffold(
        OrderTile(
          orderId: 'order-1',
          displayName: 'Test Restaurant',
          isClickable: false,
          restaurantId: 'rest-1',
          dishes: testDishes,
          dateTime: testDateTime,
          price: 28.0,
          verificationCode: '123456',
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('is initially collapsed by default', (tester) async {
      final widget = OrderTile(
        orderId: 'order-1',
        displayName: 'Test Restaurant',
        isClickable: false,
        restaurantId: 'rest-1',
        dishes: testDishes,
        dateTime: testDateTime,
        price: 28.0,
        verificationCode: '123456',
      );

      expect(widget.initiallyExpanded, isFalse);
    });

    testWidgets('can be initially expanded', (tester) async {
      final widget = OrderTile(
        orderId: 'order-1',
        displayName: 'Test Restaurant',
        isClickable: false,
        restaurantId: 'rest-1',
        dishes: testDishes,
        dateTime: testDateTime,
        price: 28.0,
        verificationCode: '123456',
        initiallyExpanded: true,
      );

      expect(widget.initiallyExpanded, isTrue);
    });

    testWidgets('has correct default isRestaurantView value', (tester) async {
      final widget = OrderTile(
        orderId: 'order-1',
        displayName: 'Test Restaurant',
        isClickable: false,
        restaurantId: 'rest-1',
        dishes: testDishes,
        dateTime: testDateTime,
        price: 28.0,
        verificationCode: '123456',
      );

      expect(widget.isRestaurantView, isFalse);
    });

    testWidgets('contains InkWell for tap interaction', (tester) async {
      await tester.pumpAppWithScaffold(
        OrderTile(
          orderId: 'order-1',
          displayName: 'Test Restaurant',
          isClickable: false,
          restaurantId: 'rest-1',
          dishes: testDishes,
          dateTime: testDateTime,
          price: 28.0,
          verificationCode: '123456',
        ),
      );

      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('stores verification code', (tester) async {
      final widget = OrderTile(
        orderId: 'order-1',
        displayName: 'Test Restaurant',
        isClickable: false,
        restaurantId: 'rest-1',
        dishes: testDishes,
        dateTime: testDateTime,
        price: 28.0,
        verificationCode: 'ABC123',
      );

      expect(widget.verificationCode, 'ABC123');
    });

    testWidgets('stores restaurant address when provided', (tester) async {
      final widget = OrderTile(
        orderId: 'order-1',
        displayName: 'Test Restaurant',
        isClickable: false,
        restaurantId: 'rest-1',
        dishes: testDishes,
        dateTime: testDateTime,
        price: 28.0,
        verificationCode: '123456',
        restaurantAddress: 'Via Roma 1, Milano',
      );

      expect(widget.restaurantAddress, 'Via Roma 1, Milano');
    });
  });
}
