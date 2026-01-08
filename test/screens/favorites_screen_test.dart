import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/favorites_screen.dart';
import 'package:sous_chef/widgets/restaurant_list_tile.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late MockRestaurantProvider mockRestaurantProvider;

  // Sample user with favorites
  final testUserWithFavorites = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
    favourites: ['restaurant-1', 'restaurant-2'],
  );

  // Sample user without favorites
  final testUserWithoutFavorites = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
    favourites: [],
  );

  // Sample favorite restaurants
  final testFavoriteRestaurants = [
    Restaurant(
      id: 'restaurant-1',
      name: 'Ristorante Italiano',
      address: 'Via Roma 10, Milano',
      isOpen: true,
      restaurantTypes: [RestaurantType.fixedMenu],
      ownerId: 'owner-1',
      location: const GeoPoint(45.4642, 9.1900),
      imageUrl: null,
    ),
    Restaurant(
      id: 'restaurant-2',
      name: 'Pizzeria Napoli',
      address: 'Via Napoli 5, Milano',
      isOpen: false,
      restaurantTypes: [RestaurantType.onRequest],
      ownerId: 'owner-2',
      location: const GeoPoint(45.4650, 9.1910),
      imageUrl: null,
    ),
  ];

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockRestaurantProvider = MockRestaurantProvider();

    // Stub default values for UserProvider
    when(() => mockUserProvider.userData).thenReturn(testUserWithFavorites);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.errorMessage).thenReturn(null);
    when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});
    when(() => mockUserProvider.syncPendingChanges()).thenAnswer((_) async {});

    // Stub default values for RestaurantProvider
    when(() => mockRestaurantProvider.isLoading).thenReturn(false);
    when(() => mockRestaurantProvider.errorMessage).thenReturn(null);
    when(
      () => mockRestaurantProvider.fetchFavoriteRestaurantsByIds(any()),
    ).thenAnswer((_) async => testFavoriteRestaurants);
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

  group('FavoritesScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with title "Favorites"', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Favorites'), findsOneWidget);
      });

      testWidgets('app bar is centered', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
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
      testWidgets('shows loading indicator when isLoading is true', (
        tester,
      ) async {
        when(() => mockRestaurantProvider.isLoading).thenReturn(true);

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('does not show loading indicator when isLoading is false', (
        tester,
      ) async {
        when(() => mockRestaurantProvider.isLoading).thenReturn(false);

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    // =========================================================================
    // EMPTY STATE TESTS
    // =========================================================================

    group('Empty State', () {
      testWidgets('shows "No favorite yet!" when user has no favorites', (
        tester,
      ) async {
        when(
          () => mockUserProvider.userData,
        ).thenReturn(testUserWithoutFavorites);
        when(
          () => mockRestaurantProvider.fetchFavoriteRestaurantsByIds(any()),
        ).thenAnswer((_) async => []);

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('No favorite yet!'), findsOneWidget);
      });
    });

    // =========================================================================
    // ERROR STATE TESTS
    // =========================================================================

    group('Error State', () {
      testWidgets('shows error message when restaurantProvider has error', (
        tester,
      ) async {
        when(
          () => mockRestaurantProvider.errorMessage,
        ).thenReturn('Network error');

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.textContaining('Error:'), findsOneWidget);
        expect(find.textContaining('Network error'), findsOneWidget);
      });
    });

    // =========================================================================
    // FAVORITES LIST TESTS
    // =========================================================================

    group('Favorites List', () {
      testWidgets('displays RestaurantListTile for each favorite', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Should show RestaurantListTile widgets
        expect(find.byType(RestaurantListTile), findsWidgets);
      });

      testWidgets('displays restaurant names from favorites', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Ristorante Italiano'), findsOneWidget);
        expect(find.text('Pizzeria Napoli'), findsOneWidget);
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('calls fetchUserData on init', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(() => mockUserProvider.fetchUserData()).called(greaterThan(0));
      });

      testWidgets('calls fetchFavoriteRestaurantsByIds with user favorites', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        verify(
          () => mockRestaurantProvider.fetchFavoriteRestaurantsByIds(
            testUserWithFavorites.favourites,
          ),
        ).called(greaterThan(0));
      });
    });

    // =========================================================================
    // LAYOUT TESTS - Mobile, Tablet Vertical, Tablet Horizontal
    // =========================================================================
    // Layout detection (same as HomeScreen):
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
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Favorites'), findsOneWidget);
      });

      testWidgets('renders ListView on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('displays restaurant list tiles on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(RestaurantListTile), findsWidgets);
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
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Favorites'), findsOneWidget);
      });

      testWidgets('renders ListView on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('displays restaurant list tiles on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(RestaurantListTile), findsWidgets);
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
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Favorites'), findsOneWidget);
      });

      testWidgets(
        'renders centered ListView with limited width on tablet horizontal',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const FavoritesScreen(),
            userProvider: mockUserProvider,
            restaurantProvider: mockRestaurantProvider,
            screenSize: tabletHorizontalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          // Should have ListView wrapped in Align and SizedBox
          expect(find.byType(ListView), findsOneWidget);
          expect(find.byType(Align), findsWidgets);
        },
      );

      testWidgets('displays restaurant list tiles on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byType(RestaurantListTile), findsWidgets);
      });

      testWidgets('tablet horizontal layout uses SizedBox with width 900', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const FavoritesScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Find SizedBox with width 900 for tablet horizontal
        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 900,
        );
        expect(sizedBoxFinder, findsOneWidget);
      });
    });
  });
}
