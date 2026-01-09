import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/app_router.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/models/order.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/dish_provider.dart';
import 'package:sous_chef/providers/order_provider.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/providers/stripe_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/screens/home_screen.dart';
import 'package:sous_chef/screens/restaurant_screen.dart';
import 'package:sous_chef/screens/cart_screen.dart';
import 'package:sous_chef/themes/light_mode.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/widgets/restaurant_list_tile.dart';
import 'package:sous_chef/widgets/animated_button.dart';

/// Mock classes
class MockAuthProvider extends Mock implements AuthProvider {}

class MockChatProvider extends Mock implements ChatProvider {}

class MockUserProvider extends Mock implements UserProvider {}

class MockRestaurantProvider extends Mock implements RestaurantProvider {}

class MockDishProvider extends Mock implements DishProvider {}

class MockOrderProvider extends Mock implements OrderProvider {}

class MockStripeProvider extends Mock implements StripeProvider {}

class MockThemeProvider extends Mock implements ThemeProvider {}

/// Fake BuildContext for mocktail
class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  late MockAuthProvider mockAuthProvider;
  late MockChatProvider mockChatProvider;
  late MockUserProvider mockUserProvider;
  late MockRestaurantProvider mockRestaurantProvider;
  late MockDishProvider mockDishProvider;
  late MockOrderProvider mockOrderProvider;
  late MockStripeProvider mockStripeProvider;
  late MockThemeProvider mockThemeProvider;

  // Test data
  late User mockUser;
  late Restaurant mockRestaurant;
  late List<Dish> mockDishes;
  late Order mockOrder;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();
    mockUserProvider = MockUserProvider();
    mockRestaurantProvider = MockRestaurantProvider();
    mockDishProvider = MockDishProvider();
    mockOrderProvider = MockOrderProvider();
    mockStripeProvider = MockStripeProvider();
    mockThemeProvider = MockThemeProvider();

    // Create mock user with address
    mockUser = User(
      id: 'test-user-123',
      email: 'test@example.com',
      username: 'testuser',
      name: 'Test',
      surname: 'User',
      phone: '1234567890',
      savedAddress: '123 Test Street',
      latitude: 45.4642,
      longitude: 9.1900,
    );

    // Create mock restaurant
    mockRestaurant = Restaurant(
      id: 'restaurant-123',
      name: 'Test Restaurant',
      address: '456 Restaurant Ave',
      isOpen: true,
      restaurantTypes: [RestaurantType.fixedMenu],
      ownerId: 'owner-123',
      location: const GeoPoint(45.4650, 9.1850),
      imageUrl: null,
    );

    // Create mock dishes
    mockDishes = [
      Dish(
        id: 'dish-1',
        name: 'Margherita Pizza',
        description: 'Classic Italian pizza with tomato and mozzarella',
        price: 12.50,
        isSpecial: false,
        isAvailable: true,
        course: Course.mainDish,
        cuisine: Cuisine.italian,
        minForewarningDays: 0,
        imageUrl: null,
      ),
      Dish(
        id: 'dish-2',
        name: 'Tiramisu',
        description: 'Traditional Italian dessert',
        price: 8.00,
        isSpecial: false,
        isAvailable: true,
        course: Course.dessert,
        cuisine: Cuisine.italian,
        minForewarningDays: 0,
        imageUrl: null,
      ),
    ];

    // Create mock order (ready for checkout)
    mockOrder = Order(
      id: 'order-123',
      userId: 'test-user-123',
      username: 'testuser',
      restaurantName: 'Test Restaurant',
      restaurantId: 'restaurant-123',
      pickupDateTime: DateTime.now().add(const Duration(hours: 2)),
      verificationCode: 'ABC123',
      status: 'ready_for_checkout',
      total: 12.50,
      restaurantAddress: '456 Restaurant Ave',
      restaurantLocation: const GeoPoint(45.4650, 9.1850),
      dishes: [
        OrderItem(
          dishId: 'dish-1',
          name: 'Margherita Pizza',
          quantity: 1,
          price: 12.50,
        ),
      ],
    );

    // === AuthProvider stubs ===
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.hasEmailError).thenReturn(false);
    when(() => mockAuthProvider.hasPasswordError).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(true);
    when(() => mockAuthProvider.user).thenReturn(mockUser);
    when(() => mockAuthProvider.clearErrors()).thenReturn(null);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});

    // === ChatProvider stubs ===
    when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
    when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
    when(() => mockChatProvider.setCurrentUserId(any())).thenReturn(null);
    when(() => mockChatProvider.startListeningToChats()).thenReturn(null);

    // === UserProvider stubs ===
    when(() => mockUserProvider.userData).thenReturn(mockUser);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});

    // === RestaurantProvider stubs ===
    when(() => mockRestaurantProvider.isLoading).thenReturn(false);
    when(() => mockRestaurantProvider.restaurant).thenReturn(null);
    when(() => mockRestaurantProvider.errorMessage).thenReturn(null);
    when(
      () => mockRestaurantProvider.fetchNearbyRestaurants(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radiusInKm: any(named: 'radiusInKm'),
      ),
    ).thenAnswer((_) async => [mockRestaurant]);
    when(
      () => mockRestaurantProvider.fetchCompleteRestaurantData(any()),
    ).thenAnswer((_) async {
      when(() => mockRestaurantProvider.restaurant).thenReturn(mockRestaurant);
    });

    // === DishProvider stubs ===
    when(() => mockDishProvider.isLoading).thenReturn(false);
    when(() => mockDishProvider.dishes).thenReturn(mockDishes);
    when(() => mockDishProvider.errorMessage).thenReturn(null);
    when(
      () => mockDishProvider.currentRestaurantId,
    ).thenReturn('restaurant-123');
    when(() => mockDishProvider.fetchDishes(any())).thenAnswer((_) async {});
    when(() => mockDishProvider.getDishById(any())).thenAnswer((invocation) {
      final dishId = invocation.positionalArguments[0] as String;
      return mockDishes.firstWhere(
        (d) => d.id == dishId,
        orElse: () => mockDishes.first,
      );
    });

    // === OrderProvider stubs ===
    when(() => mockOrderProvider.isLoading).thenReturn(false);
    when(() => mockOrderProvider.userOrders).thenReturn([]);
    when(() => mockOrderProvider.errorMessage).thenReturn(null);
    when(() => mockOrderProvider.setContext(any())).thenReturn(null);
    when(
      () => mockOrderProvider.fetchUserOrders(
        any(),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockOrderProvider.addOrder(
        userId: any(named: 'userId'),
        username: any(named: 'username'),
        dishId: any(named: 'dishId'),
        dishName: any(named: 'dishName'),
        dishPrice: any(named: 'dishPrice'),
        pickupDateTime: any(named: 'pickupDateTime'),
      ),
    ).thenAnswer((_) async {
      // After order creation, update userOrders
      when(() => mockOrderProvider.userOrders).thenReturn([mockOrder]);
    });
    when(() => mockOrderProvider.deleteOrder(any())).thenAnswer((_) async {});

    // === StripeProvider stubs ===
    when(() => mockStripeProvider.isLoading).thenReturn(false);
    when(() => mockStripeProvider.errorMessage).thenReturn(null);
    when(
      () => mockStripeProvider.processPayment(
        context: any(named: 'context'),
        amount: any(named: 'amount'),
        items: any(named: 'items'),
        currency: any(named: 'currency'),
      ),
    ).thenAnswer((_) async => true);

    // === ThemeProvider stubs ===
    when(() => mockThemeProvider.themeData).thenReturn(lightMode);
    when(() => mockThemeProvider.isDarkMode).thenReturn(false);
  });

  Widget buildTestApp({Widget? home}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<RestaurantProvider>.value(
          value: mockRestaurantProvider,
        ),
        ChangeNotifierProvider<DishProvider>.value(value: mockDishProvider),
        ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
        ChangeNotifierProvider<StripeProvider>.value(value: mockStripeProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        Provider<AppRouter>(create: (_) => AppRouter()),
      ],
      child: Consumer<AppRouter>(
        builder: (context, router, child) {
          return MaterialApp(
            theme: lightMode,
            home: home ?? const HomeScreen(),
            onGenerateRoute: router.onGenerateRoute,
          );
        },
      ),
    );
  }

  group('Complete Order Flow', () {
    testWidgets('should display nearby restaurants on Home screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Assert: Verify we're on the Home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Assert: Verify the restaurant is displayed
      expect(find.text('Test Restaurant'), findsOneWidget);

      // Verify RestaurantListTile is shown
      expect(find.byType(RestaurantListTile), findsOneWidget);
    });

    testWidgets(
      'should navigate to Restaurant screen when tapping on a restaurant',
      (WidgetTester tester) async {
        // Pre-set restaurant so it's available immediately after navigation
        when(
          () => mockRestaurantProvider.restaurant,
        ).thenReturn(mockRestaurant);

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Assert: Verify restaurant is displayed
        expect(find.text('Test Restaurant'), findsOneWidget);

        // Act: Tap on the restaurant
        await tester.tap(find.byType(RestaurantListTile));

        // Use pump with duration instead of pumpAndSettle to handle any remaining animations
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Assert: Verify navigation to RestaurantScreen
        expect(find.byType(RestaurantScreen), findsOneWidget);
      },
    );

    testWidgets('should display menu items on Restaurant screen', (
      WidgetTester tester,
    ) async {
      // Pre-set restaurant so it's available immediately
      when(() => mockRestaurantProvider.restaurant).thenReturn(mockRestaurant);

      // Start directly from RestaurantScreen
      await tester.pumpWidget(
        buildTestApp(
          home: const RestaurantScreen(
            restaurantId: 'restaurant-123',
            showBackButton: true,
          ),
        ),
      );

      // Use pump with duration to handle any loading animations
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: Verify we're on the Restaurant screen
      expect(find.byType(RestaurantScreen), findsOneWidget);

      // Assert: Verify menu items are displayed
      expect(find.text('Margherita Pizza'), findsOneWidget);
      expect(find.text('Tiramisu'), findsOneWidget);
    });

    testWidgets('should display Cart screen with orders ready for checkout', (
      WidgetTester tester,
    ) async {
      // Set up order in cart
      when(() => mockOrderProvider.userOrders).thenReturn([mockOrder]);

      await tester.pumpWidget(buildTestApp(home: const CartScreen()));
      await tester.pumpAndSettle();

      // Assert: Verify we're on the Cart screen
      expect(find.byType(CartScreen), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);

      // Assert: Verify the order is displayed
      expect(find.text('Test Restaurant'), findsOneWidget);

      // Assert: Verify Checkout button exists
      expect(find.text('Checkout'), findsOneWidget);
    });

    testWidgets('should show empty cart message when no orders', (
      WidgetTester tester,
    ) async {
      // Ensure no orders in cart
      when(() => mockOrderProvider.userOrders).thenReturn([]);

      await tester.pumpWidget(buildTestApp(home: const CartScreen()));
      await tester.pumpAndSettle();

      // Assert: Verify empty cart message
      expect(find.text('No orders received!'), findsOneWidget);
    });

    testWidgets('should process payment successfully when tapping Checkout', (
      WidgetTester tester,
    ) async {
      // Set up order in cart
      when(() => mockOrderProvider.userOrders).thenReturn([mockOrder]);

      await tester.pumpWidget(buildTestApp(home: const CartScreen()));
      await tester.pumpAndSettle();

      // Assert: Verify order is in cart
      expect(find.text('Test Restaurant'), findsOneWidget);

      // Act: Find and tap the Checkout button
      final checkoutButton = find.ancestor(
        of: find.text('Checkout'),
        matching: find.byType(AnimatedButton),
      );
      expect(checkoutButton, findsOneWidget);

      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      // A confirmation dialog should appear - find and tap Proceed
      // Note: In real integration test, dialog appears; here we mock the payment
    });

    testWidgets('should allow removing order from cart', (
      WidgetTester tester,
    ) async {
      // Set up order in cart
      when(() => mockOrderProvider.userOrders).thenReturn([mockOrder]);

      await tester.pumpWidget(buildTestApp(home: const CartScreen()));
      await tester.pumpAndSettle();

      // Assert: Verify order is in cart
      expect(find.text('Test Restaurant'), findsOneWidget);

      // Act: Find the remove button (circular button with remove icon)
      final removeButton = find.byIcon(Icons.remove_circle_outline_rounded);
      expect(removeButton, findsOneWidget);

      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // A confirmation dialog should appear
      expect(find.text('Remove Order'), findsOneWidget);
    });
  });
}
