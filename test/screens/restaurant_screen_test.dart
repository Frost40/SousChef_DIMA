import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/restaurant_screen.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';
import 'package:sous_chef/widgets/restaurant_screen/restaurant_info.dart';
import 'package:sous_chef/widgets/favorite_icon_button.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockRestaurantProvider mockRestaurantProvider;
  late MockDishProvider mockDishProvider;
  late MockChatProvider mockChatProvider;
  late MockOrderProvider mockOrderProvider;
  late MockUserProvider mockUserProvider;

  // Sample normal user (not the restaurant owner)
  final testNormalUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
    restaurantId: null,
  );

  // Sample restaurant owner user
  final testOwnerUser = User(
    id: 'owner-user-id',
    email: 'owner@example.com',
    username: 'owneruser',
    name: 'Owner',
    surname: 'User',
    phone: '0987654321',
    restaurantId: 'restaurant-123',
  );

  // Sample restaurant
  final testRestaurant = Restaurant(
    id: 'restaurant-123',
    name: 'Ristorante Test',
    address: 'Via Roma 10, Milano',
    isOpen: true,
    restaurantTypes: [RestaurantType.fixedMenu, RestaurantType.onRequest],
    ownerId: 'owner-user-id',
    location: const GeoPoint(45.4642, 9.1900),
    imageUrl: 'https://example.com/image.jpg',
  );

  // Sample dishes
  final testDishes = <Dish>[
    Dish(
      id: 'dish-1',
      name: 'Pasta Carbonara',
      description: 'Classic Roman pasta',
      price: 12.50,
      course: Course.pastaDish,
      cuisine: Cuisine.italian,
      isAvailable: true,
      isSpecial: false,
    ),
    Dish(
      id: 'dish-2',
      name: 'Tiramisu',
      description: 'Classic Italian dessert',
      price: 6.00,
      course: Course.dessert,
      cuisine: Cuisine.italian,
      isAvailable: true,
      isSpecial: false,
    ),
  ];

  // Sample special dishes (on request)
  final testSpecialDishes = <Dish>[
    Dish(
      id: 'special-dish-1',
      name: 'Chef Special',
      description: 'Daily chef special',
      price: 25.00,
      course: Course.mainDish,
      cuisine: Cuisine.italian,
      isAvailable: true,
      isSpecial: true,
    ),
  ];

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockRestaurantProvider = MockRestaurantProvider();
    mockDishProvider = MockDishProvider();
    mockChatProvider = MockChatProvider();
    mockOrderProvider = MockOrderProvider();
    mockUserProvider = MockUserProvider();

    // Stub default values for AuthProvider (normal user)
    when(() => mockAuthProvider.user).thenReturn(testNormalUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});

    // Stub default values for RestaurantProvider
    when(() => mockRestaurantProvider.restaurant).thenReturn(testRestaurant);
    when(() => mockRestaurantProvider.isLoading).thenReturn(false);
    when(() => mockRestaurantProvider.errorMessage).thenReturn(null);
    when(
      () => mockRestaurantProvider.fetchCompleteRestaurantData(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockRestaurantProvider.updateRestaurantOpenStatus(any(), any()),
    ).thenAnswer((_) async {});

    // Stub default values for DishProvider
    when(() => mockDishProvider.isLoading).thenReturn(false);
    when(() => mockDishProvider.errorMessage).thenReturn(null);
    when(() => mockDishProvider.dishes).thenReturn(testDishes);
    when(() => mockDishProvider.fetchDishes(any())).thenAnswer((_) async {});

    // Stub default values for ChatProvider
    when(() => mockChatProvider.chats).thenReturn([]);
    when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
    when(() => mockChatProvider.isLoading).thenReturn(false);

    // Stub default values for OrderProvider
    when(() => mockOrderProvider.isLoading).thenReturn(false);
    when(() => mockOrderProvider.userOrders).thenReturn([]);

    // Stub default values for UserProvider
    when(() => mockUserProvider.userData).thenReturn(null);
  });

  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(RestaurantType.fixedMenu);
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

  group('RestaurantScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with restaurant name', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Ristorante Test'), findsOneWidget);
      });

      testWidgets('displays RestaurantInfo widget', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(RestaurantInfo), findsOneWidget);
      });

      testWidgets('displays NavigationTabbar for menu tabs', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(NavigationTabbar), findsOneWidget);
      });

      testWidgets('displays Fixed menu and On Request tab labels', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Fixed menu'), findsOneWidget);
        expect(find.text('On Request'), findsAtLeastNWidgets(1));
      });
    });

    // =========================================================================
    // LOADING STATE TESTS
    // =========================================================================

    group('Loading State', () {
      testWidgets('displays loading indicator when restaurant is null', (
        tester,
      ) async {
        when(() => mockRestaurantProvider.restaurant).thenReturn(null);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();

        FlutterError.onError = originalOnError;

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);
      });

      testWidgets('displays loading indicator when dishes are loading', (
        tester,
      ) async {
        when(() => mockDishProvider.isLoading).thenReturn(true);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    // =========================================================================
    // NON-OWNER VIEW TESTS
    // =========================================================================

    group('Non-Owner View', () {
      testWidgets('displays mail icon for non-owner', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.mail_rounded), findsOneWidget);
      });

      testWidgets('displays FavoriteIconButton for non-owner', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(FavoriteIconButton), findsOneWidget);
      });

      testWidgets('does not display add dish button for non-owner', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // CircularButton with add icon should not be visible for non-owner
        expect(find.byIcon(Icons.add), findsNothing);
      });
    });

    // =========================================================================
    // OWNER VIEW TESTS
    // =========================================================================

    group('Owner View', () {
      setUp(() {
        when(() => mockAuthProvider.user).thenReturn(testOwnerUser);
      });

      testWidgets('does not display mail icon for owner', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.mail_rounded), findsNothing);
      });

      testWidgets('does not display FavoriteIconButton for owner', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(FavoriteIconButton), findsNothing);
      });

      testWidgets('displays edit icon next to restaurant name for owner', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.edit), findsOneWidget);
      });

      testWidgets('displays add dish button for owner', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('calls fetchCompleteRestaurantData on init', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(
          () => mockRestaurantProvider.fetchCompleteRestaurantData(
            'restaurant-123',
          ),
        ).called(1);
      });

      testWidgets('calls fetchDishes on init', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(() => mockDishProvider.fetchDishes('restaurant-123')).called(1);
      });
    });

    // =========================================================================
    // BACK BUTTON TESTS
    // =========================================================================

    group('Back Button', () {
      // Use mobile size to ensure SliverAppBar is used (not tablet horizontal with regular AppBar)
      const mobileSize = Size(500, 900);

      testWidgets(
        'SliverAppBar has automaticallyImplyLeading true when showBackButton is true',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const RestaurantScreen(
              restaurantId: 'restaurant-123',
              showBackButton: true,
            ),
            authProvider: mockAuthProvider,
            restaurantProvider: mockRestaurantProvider,
            dishProvider: mockDishProvider,
            chatProvider: mockChatProvider,
            orderProvider: mockOrderProvider, userProvider: mockUserProvider,
            screenSize: mobileSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          // Check SliverAppBar has automaticallyImplyLeading set to true
          final sliverAppBar = tester.widget<SliverAppBar>(
            find.byType(SliverAppBar),
          );
          expect(sliverAppBar.automaticallyImplyLeading, isTrue);
        },
      );

      testWidgets(
        'SliverAppBar has automaticallyImplyLeading false when showBackButton is false',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const RestaurantScreen(
              restaurantId: 'restaurant-123',
              showBackButton: false,
            ),
            authProvider: mockAuthProvider,
            restaurantProvider: mockRestaurantProvider,
            dishProvider: mockDishProvider,
            chatProvider: mockChatProvider,
            orderProvider: mockOrderProvider, userProvider: mockUserProvider,
            screenSize: mobileSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          // Check SliverAppBar has automaticallyImplyLeading set to false
          final sliverAppBar = tester.widget<SliverAppBar>(
            find.byType(SliverAppBar),
          );
          expect(sliverAppBar.automaticallyImplyLeading, isFalse);
        },
      );
    });

    // =========================================================================
    // LAYOUT TESTS - MOBILE
    // =========================================================================

    group('Layout - Mobile (shortestSide < 600)', () {
      // Mobile size: 500x900 (shortestSide = 500)
      const mobileSize = Size(500, 900);

      testWidgets('renders app bar with restaurant name on mobile', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Ristorante Test'), findsOneWidget);
      });

      testWidgets('displays RestaurantInfo on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(RestaurantInfo), findsOneWidget);
      });

      testWidgets('displays NavigationTabbar on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(NavigationTabbar), findsOneWidget);
      });

      testWidgets('uses vertical layout on mobile (no Row)', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Mobile uses CustomScrollView, not a Row layout
        expect(find.byType(CustomScrollView), findsOneWidget);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET VERTICAL
    // =========================================================================

    group('Layout - Tablet Vertical (shortestSide >= 600, portrait)', () {
      // Tablet vertical size: 700x1000 (shortestSide = 700, portrait)
      const tabletVerticalSize = Size(700, 1000);

      testWidgets('renders app bar with restaurant name on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Ristorante Test'), findsOneWidget);
      });

      testWidgets('displays RestaurantInfo on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(RestaurantInfo), findsOneWidget);
      });

      testWidgets('displays NavigationTabbar on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(NavigationTabbar), findsOneWidget);
      });

      testWidgets('uses vertical layout on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Tablet vertical uses the same layout as mobile (CustomScrollView)
        expect(find.byType(CustomScrollView), findsOneWidget);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET HORIZONTAL
    // =========================================================================

    group('Layout - Tablet Horizontal (shortestSide >= 600, landscape)', () {
      // Tablet horizontal size: 1024x700 (shortestSide = 700, landscape)
      const tabletHorizontalSize = Size(1024, 700);

      testWidgets('renders app bar with restaurant name on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Ristorante Test'), findsOneWidget);
      });

      testWidgets('displays RestaurantInfo on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(RestaurantInfo), findsOneWidget);
      });

      testWidgets('displays NavigationTabbar on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(NavigationTabbar), findsOneWidget);
      });

      testWidgets('uses horizontal layout with Row on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Tablet horizontal uses a Row layout with side panel
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('uses regular AppBar on tablet horizontal', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const RestaurantScreen(restaurantId: 'restaurant-123'),
          authProvider: mockAuthProvider,
          restaurantProvider: mockRestaurantProvider,
          dishProvider: mockDishProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider, userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Regular AppBar (not SliverAppBar) is used in horizontal layout
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets(
        'displays mail and favorite icons for non-owner on tablet horizontal',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const RestaurantScreen(restaurantId: 'restaurant-123'),
            authProvider: mockAuthProvider,
            restaurantProvider: mockRestaurantProvider,
            dishProvider: mockDishProvider,
            chatProvider: mockChatProvider,
            orderProvider: mockOrderProvider, userProvider: mockUserProvider,
            screenSize: tabletHorizontalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          expect(find.byIcon(Icons.mail_rounded), findsOneWidget);
          expect(find.byType(FavoriteIconButton), findsOneWidget);
        },
      );
    });
  });
}
