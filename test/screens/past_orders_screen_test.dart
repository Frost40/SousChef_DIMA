import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/order.dart' as order_model;
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/past_orders_screen.dart';
import 'package:sous_chef/widgets/order_card.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockOrderProvider mockOrderProvider;

  // Screen sizes for different layouts
  const mobileSize = Size(400, 800);
  const tabletVerticalSize = Size(800, 1200);
  const tabletHorizontalSize = Size(1200, 800);

  // Sample test user
  final testUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
  );

  // Sample completed orders
  final testCompletedOrders = <order_model.Order>[
    order_model.Order(
      id: 'completed-order-1',
      userId: 'test-user-id',
      username: 'testuser',
      restaurantId: 'restaurant-1',
      restaurantName: 'Ristorante Italiano',
      restaurantAddress: 'Via Roma 10, Milano',
      restaurantLocation: const GeoPoint(45.4642, 9.1900),
      pickupDateTime: DateTime(2025, 12, 15, 14, 30),
      verificationCode: '1234',
      status: 'completed',
      total: 25.50,
      dishes: [
        order_model.OrderItem(
          dishId: 'dish-1',
          name: 'Pasta Carbonara',
          quantity: 2,
          price: 12.50,
        ),
      ],
    ),
    order_model.Order(
      id: 'completed-order-2',
      userId: 'test-user-id',
      username: 'testuser',
      restaurantId: 'restaurant-2',
      restaurantName: 'Pizzeria Napoli',
      restaurantAddress: 'Via Napoli 5, Milano',
      restaurantLocation: const GeoPoint(45.4650, 9.1910),
      pickupDateTime: DateTime(2025, 12, 10, 18, 00),
      verificationCode: '5678',
      status: 'completed',
      total: 18.00,
      dishes: [
        order_model.OrderItem(
          dishId: 'dish-2',
          name: 'Pizza Margherita',
          quantity: 1,
          price: 10.00,
        ),
        order_model.OrderItem(
          dishId: 'dish-3',
          name: 'Tiramisu',
          quantity: 1,
          price: 8.00,
        ),
      ],
    ),
  ];

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockOrderProvider = MockOrderProvider();

    // Stub default values for AuthProvider
    when(() => mockAuthProvider.user).thenReturn(testUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);

    // Stub default values for OrderProvider
    when(() => mockOrderProvider.isLoading).thenReturn(false);
    when(() => mockOrderProvider.errorMessage).thenReturn(null);
    when(
      () => mockOrderProvider.fetchUserCompletedOrders(any()),
    ).thenAnswer((_) async => testCompletedOrders);
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

  group('PastOrdersScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with title when not embedded', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Orders completed'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('does not render app bar when embedded', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        // Should NOT have an AppBar when embedded
        expect(find.byType(AppBar), findsNothing);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders back button when not embedded', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders OrderCard for each completed order', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        // Should have 2 OrderCard widgets
        expect(find.byType(OrderCard), findsNWidgets(2));

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays restaurant names in order cards', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Ristorante Italiano'), findsOneWidget);
        expect(find.text('Pizzeria Napoli'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LOADING STATE TESTS
    // =========================================================================

    group('Loading State', () {
      testWidgets('shows loading indicator when not initialized', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        // Don't pumpAndSettle to catch loading state
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsWidgets);

        FlutterError.onError = originalOnError;
      });

      testWidgets('shows loading indicator when provider is loading', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        when(() => mockOrderProvider.isLoading).thenReturn(true);

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CircularProgressIndicator), findsWidgets);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // EMPTY STATE TESTS
    // =========================================================================

    group('Empty State', () {
      testWidgets('displays empty message when no completed orders', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        when(
          () => mockOrderProvider.fetchUserCompletedOrders(any()),
        ).thenAnswer((_) async => []);

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('There are no completed orders yet'), findsOneWidget);
        expect(find.byType(OrderCard), findsNothing);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('calls fetchUserCompletedOrders on initialization', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        verify(
          () => mockOrderProvider.fetchUserCompletedOrders('test-user-id'),
        ).called(1);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - MOBILE
    // =========================================================================

    group('Layout - Mobile', () {
      testWidgets('uses full width layout on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        // On mobile, uses Padding (not wrapped in Align + SizedBox)
        expect(find.byType(Padding), findsWidgets);
        expect(find.byType(OrderCard), findsNWidgets(2));

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays app bar on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Orders completed'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET VERTICAL
    // =========================================================================

    group('Layout - Tablet Vertical', () {
      testWidgets('uses full width layout on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletVerticalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(Padding), findsWidgets);
        expect(find.byType(OrderCard), findsNWidgets(2));

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays app bar on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletVerticalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Orders completed'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET HORIZONTAL
    // =========================================================================

    group('Layout - Tablet Horizontal', () {
      testWidgets('uses centered constrained layout on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        // Should use Align with center alignment and SizedBox with width 600
        expect(find.byType(Align), findsWidgets);

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays all order cards on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(OrderCard), findsNWidgets(2));
        expect(find.text('Ristorante Italiano'), findsOneWidget);
        expect(find.text('Pizzeria Napoli'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('does not show AppBar when embedded on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsNothing);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // EMBEDDED MODE TESTS
    // =========================================================================

    group('Embedded Mode', () {
      testWidgets('isEmbedded false shows AppBar', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Orders completed'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('isEmbedded true hides AppBar', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const PastOrdersScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsNothing);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // ORDER DISPLAY TESTS
    // =========================================================================

    group('Order Display', () {
      testWidgets('displays restaurant addresses', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        try {
          await tester.pumpApp(
            const PastOrdersScreen(isEmbedded: false),
            authProvider: mockAuthProvider,
            orderProvider: mockOrderProvider,
            screenSize: mobileSize,
          );
          await tester.pumpAndSettle();

          // Verify the order cards contain address information
          expect(find.textContaining('Via Roma'), findsOneWidget);
          expect(find.textContaining('Via Napoli'), findsOneWidget);
        } finally {
          FlutterError.onError = originalOnError;
        }
      });
    });
  });
}
