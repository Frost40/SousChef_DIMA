import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/app_router.dart';
import 'package:sous_chef/models/dish.dart';
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
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

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
  late User mockRegularUser;
  late User mockOwnerUser;
  late Restaurant mockRestaurant;
  late List<Dish> mockDishes;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();
    mockUserProvider = MockUserProvider();
    mockRestaurantProvider = MockRestaurantProvider();
    mockDishProvider = MockDishProvider();
    mockOrderProvider = MockOrderProvider();
    mockStripeProvider = MockStripeProvider();
    mockThemeProvider = MockThemeProvider();

    // Create mock regular user (no restaurant)
    mockRegularUser = User(
      id: 'regular-user-123',
      email: 'regular@example.com',
      username: 'regularuser',
      name: 'Regular',
      surname: 'User',
      phone: '1234567890',
      savedAddress: '123 Test Street',
      latitude: 45.4642,
      longitude: 9.1900,
      restaurantId: null, // No restaurant - regular user
    );

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
      restaurantId: 'restaurant-123', // Has restaurant - owner
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

    // === StripeProvider stubs ===
    when(() => mockStripeProvider.isLoading).thenReturn(false);
    when(() => mockStripeProvider.errorMessage).thenReturn(null);

    // === ThemeProvider stubs ===
    when(() => mockThemeProvider.themeData).thenReturn(lightMode);
    when(() => mockThemeProvider.isDarkMode).thenReturn(false);
  });

  Widget buildTestApp({required User user}) {
    // Update UserProvider mock based on user
    when(() => mockUserProvider.userData).thenReturn(user);
    when(() => mockAuthProvider.user).thenReturn(user);

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

  group('Owner Navigation', () {
    testWidgets('should display 4 tabs for regular users (no restaurant)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(user: mockRegularUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find the StylishBottomBar
      final bottomBar = find.byType(StylishBottomBar);
      expect(bottomBar, findsOneWidget);

      // Verify 4 tabs for regular user: Home, Orders, Favorites, Account
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);

      // Restaurant tab should NOT be present
      expect(find.byIcon(Icons.restaurant_menu_rounded), findsNothing);
    });

    testWidgets('should display 5 tabs for restaurant owners', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(user: mockOwnerUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find the StylishBottomBar
      final bottomBar = find.byType(StylishBottomBar);
      expect(bottomBar, findsOneWidget);

      // Verify 5 tabs for owner: Home, Orders, Restaurant, Favorites, Account
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
      expect(
        find.byIcon(Icons.restaurant_menu_rounded),
        findsOneWidget,
      ); // Extra tab for owners
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets(
      'should navigate to Restaurant screen when owner taps Restaurant tab',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(user: mockOwnerUser));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Tap on Restaurant tab (index 2 for owners)
        final restaurantTab = find.byIcon(Icons.restaurant_menu_rounded);
        expect(restaurantTab, findsOneWidget);

        await tester.tap(restaurantTab);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Should show restaurant name
        expect(find.text('Test Restaurant'), findsOneWidget);
      },
    );

    testWidgets('should show correct tab labels for owner', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(user: mockOwnerUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify all 5 tab labels exist
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Restaurant'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('should show correct tab labels for regular user', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(user: mockRegularUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify only 4 tab labels exist (no Restaurant)
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(
        find.text('Restaurant'),
        findsNothing,
      ); // Not present for regular users
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });
  });
}
