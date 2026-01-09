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
import 'package:sous_chef/screens/home_screen.dart';
import 'package:sous_chef/themes/light_mode.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/widgets/home_screen/distance_selector.dart';
import 'package:sous_chef/widgets/restaurant_list_tile.dart';
import 'package:sous_chef/widgets/favorite_icon_button.dart';

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
  late User mockUser;
  late Restaurant mockRestaurant;
  late Restaurant mockFarRestaurant;
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

    // Create mock user with address (no favorites initially)
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
      favourites: [], // Empty favorites initially
    );

    // Create mock nearby restaurant (within 3km)
    mockRestaurant = Restaurant(
      id: 'restaurant-123',
      name: 'Nearby Restaurant',
      address: '456 Restaurant Ave',
      isOpen: true,
      restaurantTypes: [RestaurantType.fixedMenu],
      ownerId: 'owner-123',
      location: const GeoPoint(45.4650, 9.1850),
      imageUrl: null,
    );

    // Create mock far restaurant (only visible with 5km+ radius)
    mockFarRestaurant = Restaurant(
      id: 'restaurant-456',
      name: 'Far Away Restaurant',
      address: '789 Distant Street',
      isOpen: true,
      restaurantTypes: [RestaurantType.onRequest],
      ownerId: 'owner-456',
      location: const GeoPoint(45.4800, 9.2100),
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
    when(() => mockUserProvider.addToFavorites(any(), any(), any())).thenAnswer(
      (invocation) {
        // Simulate adding to favorites
        final restaurantId = invocation.positionalArguments[1] as String;
        if (!mockUser.favourites.contains(restaurantId)) {
          mockUser.favourites.add(restaurantId);
        }
      },
    );
    when(() => mockUserProvider.toggleFavorite(any(), any(), any())).thenAnswer(
      (invocation) {
        // Simulate removing from favorites
        final restaurantId = invocation.positionalArguments[1] as String;
        mockUser.favourites.remove(restaurantId);
      },
    );

    // === RestaurantProvider stubs ===
    when(() => mockRestaurantProvider.isLoading).thenReturn(false);
    when(() => mockRestaurantProvider.restaurant).thenReturn(null);
    when(() => mockRestaurantProvider.errorMessage).thenReturn(null);

    // Return restaurants based on radius
    when(
      () => mockRestaurantProvider.fetchNearbyRestaurants(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radiusInKm: any(named: 'radiusInKm'),
      ),
    ).thenAnswer((invocation) async {
      final radius =
          invocation.namedArguments[const Symbol('radiusInKm')] as double;
      // With radius <= 3, only show nearby restaurant
      // With radius > 3, show both restaurants
      if (radius <= 3) {
        return [mockRestaurant];
      } else {
        return [mockRestaurant, mockFarRestaurant];
      }
    });

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
      child: Consumer<AppRouter>(
        builder: (context, router, child) {
          return MaterialApp(
            theme: lightMode,
            home: const HomeScreen(),
            onGenerateRoute: router.onGenerateRoute,
          );
        },
      ),
    );
  }

  group('Distance Selector and Favorites Flow', () {
    testWidgets('should display distance selector on home screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify distance selector is visible
      expect(find.byType(DistanceSelector), findsOneWidget);
      expect(find.text('Max distance:'), findsOneWidget);
    });

    testWidgets('should display initial distance of 3km', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify initial distance is 3 km
      expect(find.text('3 km'), findsOneWidget);
    });

    testWidgets('should display nearby restaurant within initial radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify nearby restaurant is shown
      expect(find.byType(RestaurantListTile), findsOneWidget);
      expect(find.text('Nearby Restaurant'), findsOneWidget);

      // Far restaurant should not be visible at 3km
      expect(find.text('Far Away Restaurant'), findsNothing);
    });

    testWidgets('should increase distance when tapping up arrow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify initial distance is 3 km
      expect(find.text('3 km'), findsOneWidget);

      // Find and tap the increase button (keyboard_arrow_up)
      final increaseButton = find.byIcon(Icons.keyboard_arrow_up);
      expect(increaseButton, findsOneWidget);
      await tester.tap(increaseButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify distance increased to 4 km
      expect(find.text('4 km'), findsOneWidget);
    });

    testWidgets('should decrease distance when tapping down arrow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify initial distance is 3 km
      expect(find.text('3 km'), findsOneWidget);

      // Find and tap the decrease button
      final decreaseButton = find.byIcon(Icons.keyboard_arrow_down);
      expect(decreaseButton, findsOneWidget);
      await tester.tap(decreaseButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify distance decreased to 2 km
      expect(find.text('2 km'), findsOneWidget);
    });

    testWidgets('should show more restaurants when increasing distance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Initially only 1 restaurant
      expect(find.byType(RestaurantListTile), findsOneWidget);
      expect(find.text('Nearby Restaurant'), findsOneWidget);
      expect(find.text('Far Away Restaurant'), findsNothing);

      // Increase distance twice (3 -> 4 -> 5)
      final increaseButton = find.byIcon(Icons.keyboard_arrow_up);
      await tester.tap(increaseButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(increaseButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Now both restaurants should be visible
      expect(find.byType(RestaurantListTile), findsNWidgets(2));
      expect(find.text('Nearby Restaurant'), findsOneWidget);
      expect(find.text('Far Away Restaurant'), findsOneWidget);
    });

    testWidgets('should display favorite button on restaurant tile', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify FavoriteIconButton is present
      expect(find.byType(FavoriteIconButton), findsOneWidget);

      // Initial state should be empty heart (not favorite)
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should add restaurant to favorites when tapping heart', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the favorite button (empty heart)
      final favoriteButton = find.byIcon(Icons.favorite_border);
      expect(favoriteButton, findsOneWidget);
      await tester.tap(favoriteButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify addToFavorites was called with correct parameters
      verify(
        () => mockUserProvider.addToFavorites(
          any(),
          'restaurant-123',
          'Nearby Restaurant',
        ),
      ).called(1);
    });

    testWidgets('should show filled heart after adding to favorites', (
      WidgetTester tester,
    ) async {
      // Pre-add restaurant to favorites
      mockUser.favourites.add('restaurant-123');

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Should show filled heart (is favorite)
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('complete flow: change distance and add to favorites', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Step 1: Verify initial state
      expect(find.text('3 km'), findsOneWidget);
      expect(find.byType(RestaurantListTile), findsOneWidget);

      // Step 2: Increase distance to find more restaurants
      final increaseButton = find.byIcon(Icons.keyboard_arrow_up);
      await tester.tap(increaseButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(increaseButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Step 3: Verify new distance is 5 km
      expect(find.text('5 km'), findsOneWidget);

      // Step 4: Verify we now see 2 restaurants
      expect(find.byType(RestaurantListTile), findsNWidgets(2));

      // Step 5: Find the far restaurant and add it to favorites
      // The FavoriteIconButtons should be in order, second one is for far restaurant
      final favoriteButtons = find.byType(FavoriteIconButton);
      expect(favoriteButtons, findsNWidgets(2));

      // Tap the second favorite button (for Far Away Restaurant)
      await tester.tap(favoriteButtons.at(1));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify addToFavorites was called for far restaurant
      verify(
        () => mockUserProvider.addToFavorites(
          any(),
          'restaurant-456',
          'Far Away Restaurant',
        ),
      ).called(1);
    });

    testWidgets('should not decrease distance below 1km', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      final decreaseButton = find.byIcon(Icons.keyboard_arrow_down);

      // Decrease from 3 to 1
      await tester.tap(decreaseButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('2 km'), findsOneWidget);

      await tester.tap(decreaseButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('1 km'), findsOneWidget);

      // Try to decrease below 1 - should stay at 1
      await tester.tap(decreaseButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('1 km'), findsOneWidget);
    });
  });
}
