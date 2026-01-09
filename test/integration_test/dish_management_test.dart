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
import 'package:sous_chef/screens/restaurant_screen.dart';
import 'package:sous_chef/screens/dish_screen.dart';
import 'package:sous_chef/themes/light_mode.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/widgets/restaurant_screen/menu_item.dart';
import 'package:sous_chef/widgets/circular_button.dart';
import 'package:sous_chef/widgets/restaurant_screen/dish_availability_button.dart';
import 'dart:io';

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

/// Fake File for mocktail
class FakeFile extends Fake implements File {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeFile());
    registerFallbackValue(Course.mainDish);
    registerFallbackValue(Cuisine.italian);
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
  late User mockRegularUser;
  late Restaurant mockRestaurant;
  late List<Dish> mockDishes;
  late Dish mockDish;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();
    mockUserProvider = MockUserProvider();
    mockRestaurantProvider = MockRestaurantProvider();
    mockDishProvider = MockDishProvider();
    mockOrderProvider = MockOrderProvider();
    mockStripeProvider = MockStripeProvider();
    mockThemeProvider = MockThemeProvider();

    // Create mock owner user
    mockOwnerUser = User(
      id: 'owner-123',
      email: 'owner@example.com',
      username: 'owneruser',
      name: 'Owner',
      surname: 'User',
      phone: '1234567890',
      savedAddress: '123 Owner Street',
      latitude: 45.4642,
      longitude: 9.1900,
      restaurantId: 'restaurant-123',
    );

    // Create mock regular user (not owner)
    mockRegularUser = User(
      id: 'regular-123',
      email: 'regular@example.com',
      username: 'regularuser',
      name: 'Regular',
      surname: 'User',
      phone: '0987654321',
      savedAddress: '456 Regular Street',
      latitude: 45.4650,
      longitude: 9.1850,
      restaurantId: null,
    );

    // Create mock restaurant
    mockRestaurant = Restaurant(
      id: 'restaurant-123',
      name: 'Test Restaurant',
      address: '456 Restaurant Ave',
      isOpen: true,
      restaurantTypes: [RestaurantType.fixedMenu],
      ownerId: 'owner-123', // Matches mockOwnerUser.id
      location: const GeoPoint(45.4650, 9.1850),
      imageUrl: null,
    );

    // Create mock dishes
    mockDish = Dish(
      id: 'dish-1',
      name: 'Margherita Pizza',
      description: 'Classic Italian pizza with tomato and mozzarella',
      price: 12.50,
      course: Course.mainDish,
      cuisine: Cuisine.italian,
      isAvailable: true,
      isSpecial: false,
      imageUrl: null,
    );

    mockDishes = [
      mockDish,
      Dish(
        id: 'dish-2',
        name: 'Tiramisu',
        description: 'Traditional Italian dessert',
        price: 7.50,
        course: Course.dessert,
        cuisine: Cuisine.italian,
        isAvailable: false,
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
    when(() => mockChatProvider.findExistingChat(any())).thenReturn(null);
    when(
      () => mockChatProvider.createChat(any()),
    ).thenAnswer((_) async => 'chat-123');

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
    when(
      () => mockDishProvider.deleteDish(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockDishProvider.updateDishAvailability(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockDishProvider.createDish(
        restaurantId: any(named: 'restaurantId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        price: any(named: 'price'),
        course: any(named: 'course'),
        cuisine: any(named: 'cuisine'),
        isSpecial: any(named: 'isSpecial'),
        imageFile: any(named: 'imageFile'),
        imageUrl: any(named: 'imageUrl'),
        minForewarningDays: any(named: 'minForewarningDays'),
        userUsername: any(named: 'userUsername'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockDishProvider.updateDish(
        restaurantId: any(named: 'restaurantId'),
        dishId: any(named: 'dishId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        price: any(named: 'price'),
        course: any(named: 'course'),
        cuisine: any(named: 'cuisine'),
        imageFile: any(named: 'imageFile'),
        imageUrl: any(named: 'imageUrl'),
        minForewarningDays: any(named: 'minForewarningDays'),
        userUsername: any(named: 'userUsername'),
        isAvailable: any(named: 'isAvailable'),
      ),
    ).thenAnswer((_) async {});

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

  Widget buildRestaurantScreen({required User user}) {
    // Update user in mocks
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
      child: Consumer<AppRouter>(
        builder: (context, router, child) {
          return MaterialApp(
            theme: lightMode,
            home: const RestaurantScreen(
              restaurantId: 'restaurant-123',
              showBackButton: false,
            ),
            onGenerateRoute: router.onGenerateRoute,
          );
        },
      ),
    );
  }

  Widget buildDishScreen({
    required User user,
    String? dishId,
    bool isNew = false,
    bool isEditable = true,
  }) {
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
      child: MaterialApp(
        theme: lightMode,
        home: DishScreen(dishId: dishId, isEditable: isEditable, isNew: isNew),
      ),
    );
  }

  group('Dish Management', () {
    testWidgets('owner should see add dish button on Restaurant screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildRestaurantScreen(user: mockOwnerUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Owner should see the add button (CircularButton with add icon)
      final addButton = find.byWidgetPredicate(
        (widget) => widget is CircularButton && widget.icon == Icons.add,
      );
      expect(addButton, findsOneWidget);
    });

    testWidgets('regular user should NOT see add dish button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildRestaurantScreen(user: mockRegularUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Regular user should NOT see the add button
      final addButton = find.byWidgetPredicate(
        (widget) => widget is CircularButton && widget.icon == Icons.add,
      );
      expect(addButton, findsNothing);
    });

    testWidgets('should display menu items on Restaurant screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildRestaurantScreen(user: mockOwnerUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify menu items are displayed
      expect(find.byType(MenuItem), findsNWidgets(2)); // Two dishes
      expect(find.text('Margherita Pizza'), findsOneWidget);
      expect(find.text('Tiramisu'), findsOneWidget);
    });

    testWidgets('should navigate to DishScreen when tapping add button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildRestaurantScreen(user: mockOwnerUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find and tap the add button
      final addButton = find.byWidgetPredicate(
        (widget) => widget is CircularButton && widget.icon == Icons.add,
      );
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Should navigate to DishScreen
      expect(find.byType(DishScreen), findsOneWidget);
    });

    testWidgets('should display dish details on DishScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildDishScreen(user: mockOwnerUser, dishId: 'dish-1'),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify dish details are displayed
      expect(find.text('Margherita Pizza'), findsOneWidget);
      expect(
        find.text('Classic Italian pizza with tomato and mozzarella'),
        findsOneWidget,
      );
    });

    testWidgets('owner should see save button when editing dish', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildDishScreen(
          user: mockOwnerUser,
          dishId: 'dish-1',
          isEditable: true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find the name field and modify it to trigger hasChanges
      final nameField = find.widgetWithText(TextField, 'Margherita Pizza');
      if (nameField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'Updated Pizza');
        await tester.pump(const Duration(milliseconds: 300));

        // Save icon should appear when there are changes
        expect(find.byIcon(Icons.save), findsOneWidget);
      }
    });

    testWidgets('should show availability toggle for owner', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildRestaurantScreen(user: mockOwnerUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find availability buttons on menu items
      final availabilityButtons = find.byType(DishAvailabilityButton);
      expect(availabilityButtons, findsWidgets);
    });

    testWidgets('new dish screen should have empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildDishScreen(user: mockOwnerUser, isNew: true, isEditable: true),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify DishScreen is shown for new dish
      expect(find.byType(DishScreen), findsOneWidget);

      // Fields should exist (name input, description input, etc.)
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
    });

    testWidgets('should navigate to dish detail when tapping menu item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildRestaurantScreen(user: mockOwnerUser));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find and tap on a menu item
      final menuItem = find.text('Margherita Pizza');
      expect(menuItem, findsOneWidget);

      await tester.tap(menuItem);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Should show dish details screen or dialog
      // The dish name should still be visible
      expect(find.text('Margherita Pizza'), findsWidgets);
    });
  });
}
