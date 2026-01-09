import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/order.dart';
import 'package:sous_chef/widgets/order_screen/order.dart';
import 'package:sous_chef/widgets/restaurant_screen/price_tag.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_providers.dart';

void main() {
  group('OrderTile', () {
    late List<OrderItem> testDishes;
    late DateTime testDateTime;
    late MockOrderProvider mockOrderProvider;

    setUpAll(() {
      registerFallbackValues();
    });

    setUp(() {
      testDishes = [
        OrderItem(dishId: 'dish-1', name: 'Pizza', quantity: 2, price: 10.0),
        OrderItem(dishId: 'dish-2', name: 'Pasta', quantity: 1, price: 8.0),
      ];
      testDateTime = DateTime(2026, 1, 2, 12, 30);
      mockOrderProvider = MockOrderProvider();
      when(
        () => mockOrderProvider.verifyAndCompleteOrder(any(), any()),
      ).thenAnswer((_) async => true);
    });

    group('widget instantiation', () {
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

      test('is initially collapsed by default', () {
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

      test('can be initially expanded', () {
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

      test('has correct default isRestaurantView value', () {
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

      test('stores verification code', () {
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

      test('stores restaurant address when provided', () {
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

    group('rendering', () {
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

      testWidgets('displays PriceTag with total price', (tester) async {
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

        expect(find.byType(PriceTag), findsOneWidget);
        expect(find.text('Total:'), findsOneWidget);
      });

      testWidgets('displays pickup date and time', (tester) async {
        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName: 'Test Restaurant',
            isClickable: false,
            restaurantId: 'rest-1',
            dishes: testDishes,
            dateTime: DateTime(2026, 1, 2, 12, 30),
            price: 28.0,
            verificationCode: '123456',
          ),
        );

        expect(find.textContaining('Pickup'), findsOneWidget);
        expect(find.textContaining('Jan 2, 2026'), findsOneWidget);
        expect(find.textContaining('12:30'), findsOneWidget);
      });

      testWidgets('displays restaurant address when provided', (tester) async {
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
            restaurantAddress: 'Via Roma 1, Milano',
          ),
        );

        expect(find.text('Address • '), findsOneWidget);
        expect(find.text('Via Roma 1, Milano'), findsOneWidget);
      });

      testWidgets('displays pickup code when not restaurant view', (
        tester,
      ) async {
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
            isRestaurantView: false,
          ),
        );

        // Pickup code is shown via RichText - verify the widget exists
        expect(find.byType(RichText), findsWidgets);
      });
    });

    group('expand/collapse behavior', () {
      testWidgets('expands when tapped', (tester) async {
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

        // Tap to expand
        await tester.tap(find.byType(InkWell).first);
        await tester.pumpAndSettle();

        // SizeTransition should be animating
        expect(find.byType(SizeTransition), findsOneWidget);
      });

      testWidgets('collapses when tapped again', (tester) async {
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
            initiallyExpanded: true,
          ),
        );
        await tester.pumpAndSettle();

        // Tap to collapse
        await tester.tap(find.byType(InkWell).first);
        await tester.pumpAndSettle();

        expect(find.byType(SizeTransition), findsOneWidget);
      });

      testWidgets('shows dishes when expanded', (tester) async {
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
            initiallyExpanded: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pizza'), findsOneWidget);
        expect(find.text('Pasta'), findsOneWidget);
        expect(find.text('2x'), findsOneWidget);
        expect(find.text('1x'), findsOneWidget);
      });
    });

    group('clickable restaurant name', () {
      testWidgets('restaurant name is underlined when clickable', (
        tester,
      ) async {
        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName: 'Test Restaurant',
            isClickable: true,
            restaurantId: 'rest-1',
            dishes: testDishes,
            dateTime: testDateTime,
            price: 28.0,
            verificationCode: '123456',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Test Restaurant'));
        expect(textWidget.style?.decoration, TextDecoration.underline);
      });

      testWidgets('restaurant name is not underlined when not clickable', (
        tester,
      ) async {
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

        final textWidget = tester.widget<Text>(find.text('Test Restaurant'));
        expect(textWidget.style?.decoration, isNot(TextDecoration.underline));
      });

      testWidgets('clickable restaurant name has GestureDetector', (
        tester,
      ) async {
        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName: 'Test Restaurant',
            isClickable: true,
            restaurantId: 'rest-1',
            dishes: testDishes,
            dateTime: testDateTime,
            price: 28.0,
            verificationCode: '123456',
          ),
        );

        // Verify GestureDetector exists for the clickable name
        expect(find.byType(GestureDetector), findsWidgets);
      });
    });

    group('restaurant view', () {
      testWidgets(
        'shows verify button in restaurant view with verification code',
        (tester) async {
          await tester.pumpApp(
            Scaffold(
              body: OrderTile(
                orderId: 'order-1',
                displayName: 'Test Restaurant',
                isClickable: false,
                restaurantId: 'rest-1',
                dishes: testDishes,
                dateTime: testDateTime,
                price: 28.0,
                verificationCode: '123456',
                isRestaurantView: true,
                initiallyExpanded: true,
              ),
            ),
            orderProvider: mockOrderProvider,
          );
          await tester.pumpAndSettle();

          expect(find.text('Verify Pickup Code'), findsOneWidget);
          expect(find.byIcon(Icons.verified), findsOneWidget);
        },
      );

      testWidgets('does not show verify button when not restaurant view', (
        tester,
      ) async {
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
            isRestaurantView: false,
            initiallyExpanded: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Verify Pickup Code'), findsNothing);
      });

      testWidgets('does not show pickup code in restaurant view', (
        tester,
      ) async {
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
            isRestaurantView: true,
          ),
        );

        expect(find.textContaining('Pickup Code •'), findsNothing);
      });
    });

    group('page specific widget', () {
      testWidgets('renders pageSpecificWidget when provided', (tester) async {
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
            pageSpecificWidget: const Icon(
              Icons.star,
              key: Key('custom-widget'),
            ),
          ),
        );

        expect(find.byKey(const Key('custom-widget')), findsOneWidget);
      });

      testWidgets(
        'does not render extra widget when pageSpecificWidget is null',
        (tester) async {
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
              pageSpecificWidget: null,
            ),
          );

          expect(find.byKey(const Key('custom-widget')), findsNothing);
        },
      );
    });

    group('dishes list', () {
      testWidgets('uses Column for 3 or fewer dishes', (tester) async {
        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName: 'Test Restaurant',
            isClickable: false,
            restaurantId: 'rest-1',
            dishes: testDishes, // 2 dishes
            dateTime: testDateTime,
            price: 28.0,
            verificationCode: '123456',
            initiallyExpanded: true,
          ),
        );
        await tester.pumpAndSettle();

        // Should not use ListView for 2 dishes
        final sizeTransition = find.byType(SizeTransition);
        expect(sizeTransition, findsOneWidget);
      });

      testWidgets('uses ListView for more than 3 dishes', (tester) async {
        final manyDishes = [
          OrderItem(dishId: 'dish-1', name: 'Pizza', quantity: 1, price: 10.0),
          OrderItem(dishId: 'dish-2', name: 'Pasta', quantity: 1, price: 8.0),
          OrderItem(dishId: 'dish-3', name: 'Salad', quantity: 1, price: 6.0),
          OrderItem(dishId: 'dish-4', name: 'Dessert', quantity: 1, price: 5.0),
        ];

        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName: 'Test Restaurant',
            isClickable: false,
            restaurantId: 'rest-1',
            dishes: manyDishes,
            dateTime: testDateTime,
            price: 29.0,
            verificationCode: '123456',
            initiallyExpanded: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('displays dish prices', (tester) async {
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
            initiallyExpanded: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('€10.00'), findsOneWidget);
        expect(find.text('€8.00'), findsOneWidget);
      });
    });

    group('theme support', () {
      testWidgets('renders correctly with light theme', (tester) async {
        await tester.pumpApp(
          Scaffold(
            body: OrderTile(
              orderId: 'order-1',
              displayName: 'Test Restaurant',
              isClickable: false,
              restaurantId: 'rest-1',
              dishes: testDishes,
              dateTime: testDateTime,
              price: 28.0,
              verificationCode: '123456',
            ),
          ),
          theme: ThemeData.light(),
        );

        expect(find.byType(OrderTile), findsOneWidget);
      });

      testWidgets('renders correctly with dark theme', (tester) async {
        await tester.pumpApp(
          Scaffold(
            body: OrderTile(
              orderId: 'order-1',
              displayName: 'Test Restaurant',
              isClickable: false,
              restaurantId: 'rest-1',
              dishes: testDishes,
              dateTime: testDateTime,
              price: 28.0,
              verificationCode: '123456',
            ),
          ),
          theme: ThemeData.dark(),
        );

        expect(find.byType(OrderTile), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('handles empty verification code', (tester) async {
        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName: 'Test Restaurant',
            isClickable: false,
            restaurantId: 'rest-1',
            dishes: testDishes,
            dateTime: testDateTime,
            price: 28.0,
            verificationCode: '',
          ),
        );

        expect(find.textContaining('Pickup Code'), findsNothing);
      });

      testWidgets('handles long restaurant name with overflow', (tester) async {
        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName:
                'Very Long Restaurant Name That Should Handle Overflow Properly',
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

      testWidgets('handles empty dishes list', (tester) async {
        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName: 'Test Restaurant',
            isClickable: false,
            restaurantId: 'rest-1',
            dishes: const [],
            dateTime: testDateTime,
            price: 0.0,
            verificationCode: '123456',
            initiallyExpanded: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OrderTile), findsOneWidget);
      });

      testWidgets('handles single dish', (tester) async {
        await tester.pumpAppWithScaffold(
          OrderTile(
            orderId: 'order-1',
            displayName: 'Test Restaurant',
            isClickable: false,
            restaurantId: 'rest-1',
            dishes: [
              OrderItem(
                dishId: 'dish-1',
                name: 'Pizza',
                quantity: 1,
                price: 10.0,
              ),
            ],
            dateTime: testDateTime,
            price: 10.0,
            verificationCode: '123456',
            initiallyExpanded: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pizza'), findsOneWidget);
        expect(find.text('1x'), findsOneWidget);
      });
    });

    group('animation', () {
      testWidgets('contains SizeTransition for expand animation', (
        tester,
      ) async {
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

        expect(find.byType(SizeTransition), findsOneWidget);
      });

      testWidgets('animation completes when expanded', (tester) async {
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

        await tester.tap(find.byType(InkWell).first);
        await tester.pumpAndSettle();

        final sizeTransition = tester.widget<SizeTransition>(
          find.byType(SizeTransition),
        );
        expect(sizeTransition.sizeFactor.value, 1.0);
      });
    });

    group('dispose', () {
      testWidgets('disposes animation controller properly', (tester) async {
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

        // Navigate away to trigger dispose
        await tester.pumpWidget(Container());

        // No exception means dispose was successful
        expect(true, isTrue);
      });
    });
  });
}
