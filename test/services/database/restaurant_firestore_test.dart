import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/services/database/restaurant_firestore.dart';
import '../../mocks/mock_models.dart';

/// Mock Firestore classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(const GetOptions(source: Source.server));
  });

  group('RestaurantFirestore Service Tests', () {
    late RestaurantFirestore restaurantFirestore;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocRef;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocRef = MockDocumentReference();

      when(() => mockFirestore.collection('restaurants'))
          .thenReturn(mockCollection);

      restaurantFirestore = RestaurantFirestore(firestoreInstance: mockFirestore);
    });

    group('createRestaurant', () {
      test('should create restaurant and return document ID', () async {
        // Arrange
        when(() => mockCollection.add(any()))
            .thenAnswer((_) async => mockDocRef);
        when(() => mockDocRef.id).thenReturn('newRestaurant123');

        // Act
        final result = await restaurantFirestore.createRestaurant(
          restaurantName: 'Test Restaurant',
          ownerId: 'owner123',
        );

        // Assert
        expect(result, 'newRestaurant123');
        verify(() => mockCollection.add({
          'name': 'Test Restaurant',
          'owner_id': 'owner123',
        })).called(1);
      });
    });

    group('getRestaurant', () {
      test('should return restaurant when document exists', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('rest123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'name': 'Test Restaurant',
          'address': '123 Main St',
          'is_open': true,
          'owner_id': 'owner123',
          'location': const GeoPoint(45.0, 9.0),
          'restaurant_types': ['fixed_menu'],
          'image_url': 'https://example.com/image.jpg',
        });

        // Act
        final result = await restaurantFirestore.getRestaurant('rest123');

        // Assert
        expect(result.id, 'rest123');
        expect(result.name, 'Test Restaurant');
        expect(result.address, '123 Main St');
        expect(result.isOpen, true);
      });

      test('should throw exception when restaurant not found', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('notFound')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act & Assert
        expect(
          () => restaurantFirestore.getRestaurant('notFound'),
          throwsException,
        );
      });
    });

    group('updateRestaurantOpenStatus', () {
      test('should update isOpen status', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await restaurantFirestore.updateRestaurantOpenStatus('rest123', true);

        // Assert
        verify(() => mockDocRef.update({'is_open': true})).called(1);
      });

      test('should update isOpen to false', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await restaurantFirestore.updateRestaurantOpenStatus('rest123', false);

        // Assert
        verify(() => mockDocRef.update({'is_open': false})).called(1);
      });
    });

    group('updateRestaurantName', () {
      test('should update restaurant name', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await restaurantFirestore.updateRestaurantName('rest123', 'New Name');

        // Assert
        verify(() => mockDocRef.update({'name': 'New Name'})).called(1);
      });
    });

    group('updateRestaurantAddress', () {
      test('should update address and location', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await restaurantFirestore.updateRestaurantAddress(
          'rest123',
          '456 New St',
          45.5,
          9.5,
        );

        // Assert
        verify(() => mockDocRef.update({
          'address': '456 New St',
          'location': const GeoPoint(45.5, 9.5),
        })).called(1);
      });
    });

    group('updateRestaurantType', () {
      test('should update restaurant types to fixed_menu', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await restaurantFirestore.updateRestaurantType(
          'rest123',
          [RestaurantType.fixedMenu],
        );

        // Assert
        verify(() => mockDocRef.update({
          'restaurant_types': ['fixed_menu'],
        })).called(1);
      });

      test('should update restaurant types to on_request', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await restaurantFirestore.updateRestaurantType(
          'rest123',
          [RestaurantType.onRequest],
        );

        // Assert
        verify(() => mockDocRef.update({
          'restaurant_types': ['on_request'],
        })).called(1);
      });

      test('should update with multiple types', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await restaurantFirestore.updateRestaurantType(
          'rest123',
          [RestaurantType.fixedMenu, RestaurantType.onRequest],
        );

        // Assert
        verify(() => mockDocRef.update({
          'restaurant_types': ['fixed_menu', 'on_request'],
        })).called(1);
      });
    });

    group('updateRestaurantImage', () {
      test('should update restaurant image URL', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await restaurantFirestore.updateRestaurantImage(
          'rest123',
          'https://example.com/new-image.jpg',
        );

        // Assert
        verify(() => mockDocRef.update({
          'image_url': 'https://example.com/new-image.jpg',
        })).called(1);
      });
    });

    group('getFavouriteInfo', () {
      test('should return restaurant when found', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.get(any())).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('rest123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'name': 'Favorite Restaurant',
          'address': '789 Fav St',
          'is_open': true,
          'owner_id': 'owner456',
          'location': const GeoPoint(45.0, 9.0),
          'restaurant_types': [],
          'image_url': null,
        });

        // Act
        final result = await restaurantFirestore.getFavouriteInfo('rest123');

        // Assert
        expect(result, isNotNull);
        expect(result!.name, 'Favorite Restaurant');
      });

      test('should return null when restaurant not found', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('notFound')).thenReturn(mockDocRef);
        when(() => mockDocRef.get(any())).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act
        final result = await restaurantFirestore.getFavouriteInfo('notFound');

        // Assert
        expect(result, isNull);
      });

      test('should return null on error', () async {
        // Arrange
        when(() => mockCollection.doc('rest123')).thenReturn(mockDocRef);
        when(() => mockDocRef.get(any())).thenThrow(Exception('Network error'));

        // Act
        final result = await restaurantFirestore.getFavouriteInfo('rest123');

        // Assert
        expect(result, isNull);
      });
    });
  });

  group('Restaurant Model Tests', () {
    test('should create restaurant with correct properties', () {
      final restaurant = MockModels.createMockRestaurant(
        id: 'rest123',
        name: 'Test Restaurant',
        address: '123 Main St',
        isOpen: true,
      );

      expect(restaurant.id, 'rest123');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.address, '123 Main St');
      expect(restaurant.isOpen, isTrue);
    });

    test('should support location with GeoPoint', () {
      final restaurant = MockModels.createMockRestaurant(
        location: const GeoPoint(45.0, 9.0),
      );

      expect(restaurant.location, isNotNull);
      expect(restaurant.location.latitude, 45.0);
      expect(restaurant.location.longitude, 9.0);
    });

    group('toggleRestaurantType', () {
      test('should add type when not present', () {
        final restaurant = MockModels.createMockRestaurant(
          restaurantTypes: [RestaurantType.fixedMenu],
        );

        final updated = restaurant.toggleRestaurantType(RestaurantType.onRequest);

        expect(updated.restaurantTypes, contains(RestaurantType.onRequest));
        expect(updated.restaurantTypes, contains(RestaurantType.fixedMenu));
      });

      test('should remove type when present', () {
        final restaurant = MockModels.createMockRestaurant(
          restaurantTypes: [RestaurantType.fixedMenu, RestaurantType.onRequest],
        );

        final updated = restaurant.toggleRestaurantType(RestaurantType.onRequest);

        expect(updated.restaurantTypes, isNot(contains(RestaurantType.onRequest)));
        expect(updated.restaurantTypes, contains(RestaurantType.fixedMenu));
      });
    });

    group('copyWith', () {
      test('should copy with new name', () {
        final restaurant = MockModels.createMockRestaurant(name: 'Old Name');
        final updated = restaurant.copyWith(name: 'New Name');

        expect(updated.name, 'New Name');
        expect(updated.id, restaurant.id);
      });

      test('should copy with new isOpen status', () {
        final restaurant = MockModels.createMockRestaurant(isOpen: false);
        final updated = restaurant.copyWith(isOpen: true);

        expect(updated.isOpen, isTrue);
      });
    });
  });
}
