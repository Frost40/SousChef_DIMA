import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/widgets/restaurant_list_tile.dart';

import '../helpers/mock_providers.dart';

void main() {
  group('RestaurantListTile', () {
    late MockUserProvider mockUserProvider;
    late Restaurant testRestaurant;
    late User testUser;

    setUpAll(() {
      registerFallbackValues();
    });

    setUp(() {
      mockUserProvider = MockUserProvider();

      testUser = User(
        id: 'user-1',
        email: 'test@test.com',
        username: 'testuser',
        name: 'Test',
        surname: 'User',
        phone: '123456789',
        favourites: [],
      );

      when(() => mockUserProvider.userData).thenReturn(testUser);

      testRestaurant = Restaurant(
        id: 'test-id',
        name: 'Test Restaurant',
        address: '123 Test St',
        isOpen: true,
        restaurantTypes: [],
        ownerId: 'owner-1',
        location: const GeoPoint(45.0, 9.0),
        imageUrl: null,
      );
    });

    Future<void> pumpRestaurantListTile(
      WidgetTester tester, {
      required Restaurant restaurant,
      MockNavigatorObserver? navigatorObserver,
    }) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: MaterialApp(
            home: Scaffold(body: RestaurantListTile(restaurant: restaurant)),
            navigatorObservers: [
              if (navigatorObserver != null) navigatorObserver,
            ],
            routes: {
              '/restaurant':
                  (context) => const Scaffold(body: Text('Restaurant')),
            },
          ),
        ),
      );
    }

    testWidgets('renders correctly', (tester) async {
      await pumpRestaurantListTile(tester, restaurant: testRestaurant);

      expect(find.byType(RestaurantListTile), findsOneWidget);
    });

    testWidgets('displays restaurant name', (tester) async {
      await pumpRestaurantListTile(tester, restaurant: testRestaurant);

      expect(find.text('Test Restaurant'), findsOneWidget);
    });

    testWidgets('shows Open status when restaurant is open', (tester) async {
      await pumpRestaurantListTile(tester, restaurant: testRestaurant);

      expect(find.text('Open'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows Closed status when restaurant is closed', (
      tester,
    ) async {
      final closedRestaurant = Restaurant(
        id: 'test-id',
        name: 'Closed Restaurant',
        address: '123 Test St',
        isOpen: false,
        restaurantTypes: [],
        ownerId: 'owner-1',
        location: const GeoPoint(45.0, 9.0),
        imageUrl: null,
      );

      await pumpRestaurantListTile(tester, restaurant: closedRestaurant);

      expect(find.text('Closed'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('contains Card widget', (tester) async {
      await pumpRestaurantListTile(tester, restaurant: testRestaurant);

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('contains InkWell for tap', (tester) async {
      await pumpRestaurantListTile(tester, restaurant: testRestaurant);

      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('shows placeholder image when imageUrl is null', (
      tester,
    ) async {
      await pumpRestaurantListTile(tester, restaurant: testRestaurant);

      // Should show restaurant icon as placeholder
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('navigates to restaurant screen on tap', (tester) async {
      final mockObserver = MockNavigatorObserver();

      await pumpRestaurantListTile(
        tester,
        restaurant: testRestaurant,
        navigatorObserver: mockObserver,
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      verify(
        () => mockObserver.didPush(any(), any()),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
