import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/order.dart' as order_model;
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/orders_screen.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';
import 'package:sous_chef/widgets/order_screen/order.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockOrderProvider mockOrderProvider;

  // Sample normal user (not a restaurant)
  final testNormalUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
    restaurantId: null,
  );

  // Sample restaurant user
  final testRestaurantUser = User(
    id: 'restaurant-user-id',
    email: 'restaurant@example.com',
    username: 'restaurantuser',
    name: 'Restaurant',
    surname: 'Owner',
    phone: '0987654321',
    restaurantId: 'restaurant-123',
  );

  // Sample orders
  final testOrders = <order_model.Order>[
    order_model.Order(
      id: 'order-1',
      userId: 'test-user-id',
      username: 'testuser',
      restaurantId: 'restaurant-1',
      restaurantName: 'Ristorante Italiano',
      restaurantAddress: 'Via Roma 10, Milano',
      restaurantLocation: const GeoPoint(45.4642, 9.1900),
      pickupDateTime: DateTime.now().add(const Duration(hours: 2)),
      verificationCode: '1234',
      status: 'paid',
      total: 25.50,
      dishes: [],
    ),
    order_model.Order(
      id: 'order-2',
      userId: 'test-user-id',
      username: 'testuser',
      restaurantId: 'restaurant-2',
      restaurantName: 'Pizzeria Napoli',
      restaurantAddress: 'Via Napoli 5, Milano',
      restaurantLocation: const GeoPoint(45.4650, 9.1910),
      pickupDateTime: DateTime.now().add(const Duration(hours: 4)),
      verificationCode: '5678',
      status: 'paid',
      total: 18.00,
      dishes: [],
    ),
  ];

  // Sample received orders for restaurant
  final testReceivedOrders = <order_model.Order>[
    order_model.Order(
      id: 'received-order-1',
      userId: 'customer-1',
      username: 'customer1',
      restaurantId: 'restaurant-123',
      restaurantName: 'My Restaurant',
      restaurantAddress: 'Via Test 1',
      restaurantLocation: const GeoPoint(45.0, 9.0),
      pickupDateTime: DateTime.now().add(const Duration(hours: 1)),
      verificationCode: 'ABCD',
      status: 'paid',
      total: 35.00,
      dishes: [],
    ),
  ];

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockOrderProvider = MockOrderProvider();

    // Stub default values for AuthProvider (normal user)
    when(() => mockAuthProvider.user).thenReturn(testNormalUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});

    // Stub default values for OrderProvider
    when(() => mockOrderProvider.isLoading).thenReturn(false);
    when(() => mockOrderProvider.errorMessage).thenReturn(null);
    when(
      () => mockOrderProvider.fetchUserPaidOrders(any()),
    ).thenAnswer((_) async => testOrders);
    when(
      () => mockOrderProvider.fetchRestaurantReceivedOrders(any()),
    ).thenAnswer((_) async => testReceivedOrders);
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

  group('OrdersScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with title "Orders"', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Orders'), findsOneWidget);
      });

      testWidgets('app bar is centered', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.centerTitle, isTrue);
      });
    });

    // =========================================================================
    // LOADING STATE TESTS
    // =========================================================================

    group('Loading State', () {
      testWidgets('hides loading indicator after orders are loaded', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // After loading completes, no loading indicator
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    // =========================================================================
    // EMPTY STATE TESTS
    // =========================================================================

    group('Empty State', () {
      testWidgets('shows "No orders yet" when user has no orders', (
        tester,
      ) async {
        when(
          () => mockOrderProvider.fetchUserPaidOrders(any()),
        ).thenAnswer((_) async => []);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('No orders yet'), findsOneWidget);
      });
    });

    // =========================================================================
    // ORDERS LIST TESTS
    // =========================================================================

    group('Orders List', () {
      testWidgets('displays OrderTile for each order', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(OrderTile), findsWidgets);
      });

      testWidgets('displays restaurant names in orders', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Ristorante Italiano'), findsOneWidget);
        expect(find.text('Pizzeria Napoli'), findsOneWidget);
      });
    });

    // =========================================================================
    // RESTAURANT VIEW TESTS
    // =========================================================================

    group('Restaurant View', () {
      setUp(() {
        // Configure as restaurant user
        when(() => mockAuthProvider.user).thenReturn(testRestaurantUser);
      });

      testWidgets('shows NavigationTabbar for restaurant users', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(NavigationTabbar), findsOneWidget);
      });

      testWidgets(
        'shows "Received Orders" and "My Orders" tabs for restaurant',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const OrdersScreen(),
            authProvider: mockAuthProvider,
            orderProvider: mockOrderProvider,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          expect(find.text('Received Orders'), findsOneWidget);
          expect(find.text('My Orders'), findsOneWidget);
        },
      );

      testWidgets(
        'shows "No incoming orders yet" when restaurant has no received orders',
        (tester) async {
          when(
            () => mockOrderProvider.fetchRestaurantReceivedOrders(any()),
          ).thenAnswer((_) async => []);

          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const OrdersScreen(),
            authProvider: mockAuthProvider,
            orderProvider: mockOrderProvider,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          expect(find.text('No incoming orders yet'), findsOneWidget);
        },
      );
    });

    // =========================================================================
    // NORMAL USER TESTS
    // =========================================================================

    group('Normal User View', () {
      testWidgets('does NOT show NavigationTabbar for normal users', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(NavigationTabbar), findsNothing);
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('calls fetchUserPaidOrders for normal users', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(
          () => mockOrderProvider.fetchUserPaidOrders(testNormalUser.id),
        ).called(greaterThan(0));
      });

      testWidgets('calls fetchRestaurantReceivedOrders for restaurant users', (
        tester,
      ) async {
        when(() => mockAuthProvider.user).thenReturn(testRestaurantUser);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(
          () => mockOrderProvider.fetchRestaurantReceivedOrders(
            testRestaurantUser.restaurantId!,
          ),
        ).called(greaterThan(0));
      });
    });

    // =========================================================================
    // LAYOUT TESTS - Mobile, Tablet Vertical, Tablet Horizontal
    // =========================================================================
    // Layout detection:
    // - Mobile: shortestSide < 600
    // - Tablet Vertical: shortestSide >= 600 && portrait
    // - Tablet Horizontal: shortestSide >= 600 && landscape
    // =========================================================================

    group('Layout - Mobile (shortestSide < 600)', () {
      // Mobile size: 500x900 (shortestSide = 500 < 600)
      const mobileSize = Size(500, 900);

      testWidgets('renders app bar with title on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Orders'), findsOneWidget);
      });

      testWidgets('displays orders list on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(OrderTile), findsWidgets);
      });

      testWidgets('uses 16px horizontal padding on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
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
    });

    group('Layout - Tablet Vertical (shortestSide >= 600, portrait)', () {
      // Tablet vertical size: 700x1000 (shortestSide = 700, portrait)
      const tabletVerticalSize = Size(700, 1000);

      testWidgets('renders app bar with title on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Orders'), findsOneWidget);
      });

      testWidgets('displays orders list on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(OrderTile), findsWidgets);
      });

      testWidgets('uses 24px horizontal padding on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Find Padding with horizontal 24.0
        final paddingFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.symmetric(horizontal: 24.0),
        );
        expect(paddingFinder, findsOneWidget);
      });
    });

    group('Layout - Tablet Horizontal (shortestSide >= 600, landscape)', () {
      // Tablet horizontal size: 1024x700 (shortestSide = 700, landscape)
      const tabletHorizontalSize = Size(1024, 700);

      testWidgets('renders app bar with title on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Orders'), findsOneWidget);
      });

      testWidgets('displays orders list on tablet horizontal', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(OrderTile), findsWidgets);
      });

      testWidgets(
        'uses centered layout with fixed width 600 on tablet horizontal',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const OrdersScreen(),
            authProvider: mockAuthProvider,
            orderProvider: mockOrderProvider,
            screenSize: tabletHorizontalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          // Find SizedBox with width 600 for centered orders
          final sizedBoxFinder = find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == 600,
          );
          expect(sizedBoxFinder, findsOneWidget);
        },
      );

      testWidgets('uses 24px horizontal padding on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const OrdersScreen(),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Find Padding with horizontal 24.0
        final paddingFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.symmetric(horizontal: 24.0),
        );
        expect(paddingFinder, findsOneWidget);
      });
    });
  });
}
