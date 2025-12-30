import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/restaurant.dart';

// Mock class for DocumentSnapshot
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('Restaurant Model Tests', () {
    group('Constructor', () {
      test('should create Restaurant with all required fields', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(45.4642, 9.1900),
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(restaurant.id, 'rest123');
        expect(restaurant.name, 'Test Restaurant');
        expect(restaurant.address, '123 Main St');
        expect(restaurant.isOpen, true);
        expect(restaurant.restaurantTypes, [RestaurantType.fixedMenu]);
        expect(restaurant.ownerId, 'owner123');
        expect(restaurant.location.latitude, 45.4642);
        expect(restaurant.location.longitude, 9.1900);
        expect(restaurant.imageUrl, 'https://example.com/image.jpg');
      });

      test('should create Restaurant with isOpen false', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Closed Restaurant',
          address: '123 Main St',
          isOpen: false,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.isOpen, false);
      });

      test('should create Restaurant with empty restaurantTypes', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.restaurantTypes, isEmpty);
      });

      test('should create Restaurant with both restaurant types', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu, RestaurantType.onRequest],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.restaurantTypes.length, 2);
        expect(restaurant.restaurantTypes, contains(RestaurantType.fixedMenu));
        expect(restaurant.restaurantTypes, contains(RestaurantType.onRequest));
      });

      test('should create Restaurant with null imageUrl', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.imageUrl, isNull);
      });

      test('should handle empty string values', () {
        final restaurant = Restaurant(
          id: '',
          name: '',
          address: '',
          isOpen: false,
          restaurantTypes: [],
          ownerId: '',
          location: const GeoPoint(0, 0),
          imageUrl: '',
        );

        expect(restaurant.id, '');
        expect(restaurant.name, '');
        expect(restaurant.address, '');
        expect(restaurant.ownerId, '');
        expect(restaurant.imageUrl, '');
      });

      test('should handle special characters in name and address', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: "Giuseppe's Trattoria & Café",
          address: '123 Main St, Apt #5, 東京',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.name, "Giuseppe's Trattoria & Café");
        expect(restaurant.address, '123 Main St, Apt #5, 東京');
      });

      test('should handle negative coordinates', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Sydney Restaurant',
          address: 'Sydney, Australia',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(-33.8688, 151.2093),
          imageUrl: null,
        );

        expect(restaurant.location.latitude, -33.8688);
        expect(restaurant.location.longitude, 151.2093);
      });
    });

    group('fromFirestore', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should create Restaurant from Firestore document with all fields', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'restaurant_types': ['fixed_menu', 'on_request'],
          'owner_id': 'owner123',
          'location': const GeoPoint(45.4642, 9.1900),
          'image_url': 'https://example.com/image.jpg',
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.id, 'rest123');
        expect(restaurant.name, 'Test Restaurant');
        expect(restaurant.address, '123 Main St');
        expect(restaurant.isOpen, true);
        expect(restaurant.restaurantTypes.length, 2);
        expect(restaurant.restaurantTypes, contains(RestaurantType.fixedMenu));
        expect(restaurant.restaurantTypes, contains(RestaurantType.onRequest));
        expect(restaurant.ownerId, 'owner123');
        expect(restaurant.location.latitude, 45.4642);
        expect(restaurant.location.longitude, 9.1900);
        expect(restaurant.imageUrl, 'https://example.com/image.jpg');
      });

      test('should handle missing name with empty string default', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.name, '');
      });

      test('should handle null name with empty string default', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': null,
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.name, '');
      });

      test('should handle missing address with empty string default', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.address, '');
      });

      test('should handle missing is_open with false default', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.isOpen, false);
      });

      test('should handle null is_open with false default', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': null,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.isOpen, false);
      });

      test('should handle missing owner_id with empty string default', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'location': const GeoPoint(0, 0),
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.ownerId, '');
      });

      test('should handle missing location with default GeoPoint(0, 0)', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.location.latitude, 0);
        expect(restaurant.location.longitude, 0);
      });

      test('should handle null location with default GeoPoint(0, 0)', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': null,
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.location.latitude, 0);
        expect(restaurant.location.longitude, 0);
      });

      test('should handle missing image_url with empty string default', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.imageUrl, '');
      });

      test('should handle null image_url with empty string default', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
          'image_url': null,
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.imageUrl, '');
      });

      test('should handle null restaurant_types with empty list', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
          'restaurant_types': null,
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.restaurantTypes, isEmpty);
      });

      test('should handle missing restaurant_types with empty list', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.restaurantTypes, isEmpty);
      });

      test('should handle empty restaurant_types array', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
          'restaurant_types': [],
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.restaurantTypes, isEmpty);
      });

      test('should parse fixed_menu type correctly', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
          'restaurant_types': ['fixed_menu'],
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.restaurantTypes.length, 1);
        expect(restaurant.restaurantTypes.first, RestaurantType.fixedMenu);
      });

      test('should parse on_request type correctly', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
          'restaurant_types': ['on_request'],
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.restaurantTypes.length, 1);
        expect(restaurant.restaurantTypes.first, RestaurantType.onRequest);
      });

      test('should ignore unknown restaurant type strings', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
          'restaurant_types': ['unknown_type', 'fixed_menu'],
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.restaurantTypes.length, 1);
        expect(restaurant.restaurantTypes.first, RestaurantType.fixedMenu);
      });

      test('should handle empty Firestore document data', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({});

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.id, 'rest123');
        expect(restaurant.name, '');
        expect(restaurant.address, '');
        expect(restaurant.isOpen, false);
        expect(restaurant.restaurantTypes, isEmpty);
        expect(restaurant.ownerId, '');
        expect(restaurant.location.latitude, 0);
        expect(restaurant.location.longitude, 0);
        expect(restaurant.imageUrl, '');
      });

      test('should handle Firestore document with extra fields', () {
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(0, 0),
          'extra_field': 'should be ignored',
          'another_field': 123,
        });

        final restaurant = Restaurant.fromFirestore(mockDoc);

        expect(restaurant.id, 'rest123');
        expect(restaurant.name, 'Test Restaurant');
      });
    });

    group('toFirestore', () {
      test('should convert Restaurant to Firestore map with all fields', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu, RestaurantType.onRequest],
          ownerId: 'owner123',
          location: const GeoPoint(45.4642, 9.1900),
          imageUrl: 'https://example.com/image.jpg',
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap['name'], 'Test Restaurant');
        expect(firestoreMap['address'], '123 Main St');
        expect(firestoreMap['is_open'], true);
        expect(firestoreMap['restaurant_types'], ['fixed_menu', 'on_request']);
        expect(firestoreMap['owner_id'], 'owner123');
        expect(firestoreMap['location'], isA<GeoPoint>());
        expect((firestoreMap['location'] as GeoPoint).latitude, 45.4642);
        expect((firestoreMap['location'] as GeoPoint).longitude, 9.1900);
      });

      test('should not include id in Firestore map', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap.containsKey('id'), isFalse);
      });

      test('should not include imageUrl in Firestore map', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: 'https://example.com/image.jpg',
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap.containsKey('imageUrl'), isFalse);
        expect(firestoreMap.containsKey('image_url'), isFalse);
      });

      test('should return map with exactly 6 keys', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap.length, 6);
        expect(firestoreMap.containsKey('name'), isTrue);
        expect(firestoreMap.containsKey('address'), isTrue);
        expect(firestoreMap.containsKey('is_open'), isTrue);
        expect(firestoreMap.containsKey('restaurant_types'), isTrue);
        expect(firestoreMap.containsKey('owner_id'), isTrue);
        expect(firestoreMap.containsKey('location'), isTrue);
      });

      test('should convert fixedMenu type to fixed_menu string', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap['restaurant_types'], ['fixed_menu']);
      });

      test('should convert onRequest type to on_request string', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.onRequest],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap['restaurant_types'], ['on_request']);
      });

      test('should handle empty restaurantTypes', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap['restaurant_types'], isEmpty);
      });

      test('should handle isOpen false', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: false,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap['is_open'], false);
      });

      test('should handle empty strings', () {
        final restaurant = Restaurant(
          id: '',
          name: '',
          address: '',
          isOpen: false,
          restaurantTypes: [],
          ownerId: '',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final firestoreMap = restaurant.toFirestore();

        expect(firestoreMap['name'], '');
        expect(firestoreMap['address'], '');
        expect(firestoreMap['owner_id'], '');
      });
    });

    group('hasRestaurantType', () {
      test('should return true when restaurant has fixedMenu type', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.hasRestaurantType(RestaurantType.fixedMenu), isTrue);
      });

      test('should return true when restaurant has onRequest type', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.onRequest],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.hasRestaurantType(RestaurantType.onRequest), isTrue);
      });

      test('should return false when restaurant does not have the type', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.hasRestaurantType(RestaurantType.onRequest), isFalse);
      });

      test('should return false when restaurantTypes is empty', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.hasRestaurantType(RestaurantType.fixedMenu), isFalse);
        expect(restaurant.hasRestaurantType(RestaurantType.onRequest), isFalse);
      });

      test('should return true for both types when restaurant has both', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu, RestaurantType.onRequest],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.hasRestaurantType(RestaurantType.fixedMenu), isTrue);
        expect(restaurant.hasRestaurantType(RestaurantType.onRequest), isTrue);
      });
    });

    group('toggleRestaurantType', () {
      test('should add type when restaurant has no types', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final toggled = restaurant.toggleRestaurantType(RestaurantType.fixedMenu);

        expect(toggled.restaurantTypes.length, 1);
        expect(toggled.restaurantTypes, contains(RestaurantType.fixedMenu));
      });

      test('should add second type when restaurant has one type', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final toggled = restaurant.toggleRestaurantType(RestaurantType.onRequest);

        expect(toggled.restaurantTypes.length, 2);
        expect(toggled.restaurantTypes, contains(RestaurantType.fixedMenu));
        expect(toggled.restaurantTypes, contains(RestaurantType.onRequest));
      });

      test('should not add third type when restaurant already has two types', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu, RestaurantType.onRequest],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        // Try to add fixedMenu again (it will be removed since it exists)
        final toggled = restaurant.toggleRestaurantType(RestaurantType.fixedMenu);

        // Should remove the type since it already exists
        expect(toggled.restaurantTypes.length, 1);
        expect(toggled.restaurantTypes, contains(RestaurantType.onRequest));
      });

      test('should remove type when it already exists', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final toggled = restaurant.toggleRestaurantType(RestaurantType.fixedMenu);

        expect(toggled.restaurantTypes, isEmpty);
      });

      test('should remove onRequest type when it already exists', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.onRequest],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final toggled = restaurant.toggleRestaurantType(RestaurantType.onRequest);

        expect(toggled.restaurantTypes, isEmpty);
      });

      test('should preserve other fields when toggling', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(45.0, 9.0),
          imageUrl: 'https://example.com/image.jpg',
        );

        final toggled = restaurant.toggleRestaurantType(RestaurantType.fixedMenu);

        expect(toggled.id, restaurant.id);
        expect(toggled.name, restaurant.name);
        expect(toggled.address, restaurant.address);
        expect(toggled.isOpen, restaurant.isOpen);
        expect(toggled.ownerId, restaurant.ownerId);
        expect(toggled.location, restaurant.location);
        expect(toggled.imageUrl, restaurant.imageUrl);
      });

      test('should not affect original restaurant when toggling', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final toggled = restaurant.toggleRestaurantType(RestaurantType.onRequest);

        expect(restaurant.restaurantTypes.length, 1);
        expect(toggled.restaurantTypes.length, 2);
      });

      test('should handle toggle sequence correctly', () {
        var restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        // Add fixedMenu
        restaurant = restaurant.toggleRestaurantType(RestaurantType.fixedMenu);
        expect(restaurant.restaurantTypes, [RestaurantType.fixedMenu]);

        // Add onRequest
        restaurant = restaurant.toggleRestaurantType(RestaurantType.onRequest);
        expect(restaurant.restaurantTypes.length, 2);

        // Remove fixedMenu
        restaurant = restaurant.toggleRestaurantType(RestaurantType.fixedMenu);
        expect(restaurant.restaurantTypes, [RestaurantType.onRequest]);

        // Remove onRequest
        restaurant = restaurant.toggleRestaurantType(RestaurantType.onRequest);
        expect(restaurant.restaurantTypes, isEmpty);
      });
    });

    group('copyWith', () {
      test('should create copy with no changes when no parameters provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(45.0, 9.0),
          imageUrl: 'https://example.com/image.jpg',
        );

        final copy = restaurant.copyWith();

        expect(copy.id, restaurant.id);
        expect(copy.name, restaurant.name);
        expect(copy.address, restaurant.address);
        expect(copy.isOpen, restaurant.isOpen);
        expect(copy.restaurantTypes, restaurant.restaurantTypes);
        expect(copy.ownerId, restaurant.ownerId);
        expect(copy.location, restaurant.location);
        expect(copy.imageUrl, restaurant.imageUrl);
      });

      test('should update id when provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(id: 'newId');

        expect(copy.id, 'newId');
        expect(copy.name, restaurant.name);
      });

      test('should update name when provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(name: 'New Name');

        expect(copy.name, 'New Name');
      });

      test('should update address when provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(address: '456 New St');

        expect(copy.address, '456 New St');
      });

      test('should update isOpen when provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(isOpen: false);

        expect(copy.isOpen, false);
      });

      test('should update restaurantTypes when provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(
          restaurantTypes: [RestaurantType.onRequest],
        );

        expect(copy.restaurantTypes, [RestaurantType.onRequest]);
      });

      test('should update ownerId when provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(ownerId: 'newOwner');

        expect(copy.ownerId, 'newOwner');
      });

      test('should update location when provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(location: const GeoPoint(50.0, 10.0));

        expect(copy.location.latitude, 50.0);
        expect(copy.location.longitude, 10.0);
      });

      test('should update imageUrl when provided', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(imageUrl: 'https://new.com/image.jpg');

        expect(copy.imageUrl, 'https://new.com/image.jpg');
      });

      test('should update multiple fields at once', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(
          name: 'New Name',
          isOpen: false,
          address: 'New Address',
        );

        expect(copy.name, 'New Name');
        expect(copy.isOpen, false);
        expect(copy.address, 'New Address');
        expect(copy.id, restaurant.id);
      });

      test('should not affect original restaurant when copying', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final copy = restaurant.copyWith(name: 'New Name');

        expect(restaurant.name, 'Test Restaurant');
        expect(copy.name, 'New Name');
      });
    });

    group('RestaurantType enum', () {
      test('should have fixedMenu value', () {
        expect(RestaurantType.fixedMenu, isNotNull);
        expect(RestaurantType.values, contains(RestaurantType.fixedMenu));
      });

      test('should have onRequest value', () {
        expect(RestaurantType.onRequest, isNotNull);
        expect(RestaurantType.values, contains(RestaurantType.onRequest));
      });

      test('should have exactly 2 values', () {
        expect(RestaurantType.values.length, 2);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toFirestore and fromFirestore', () {
        final originalRestaurant = Restaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [RestaurantType.fixedMenu, RestaurantType.onRequest],
          ownerId: 'owner123',
          location: const GeoPoint(45.4642, 9.1900),
          imageUrl: 'https://example.com/image.jpg',
        );

        // Convert to Firestore format
        final firestoreData = originalRestaurant.toFirestore();

        // Mock document snapshot with the Firestore data
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('rest123');
        when(() => mockDoc.data()).thenReturn({
          ...firestoreData,
          'image_url': originalRestaurant.imageUrl,
        });

        // Convert back from Firestore
        final restoredRestaurant = Restaurant.fromFirestore(mockDoc);

        expect(restoredRestaurant.id, originalRestaurant.id);
        expect(restoredRestaurant.name, originalRestaurant.name);
        expect(restoredRestaurant.address, originalRestaurant.address);
        expect(restoredRestaurant.isOpen, originalRestaurant.isOpen);
        expect(restoredRestaurant.restaurantTypes, originalRestaurant.restaurantTypes);
        expect(restoredRestaurant.ownerId, originalRestaurant.ownerId);
        expect(restoredRestaurant.location.latitude, originalRestaurant.location.latitude);
        expect(restoredRestaurant.location.longitude, originalRestaurant.location.longitude);
        expect(restoredRestaurant.imageUrl, originalRestaurant.imageUrl);
      });

      test('should handle round-trip with empty restaurantTypes', () {
        final originalRestaurant = Restaurant(
          id: 'rest456',
          name: 'Empty Types Restaurant',
          address: '456 Empty St',
          isOpen: false,
          restaurantTypes: [],
          ownerId: 'owner456',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final firestoreData = originalRestaurant.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('rest456');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredRestaurant = Restaurant.fromFirestore(mockDoc);

        expect(restoredRestaurant.restaurantTypes, isEmpty);
      });

      test('should handle round-trip with single type', () {
        final originalRestaurant = Restaurant(
          id: 'rest789',
          name: 'Single Type Restaurant',
          address: '789 Single St',
          isOpen: true,
          restaurantTypes: [RestaurantType.onRequest],
          ownerId: 'owner789',
          location: const GeoPoint(10.0, 20.0),
          imageUrl: null,
        );

        final firestoreData = originalRestaurant.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('rest789');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredRestaurant = Restaurant.fromFirestore(mockDoc);

        expect(restoredRestaurant.restaurantTypes.length, 1);
        expect(restoredRestaurant.restaurantTypes.first, RestaurantType.onRequest);
      });
    });

    group('Edge Cases', () {
      test('should handle restaurant at equator and prime meridian', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Null Island Restaurant',
          address: 'Null Island',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.location.latitude, 0);
        expect(restaurant.location.longitude, 0);
      });

      test('should handle extreme coordinate values', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: 'Extreme Restaurant',
          address: 'North Pole',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(90.0, 180.0),
          imageUrl: null,
        );

        expect(restaurant.location.latitude, 90.0);
        expect(restaurant.location.longitude, 180.0);
      });

      test('should handle very long name', () {
        final longName = 'A' * 500;
        final restaurant = Restaurant(
          id: 'rest123',
          name: longName,
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        expect(restaurant.name.length, 500);
      });

      test('should handle unicode in restaurant name', () {
        final restaurant = Restaurant(
          id: 'rest123',
          name: '寿司レストラン 🍣',
          address: '東京都渋谷区',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner123',
          location: const GeoPoint(35.6762, 139.6503),
          imageUrl: null,
        );

        expect(restaurant.name, '寿司レストラン 🍣');
        expect(restaurant.address, '東京都渋谷区');
      });
    });
  });
}
