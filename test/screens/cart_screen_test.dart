import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/order.dart' as order_model;
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/cart_screen.dart';
import 'package:sous_chef/widgets/order_card.dart';
import 'package:sous_chef/widgets/animated_button.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockOrderProvider mockOrderProvider;
  late MockStripeProvider mockStripeProvider;

  // Sample test user
  final testUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
    restaurantId: null,
  );

  // Sample orders ready for checkout
  final testCartOrders = <order_model.Order>[
    order_model.Order(
      id: 'cart-order-1',
      userId: 'test-user-id',
      username: 'testuser',
      restaurantId: 'restaurant-1',
      restaurantName: 'Ristorante Italiano',
      restaurantAddress: 'Via Roma 10, Milano',
      restaurantLocation: const GeoPoint(45.4642, 9.1900),
      pickupDateTime: DateTime.now().add(const Duration(hours: 2)),
      verificationCode: '1234',
      status: 'ready_for_checkout',
      total: 25.50,
      dishes: [],
    ),
    order_model.Order(
      id: 'cart-order-2',
      userId: 'test-user-id',
      username: 'testuser',
      restaurantId: 'restaurant-2',
      restaurantName: 'Pizzeria Napoli',
      restaurantAddress: 'Via Napoli 5, Milano',
      restaurantLocation: const GeoPoint(45.4650, 9.1910),
      pickupDateTime: DateTime.now().add(const Duration(hours: 4)),
      verificationCode: '5678',
      status: 'ready_for_checkout',
      total: 18.00,
      dishes: [],
    ),
  ];

  // Sample paid orders (not in cart)
  final testPaidOrders = <order_model.Order>[
    order_model.Order(
      id: 'paid-order-1',
      userId: 'test-user-id',
      username: 'testuser',
      restaurantId: 'restaurant-1',
      restaurantName: 'Ristorante Italiano',
      restaurantAddress: 'Via Roma 10, Milano',
      restaurantLocation: const GeoPoint(45.4642, 9.1900),
      pickupDateTime: DateTime.now().add(const Duration(hours: 2)),
      verificationCode: '9999',
      status: 'paid',
      total: 30.00,
      dishes: [],
    ),
  ];

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockOrderProvider = MockOrderProvider();
    mockStripeProvider = MockStripeProvider();

    // Stub default values for AuthProvider
    when(() => mockAuthProvider.user).thenReturn(testUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});

    // Stub default values for OrderProvider (with cart orders)
    when(() => mockOrderProvider.isLoading).thenReturn(false);
    when(() => mockOrderProvider.errorMessage).thenReturn(null);
    when(() => mockOrderProvider.userOrders).thenReturn(testCartOrders);
    when(
      () => mockOrderProvider.fetchUserOrders(
        any(),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => testCartOrders);
    when(() => mockOrderProvider.setContext(any())).thenReturn(null);
    when(() => mockOrderProvider.deleteOrder(any())).thenAnswer((_) async {});

    // Stub default values for StripeProvider
    when(() => mockStripeProvider.isLoading).thenReturn(false);
    when(() => mockStripeProvider.errorMessage).thenReturn(null);
    when(
      () => mockStripeProvider.processPayment(
        context: any(named: 'context'),
        amount: any(named: 'amount'),
        items: any(named: 'items'),
      ),
    ).thenAnswer((_) async => true);
  });

  setUpAll(() {
    registerFallbackValues();
  });

  // Helper to ignore overflow errors during tests
  void ignoreOverflowErrors(
    FlutterErrorDetails details, {
    bool forceReport = false,
  }) {
    bool ifIsOverflowError = false;
    final exception = details.exception;
    if (exception is FlutterError) {
      ifIsOverflowError = exception.diagnostics.any(
        (e) => e.value.toString().contains('overflowed'),
      );
    }
    if (!ifIsOverflowError) {
      FlutterError.presentError(details);
    }
  }

  group('CartScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with title "Cart"', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Cart'), findsOneWidget);
      });

      testWidgets('app bar is centered', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.centerTitle, isTrue);
      });

      testWidgets('displays Checkout button', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Checkout'), findsOneWidget);
      });

      testWidgets('displays AnimatedButton for checkout', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(AnimatedButton), findsOneWidget);
      });
    });

    // =========================================================================
    // LOADING STATE TESTS
    // =========================================================================

    group('Loading State', () {
      testWidgets('displays loading indicator when provider is loading', (
        tester,
      ) async {
        when(() => mockOrderProvider.isLoading).thenReturn(true);
        when(() => mockOrderProvider.userOrders).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();

        FlutterError.onError = originalOnError;

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('hides loading indicator after orders are loaded', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    // =========================================================================
    // EMPTY STATE TESTS
    // =========================================================================

    group('Empty State', () {
      testWidgets('displays empty message when no orders in cart', (
        tester,
      ) async {
        when(() => mockOrderProvider.userOrders).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('No orders in the cart!'), findsOneWidget);
      });

      testWidgets('displays empty message when only paid orders exist', (
        tester,
      ) async {
        when(() => mockOrderProvider.userOrders).thenReturn(testPaidOrders);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Paid orders should not appear - only ready_for_checkout orders
        expect(find.text('No orders in the cart!'), findsOneWidget);
      });

      testWidgets('does not show Checkout button when cart is empty', (
        tester,
      ) async {
        when(() => mockOrderProvider.userOrders).thenReturn([]);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Checkout'), findsNothing);
        expect(find.byType(AnimatedButton), findsNothing);
      });
    });

    // =========================================================================
    // CART ORDERS DISPLAY TESTS
    // =========================================================================

    group('Cart Orders Display', () {
      testWidgets('displays OrderCard for each order in cart', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Should find OrderCard widgets for each order
        expect(find.byType(OrderCard), findsNWidgets(2));
      });

      testWidgets('displays restaurant names in cart', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Ristorante Italiano'), findsOneWidget);
        expect(find.text('Pizzeria Napoli'), findsOneWidget);
      });

      testWidgets('displays remove button icon for orders', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(
          find.byIcon(Icons.remove_circle_outline_rounded),
          findsNWidgets(2),
        );
      });

      testWidgets('only displays ready_for_checkout orders', (tester) async {
        // Mix of cart and paid orders
        final mixedOrders = [...testCartOrders, ...testPaidOrders];
        when(() => mockOrderProvider.userOrders).thenReturn(mixedOrders);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Should only show 2 cart orders, not the paid one
        expect(find.byType(OrderCard), findsNWidgets(2));
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('calls fetchUserOrders on init when user is authenticated', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(
          () => mockOrderProvider.fetchUserOrders(
            testUser.id,
            forceRefresh: true,
          ),
        ).called(1);
      });

      testWidgets('calls setContext on init', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(() => mockOrderProvider.setContext(any())).called(1);
      });

      testWidgets('does not fetch orders when user is null', (tester) async {
        when(() => mockAuthProvider.user).thenReturn(null);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verifyNever(
          () => mockOrderProvider.fetchUserOrders(
            any(),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        );
      });
    });

    // =========================================================================
    // LAYOUT TESTS - MOBILE
    // =========================================================================

    group('Layout - Mobile (shortestSide < 600)', () {
      // Mobile size: 500x900 (shortestSide = 500)
      const mobileSize = Size(500, 900);

      testWidgets('renders app bar with title on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Cart'), findsOneWidget);
      });

      testWidgets('displays cart orders on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(OrderCard), findsNWidgets(2));
      });

      testWidgets('uses 16px horizontal padding on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Find Padding with horizontal 16.0
        final paddingFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.symmetric(horizontal: 16.0),
        );
        expect(paddingFinder, findsOneWidget);
      });

      testWidgets('displays Checkout button on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Checkout'), findsOneWidget);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET VERTICAL
    // =========================================================================

    group('Layout - Tablet Vertical (shortestSide >= 600, portrait)', () {
      // Tablet vertical size: 700x1000 (shortestSide = 700, portrait)
      const tabletVerticalSize = Size(700, 1000);

      testWidgets('renders app bar with title on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Cart'), findsOneWidget);
      });

      testWidgets('displays cart orders on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(OrderCard), findsNWidgets(2));
      });

      testWidgets('displays Checkout button on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Checkout'), findsOneWidget);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET HORIZONTAL
    // =========================================================================

    group('Layout - Tablet Horizontal (shortestSide >= 600, landscape)', () {
      // Tablet horizontal size: 1024x700 (shortestSide = 700, landscape)
      const tabletHorizontalSize = Size(1024, 700);

      testWidgets('renders app bar with title on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Cart'), findsOneWidget);
      });

      testWidgets('displays cart orders on tablet horizontal', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(OrderCard), findsNWidgets(2));
      });

      testWidgets('displays Checkout button on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Checkout'), findsOneWidget);
      });

      testWidgets('uses 16px horizontal padding on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const CartScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          stripeProvider: mockStripeProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Find Padding with horizontal 16.0
        final paddingFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.symmetric(horizontal: 16.0),
        );
        expect(paddingFinder, findsOneWidget);
      });
    });
  });
}
