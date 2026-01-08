import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/home_screen.dart';
import 'package:sous_chef/widgets/home_screen/map_viewer.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late MockRestaurantProvider mockRestaurantProvider;
  late MockChatProvider mockChatProvider;

  // Sample user with address
  final testUserWithAddress = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
    savedAddress: 'Via Roma 1, Milano',
    latitude: 45.4642,
    longitude: 9.1900,
  );

  // Sample user without address
  final testUserWithoutAddress = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
  );

  // Sample restaurants
  final testRestaurants = [
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
    mockChatProvider = MockChatProvider();

    // Stub default values for UserProvider
    when(() => mockUserProvider.userData).thenReturn(testUserWithAddress);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.errorMessage).thenReturn(null);

    // Stub default values for RestaurantProvider
    when(() => mockRestaurantProvider.isLoading).thenReturn(false);
    when(() => mockRestaurantProvider.errorMessage).thenReturn(null);
    when(() => mockRestaurantProvider.restaurant).thenReturn(null);
    when(
      () => mockRestaurantProvider.fetchNearbyRestaurants(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radiusInKm: any(named: 'radiusInKm'),
      ),
    ).thenAnswer((_) async => testRestaurants);

    // Stub default values for ChatProvider
    when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
    when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
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
      FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
    }
  }

  group('HomeScreen', () {
    group('Rendering', () {
      testWidgets('renders app bar with title "Sous Chef"', (tester) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        // Restore error handler before expect
        FlutterError.onError = originalOnError;

        expect(find.text('Sous Chef'), findsOneWidget);
      });

      testWidgets('renders shopping cart icon in app bar', (tester) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        // Restore error handler before expect
        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      });

      testWidgets('renders chat/mail icon in app bar', (tester) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        // Restore error handler before expect
        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.mail_rounded), findsOneWidget);
      });
    });

    group('User without address', () {
      testWidgets('shows "No address set" message when user has no address', (
        tester,
      ) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        when(
          () => mockUserProvider.userData,
        ).thenReturn(testUserWithoutAddress);

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        // Wait for the widget to settle
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Restore error handler before expect
        FlutterError.onError = originalOnError;

        expect(find.text('No address set'), findsOneWidget);
        expect(
          find.text('Please set your address to find restaurants'),
          findsOneWidget,
        );
      });

      testWidgets('shows location_off icon when user has no address', (
        tester,
      ) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        when(
          () => mockUserProvider.userData,
        ).thenReturn(testUserWithoutAddress);

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Restore error handler before expect
        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.location_off), findsOneWidget);
      });
    });

    group('User with address but no restaurants found', () {
      testWidgets('shows "No restaurants found" when list is empty', (
        tester,
      ) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        when(
          () => mockRestaurantProvider.fetchNearbyRestaurants(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusInKm: any(named: 'radiusInKm'),
          ),
        ).thenAnswer((_) async => []);

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Restore error handler before expect
        FlutterError.onError = originalOnError;

        expect(find.text('No restaurants found'), findsOneWidget);
        expect(find.text('Try increasing the distance'), findsOneWidget);
      });

      testWidgets('shows restaurant_menu icon when no restaurants found', (
        tester,
      ) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        when(
          () => mockRestaurantProvider.fetchNearbyRestaurants(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusInKm: any(named: 'radiusInKm'),
          ),
        ).thenAnswer((_) async => []);

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Restore error handler before expect
        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator when restaurants are loading', (
        tester,
      ) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // Use Completer to control when the Future completes
        final completer = Completer<List<Restaurant>>();
        when(
          () => mockRestaurantProvider.fetchNearbyRestaurants(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusInKm: any(named: 'radiusInKm'),
          ),
        ).thenAnswer((_) => completer.future);

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        // The initial state shows CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the Future to allow test to finish cleanly
        completer.complete(testRestaurants);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Restore error handler after all pumps
        FlutterError.onError = originalOnError;
      });
    });

    group('Distance Selector', () {
      testWidgets('distance selector is rendered', (tester) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Restore error handler before expect
        FlutterError.onError = originalOnError;

        // The DistanceSelector widget should be present
        // Check for the km text that is typically displayed
        expect(find.textContaining('km'), findsWidgets);
      });
    });

    group('Provider Interaction', () {
      testWidgets('calls fetchNearbyRestaurants when user has address', (
        tester,
      ) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Restore error handler before verify
        FlutterError.onError = originalOnError;

        verify(
          () => mockRestaurantProvider.fetchNearbyRestaurants(
            latitude: testUserWithAddress.latitude!,
            longitude: testUserWithAddress.longitude!,
            radiusInKm: any(named: 'radiusInKm'),
          ),
        ).called(greaterThan(0));
      });

      testWidgets('reads userData from UserProvider', (tester) async {
        // Ignore overflow errors for this test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.binding.setSurfaceSize(const Size(1080, 1920));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
        );

        await tester.pump();

        // Restore error handler before verify
        FlutterError.onError = originalOnError;

        verify(() => mockUserProvider.userData).called(greaterThan(0));
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
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Sous Chef'), findsOneWidget);
      });

      testWidgets('renders NavigationTabbar on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Mobile layout shows NavigationTabbar for List/Map toggle
        expect(find.byType(NavigationTabbar), findsOneWidget);
      });

      testWidgets('shows MapViewer when Map tab is selected on mobile', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Find and tap on Map tab (index 1)
        final mapTabFinder = find.text('Map');
        if (mapTabFinder.evaluate().isNotEmpty) {
          await tester.tap(mapTabFinder);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        }

        FlutterError.onError = originalOnError;

        // Now MapViewer should be visible
        expect(find.byType(MapViewer), findsOneWidget);
      });

      testWidgets('shows List view by default on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // List view is default, MapViewer should not be visible
        expect(find.byType(MapViewer), findsNothing);
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
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Sous Chef'), findsOneWidget);
      });

      testWidgets('renders NavigationTabbar on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Tablet vertical layout also shows NavigationTabbar for List/Map toggle
        expect(find.byType(NavigationTabbar), findsOneWidget);
      });

      testWidgets(
        'shows MapViewer when Map tab is selected on tablet vertical',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const HomeScreen(),
            userProvider: mockUserProvider,
            restaurantProvider: mockRestaurantProvider,
            chatProvider: mockChatProvider,
            screenSize: tabletVerticalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          // Tap on Map tab
          final mapTabFinder = find.text('Map');
          if (mapTabFinder.evaluate().isNotEmpty) {
            await tester.tap(mapTabFinder);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 500));
          }

          FlutterError.onError = originalOnError;

          // MapViewer should be visible
          expect(find.byType(MapViewer), findsOneWidget);
        },
      );
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
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Sous Chef'), findsOneWidget);
      });

      testWidgets(
        'does NOT render NavigationTabbar on tablet horizontal (side-by-side layout)',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const HomeScreen(),
            userProvider: mockUserProvider,
            restaurantProvider: mockRestaurantProvider,
            chatProvider: mockChatProvider,
            screenSize: tabletHorizontalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          // Tablet horizontal uses side-by-side layout (list + map), no NavigationTabbar
          expect(find.byType(NavigationTabbar), findsNothing);
        },
      );

      testWidgets(
        'shows MapViewer always visible on tablet horizontal (side-by-side)',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const HomeScreen(),
            userProvider: mockUserProvider,
            restaurantProvider: mockRestaurantProvider,
            chatProvider: mockChatProvider,
            screenSize: tabletHorizontalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          // In tablet horizontal layout, MapViewer is always visible (side-by-side)
          expect(find.byType(MapViewer), findsOneWidget);
        },
      );

      testWidgets('renders shopping cart icon on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      });
    });

    // =========================================================================
    // MAP VIEW TESTS
    // =========================================================================

    group('Map View', () {
      // Use tablet horizontal for map tests (map always visible)
      const tabletHorizontalSize = Size(1024, 700);
      // Use tablet vertical for toggle tests (has NavigationTabbar)
      const tabletVerticalSize = Size(700, 1000);

      testWidgets('MapViewer receives correct coordinates from user', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Find MapViewer and verify it exists
        final mapViewerFinder = find.byType(MapViewer);
        expect(mapViewerFinder, findsOneWidget);

        // Verify MapViewer has correct coordinates
        final mapViewer = tester.widget<MapViewer>(mapViewerFinder);
        expect(mapViewer.latitude, testUserWithAddress.latitude);
        expect(mapViewer.longitude, testUserWithAddress.longitude);
      });

      testWidgets('can toggle between List and Map view', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const HomeScreen(),
          userProvider: mockUserProvider,
          restaurantProvider: mockRestaurantProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Initially in List view - MapViewer should not be visible
        expect(find.byType(MapViewer), findsNothing);

        // Switch to Map view by tapping Map tab
        final mapTabFinder = find.text('Map');
        if (mapTabFinder.evaluate().isNotEmpty) {
          await tester.tap(mapTabFinder);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          // MapViewer should be visible
          expect(find.byType(MapViewer), findsOneWidget);

          // Switch back to List view
          final listTabFinder = find.text('List');
          if (listTabFinder.evaluate().isNotEmpty) {
            await tester.tap(listTabFinder);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 500));
          }
        }

        FlutterError.onError = originalOnError;

        // MapViewer should not be visible in List view
        expect(find.byType(MapViewer), findsNothing);
      });
    });
  });
}
