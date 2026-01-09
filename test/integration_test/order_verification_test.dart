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
import 'package:sous_chef/screens/main_layout.dart';
import 'package:sous_chef/themes/light_mode.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/widgets/order_screen/order.dart';
import 'package:sous_chef/widgets/order_screen/verification_code_input.dart';

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
  late User mockOwnerUser;
  late Restaurant mockRestaurant;
  late List<Dish> mockDishes;
  late List<Order> mockReceivedOrders;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();
    mockUserProvider = MockUserProvider();
    mockRestaurantProvider = MockRestaurantProvider();
    mockDishProvider = MockDishProvider();
    mockOrderProvider = MockOrderProvider();
    mockStripeProvider = MockStripeProvider();
    mockThemeProvider = MockThemeProvider();

    // Create mock owner user (has restaurant)
    mockOwnerUser = User(
      id: 'owner-user-123',
      email: 'owner@example.com',
      username: 'owneruser',
      name: 'Owner',
      surname: 'User',
      phone: '0987654321',
      savedAddress: '456 Owner Street',
      latitude: 45.4650,
      longitude: 9.1850,
      restaurantId: 'restaurant-123',
    );

    // Create mock restaurant
    mockRestaurant = Restaurant(
      id: 'restaurant-123',
      name: 'Test Restaurant',
      address: '456 Restaurant Ave',
      isOpen: true,
      restaurantTypes: [RestaurantType.fixedMenu],
      ownerId: 'owner-user-123',
      location: const GeoPoint(45.4650, 9.1850),
      imageUrl: null,
    );

    // Create mock dishes
    mockDishes = [
      Dish(
        id: 'dish-1',
        name: 'Margherita Pizza',
        description: 'Classic Italian pizza',
        price: 12.50,
        course: Course.mainDish,
        cuisine: Cuisine.italian,
        isAvailable: true,
        isSpecial: false,
        imageUrl: null,
      ),
    ];

    // Create mock received orders for the restaurant (single order for cleaner tests)
    mockReceivedOrders = [
      Order(
        id: 'order-001',
        userId: 'customer-user-123',
        username: 'John Customer',
        restaurantName: 'Test Restaurant',
        restaurantId: 'restaurant-123',
        pickupDateTime: DateTime.now().add(const Duration(hours: 1)),
        verificationCode: '123456',
        status: 'paid',
        total: 25.00,
        restaurantAddress: '456 Restaurant Ave',
        restaurantLocation: const GeoPoint(45.4650, 9.1850),
        dishes: [
          OrderItem(
            dishId: 'dish-1',
            name: 'Margherita Pizza',
            quantity: 2,
            price: 12.50,
          ),
        ],
      ),
    ];

    // === AuthProvider stubs ===
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.hasEmailError).thenReturn(false);
    when(() => mockAuthProvider.hasPasswordError).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(true);
    when(() => mockAuthProvider.user).thenReturn(mockOwnerUser);
    when(() => mockAuthProvider.clearErrors()).thenReturn(null);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});

    // === ChatProvider stubs ===
    when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
    when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
    when(() => mockChatProvider.setCurrentUserId(any())).thenReturn(null);
    when(() => mockChatProvider.startListeningToChats()).thenReturn(null);

    // === UserProvider stubs ===
    when(() => mockUserProvider.userData).thenReturn(mockOwnerUser);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});

    // === RestaurantProvider stubs ===
    when(() => mockRestaurantProvider.isLoading).thenReturn(false);
    when(() => mockRestaurantProvider.restaurant).thenReturn(mockRestaurant);
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
    ).thenAnswer((_) async {});

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
      () => mockOrderProvider.fetchRestaurantReceivedOrders(any()),
    ).thenAnswer((_) async => mockReceivedOrders);
    when(
      () => mockOrderProvider.fetchUserPaidOrders(any()),
    ).thenAnswer((_) async => []);
    when(
      () => mockOrderProvider.verifyAndCompleteOrder(any(), any()),
    ).thenAnswer((invocation) async {
      final inputCode = invocation.positionalArguments[1] as String;
      // Simulate correct code verification
      return inputCode == '123456';
    });

    // === StripeProvider stubs ===
    when(() => mockStripeProvider.isLoading).thenReturn(false);
    when(() => mockStripeProvider.errorMessage).thenReturn(null);

    // === ThemeProvider stubs ===
    when(() => mockThemeProvider.themeData).thenReturn(lightMode);
    when(() => mockThemeProvider.isDarkMode).thenReturn(false);
  });

  Widget buildTestApp() {
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
      child: MaterialApp(theme: lightMode, home: const MainLayout()),
    );
  }

  group('Order Verification Flow', () {
    testWidgets('should navigate from home to orders screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on Orders tab (second icon in bottom nav for owner)
      final ordersIcon = find.byIcon(Icons.receipt_long_rounded);
      expect(ordersIcon, findsOneWidget);
      await tester.tap(ordersIcon);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we're on Orders screen (appears in app bar and bottom nav)
      expect(find.text('Orders'), findsAtLeast(1));
    });

    testWidgets('should display received orders tab for restaurant owner', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Orders
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify navigation tabs are present for restaurant owner
      expect(find.text('Received Orders'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
    });

    testWidgets('should display received order from customer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Orders
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify order is displayed
      expect(find.byType(OrderTile), findsOneWidget);
      expect(find.text('John Customer'), findsOneWidget);
    });

    testWidgets('should expand order tile to show verify button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Orders
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on first order to expand it
      final firstOrder = find.text('John Customer');
      expect(firstOrder, findsOneWidget);
      await tester.tap(firstOrder);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify the "Verify Pickup Code" button is visible
      expect(find.text('Verify Pickup Code'), findsOneWidget);
    });

    testWidgets(
      'should open verification code dialog when tapping verify button',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Navigate to Orders
        await tester.tap(find.byIcon(Icons.receipt_long_rounded));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Tap on first order to expand it
        await tester.tap(find.text('John Customer'));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Tap on Verify Pickup Code button
        final verifyButton = find.text('Verify Pickup Code');
        expect(verifyButton, findsOneWidget);
        await tester.tap(verifyButton);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Verify dialog is shown
        expect(find.byType(VerificationCodeInput), findsOneWidget);
        expect(find.text('Verify Pickup Code'), findsWidgets);
        expect(
          find.text('Enter the 6-digit code shown by the customer:'),
          findsOneWidget,
        );
      },
    );

    testWidgets('should show error when entering invalid code', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Orders
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on first order to expand it
      await tester.tap(find.text('John Customer'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on Verify Pickup Code button
      await tester.tap(find.text('Verify Pickup Code'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter invalid code (less than 6 digits)
      final codeField = find.byType(TextField);
      expect(codeField, findsOneWidget);
      await tester.enterText(codeField, '123');
      await tester.pump();

      // Tap Verify button in dialog
      final dialogVerifyButton = find.widgetWithText(ElevatedButton, 'Verify');
      expect(dialogVerifyButton, findsOneWidget);
      await tester.tap(dialogVerifyButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify error message is shown
      expect(find.text('Code must be 6 digits'), findsOneWidget);
    });

    testWidgets('should show error when entering wrong verification code', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Orders
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on first order to expand it
      await tester.tap(find.text('John Customer'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on Verify Pickup Code button
      await tester.tap(find.text('Verify Pickup Code'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter wrong 6-digit code
      final codeField = find.byType(TextField);
      await tester.enterText(codeField, '999999');
      await tester.pump();

      // Tap Verify button in dialog
      final dialogVerifyButton = find.widgetWithText(ElevatedButton, 'Verify');
      await tester.tap(dialogVerifyButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify error message for invalid code
      expect(find.text('Invalid code. Please try again.'), findsOneWidget);
    });

    testWidgets('should successfully verify order with correct code', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Orders
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on first order to expand it
      await tester.tap(find.text('John Customer'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on Verify Pickup Code button
      await tester.tap(find.text('Verify Pickup Code'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter correct code
      final codeField = find.byType(TextField);
      await tester.enterText(codeField, '123456');
      await tester.pump();

      // Tap Verify button in dialog
      final dialogVerifyButton = find.widgetWithText(ElevatedButton, 'Verify');
      await tester.tap(dialogVerifyButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify the verifyAndCompleteOrder was called with correct parameters
      verify(
        () => mockOrderProvider.verifyAndCompleteOrder('order-001', '123456'),
      ).called(1);
    });

    testWidgets('should close dialog when cancel is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Orders
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on first order to expand it
      await tester.tap(find.text('John Customer'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on Verify Pickup Code button
      await tester.tap(find.text('Verify Pickup Code'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify dialog is shown
      expect(find.byType(VerificationCodeInput), findsOneWidget);

      // Tap Cancel button
      final cancelButton = find.widgetWithText(TextButton, 'Cancel');
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify dialog is closed
      expect(find.byType(VerificationCodeInput), findsNothing);
    });

    testWidgets('should display order details when expanded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Orders
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on first order to expand it
      await tester.tap(find.text('John Customer'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify order details are shown
      expect(find.text('2x'), findsOneWidget); // Quantity
      expect(find.text('Margherita Pizza'), findsAtLeast(1)); // Dish name
    });
  });
}
