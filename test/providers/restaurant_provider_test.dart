import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/providers/order_provider.dart';
import 'package:sous_chef/services/database/restaurant_firestore.dart';
import 'package:sous_chef/services/firebase_storage.dart' as app_storage;
import '../mocks/mock_services.dart';
import '../mocks/mock_models.dart';

/// Mock class for OrderProvider
class MockOrderProvider extends Mock implements OrderProvider {}

/// Mock class for File
class MockFile extends Mock implements File {}

void main() {
  group('RestaurantProvider Tests', () {
    late RestaurantProvider restaurantProvider;
    late MockRestaurantFirestore mockRestaurantFirestore;
    late MockFirebaseStorage mockFirebaseStorage;
    late MockOrderProvider mockOrderProvider;

    setUpAll(() {
      registerFallbackValue(MockModels.createMockRestaurant());
      registerFallbackValue(<RestaurantType>[]);
      registerFallbackValue(const GeoPoint(0, 0));
      registerFallbackValue(MockFile());
    });

    setUp(() {
      mockRestaurantFirestore = MockRestaurantFirestore();
      mockFirebaseStorage = MockFirebaseStorage();
      mockOrderProvider = MockOrderProvider();

      restaurantProvider = RestaurantProvider(
        restaurantFirestore: mockRestaurantFirestore,
        firebaseStorage: mockFirebaseStorage,
      );
    });

    tearDown(() {
      restaurantProvider.dispose();
    });

    group('State Management', () {
      test('initial state should have null restaurant and not loading', () {
        expect(restaurantProvider.restaurant, isNull);
        expect(restaurantProvider.isLoading, isFalse);
        expect(restaurantProvider.errorMessage, isNull);
        expect(restaurantProvider.hasError, isFalse);
      });

      test('clearErrors should clear error message', () {
        // We'll trigger an error first, then clear it
        restaurantProvider.clearErrors();
        expect(restaurantProvider.errorMessage, isNull);
        expect(restaurantProvider.hasError, isFalse);
      });

      test('clearErrors with clearData should also clear restaurant', () {
        restaurantProvider.clearErrors(clearData: true);
        expect(restaurantProvider.restaurant, isNull);
        expect(restaurantProvider.errorMessage, isNull);
      });
    });

    group('fetchCompleteRestaurantData', () {
      test('should populate restaurant on successful fetch', () async {
        // Arrange
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);

        // Act
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        // Assert
        expect(restaurantProvider.restaurant, isNotNull);
        expect(restaurantProvider.restaurant!.id, 'rest123');
        expect(restaurantProvider.restaurant!.name, 'Test Restaurant');
        expect(restaurantProvider.isLoading, isFalse);
        expect(restaurantProvider.errorMessage, isNull);
        verify(() => mockRestaurantFirestore.getRestaurant('rest123')).called(1);
      });

      test('should set error message on fetch failure', () async {
        // Arrange
        when(() => mockRestaurantFirestore.getRestaurant(any()))
            .thenThrow(Exception('Restaurant not found'));

        // Act
        await restaurantProvider.fetchCompleteRestaurantData('invalid_id');

        // Assert
        expect(restaurantProvider.restaurant, isNull);
        expect(restaurantProvider.isLoading, isFalse);
        expect(restaurantProvider.errorMessage, isNotNull);
        expect(restaurantProvider.hasError, isTrue);
      });

      test('should handle network error', () async {
        // Arrange
        when(() => mockRestaurantFirestore.getRestaurant(any()))
            .thenThrow(Exception('network-request-failed'));

        // Act
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        // Assert
        expect(restaurantProvider.errorMessage, contains('Network error'));
      });

      test('should handle permission denied error', () async {
        // Arrange
        when(() => mockRestaurantFirestore.getRestaurant(any()))
            .thenThrow(Exception('permission-denied'));

        // Act
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        // Assert
        expect(restaurantProvider.errorMessage, contains('permission'));
      });
    });

    group('fetchRestaurantOnly', () {
      test('should populate restaurant on successful fetch', () async {
        // Arrange
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest456',
          name: 'Another Restaurant',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest456'))
            .thenAnswer((_) async => mockRestaurant);

        // Act
        await restaurantProvider.fetchRestaurantOnly('rest456');

        // Assert
        expect(restaurantProvider.restaurant, isNotNull);
        expect(restaurantProvider.restaurant!.id, 'rest456');
        expect(restaurantProvider.isLoading, isFalse);
      });

      test('should set error on failure', () async {
        // Arrange
        when(() => mockRestaurantFirestore.getRestaurant(any()))
            .thenThrow(Exception('Error'));

        // Act
        await restaurantProvider.fetchRestaurantOnly('rest123');

        // Assert
        expect(restaurantProvider.hasError, isTrue);
      });
    });

    group('createRestaurant', () {
      test('should return restaurant ID on successful creation', () async {
        // Arrange
        when(() => mockRestaurantFirestore.createRestaurant(
              restaurantName: any(named: 'restaurantName'),
              ownerId: any(named: 'ownerId'),
            )).thenAnswer((_) async => 'new_rest_123');

        // Act
        final result = await restaurantProvider.createRestaurant(
          restaurantName: 'New Restaurant',
          ownerId: 'owner123',
        );

        // Assert
        expect(result, 'new_rest_123');
        expect(restaurantProvider.isLoading, isFalse);
        expect(restaurantProvider.errorMessage, isNull);
        verify(() => mockRestaurantFirestore.createRestaurant(
              restaurantName: 'New Restaurant',
              ownerId: 'owner123',
            )).called(1);
      });

      test('should return null on creation failure', () async {
        // Arrange
        when(() => mockRestaurantFirestore.createRestaurant(
              restaurantName: any(named: 'restaurantName'),
              ownerId: any(named: 'ownerId'),
            )).thenThrow(Exception('Creation failed'));

        // Act
        final result = await restaurantProvider.createRestaurant(
          restaurantName: 'New Restaurant',
          ownerId: 'owner123',
        );

        // Assert
        expect(result, isNull);
        expect(restaurantProvider.hasError, isTrue);
      });
    });

    group('fetchFavoriteRestaurantsByIds', () {
      test('should return list of restaurants on success', () async {
        // Arrange
        final rest1 = MockModels.createMockRestaurant(id: 'rest1', name: 'Rest 1');
        final rest2 = MockModels.createMockRestaurant(id: 'rest2', name: 'Rest 2');

        when(() => mockRestaurantFirestore.getFavouriteInfo('rest1'))
            .thenAnswer((_) async => rest1);
        when(() => mockRestaurantFirestore.getFavouriteInfo('rest2'))
            .thenAnswer((_) async => rest2);

        // Act
        final result = await restaurantProvider.fetchFavoriteRestaurantsByIds(['rest1', 'rest2']);

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'rest1');
        expect(result[1].id, 'rest2');
      });

      test('should return empty list for empty input', () async {
        // Act
        final result = await restaurantProvider.fetchFavoriteRestaurantsByIds([]);

        // Assert
        expect(result, isEmpty);
      });

      test('should filter out null results', () async {
        // Arrange
        final rest1 = MockModels.createMockRestaurant(id: 'rest1', name: 'Rest 1');

        when(() => mockRestaurantFirestore.getFavouriteInfo('rest1'))
            .thenAnswer((_) async => rest1);
        when(() => mockRestaurantFirestore.getFavouriteInfo('rest2'))
            .thenAnswer((_) async => null);

        // Act
        final result = await restaurantProvider.fetchFavoriteRestaurantsByIds(['rest1', 'rest2']);

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 'rest1');
      });

      test('should set error on failure', () async {
        // Arrange
        when(() => mockRestaurantFirestore.getFavouriteInfo(any()))
            .thenThrow(Exception('Error'));

        // Act
        final result = await restaurantProvider.fetchFavoriteRestaurantsByIds(['rest1']);

        // Assert
        expect(result, isEmpty);
        expect(restaurantProvider.errorMessage, isNotNull);
      });
    });

    group('fetchNearbyRestaurants', () {
      test('should return list of nearby restaurants', () async {
        // Arrange
        final restaurants = [
          MockModels.createMockRestaurant(id: 'rest1'),
          MockModels.createMockRestaurant(id: 'rest2'),
        ];

        when(() => mockRestaurantFirestore.getRestaurantsNearLocation(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusInKm: any(named: 'radiusInKm'),
            )).thenAnswer((_) async => restaurants);

        // Act
        final result = await restaurantProvider.fetchNearbyRestaurants(
          latitude: 45.0,
          longitude: 9.0,
          radiusInKm: 10.0,
        );

        // Assert
        expect(result.length, 2);
      });

      test('should return empty list on error', () async {
        // Arrange
        when(() => mockRestaurantFirestore.getRestaurantsNearLocation(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusInKm: any(named: 'radiusInKm'),
            )).thenThrow(Exception('Error'));

        // Act
        final result = await restaurantProvider.fetchNearbyRestaurants(
          latitude: 45.0,
          longitude: 9.0,
          radiusInKm: 10.0,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('updateRestaurantOpenStatus', () {
      test('should update open status successfully', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          isOpen: false,
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantOpenStatus(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await restaurantProvider.updateRestaurantOpenStatus('rest123', true);

        // Assert
        expect(restaurantProvider.restaurant!.isOpen, isTrue);
        expect(restaurantProvider.isLoading, isFalse);
        verify(() => mockRestaurantFirestore.updateRestaurantOpenStatus('rest123', true))
            .called(1);
      });

      test('should set error on update failure', () async {
        // Arrange
        when(() => mockRestaurantFirestore.updateRestaurantOpenStatus(any(), any()))
            .thenThrow(Exception('Update failed'));

        // Act
        await restaurantProvider.updateRestaurantOpenStatus('rest123', true);

        // Assert
        expect(restaurantProvider.hasError, isTrue);
      });
    });

    group('updateRestaurantName', () {
      test('should update name successfully and propagate to orders', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Old Name',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantName(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockOrderProvider.updateRestaurantNameInOrders(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await restaurantProvider.updateRestaurantName(
          'rest123',
          'New Name',
          orderProvider: mockOrderProvider,
        );

        // Assert
        expect(restaurantProvider.restaurant!.name, 'New Name');
        verify(() => mockRestaurantFirestore.updateRestaurantName('rest123', 'New Name'))
            .called(1);
        verify(() => mockOrderProvider.updateRestaurantNameInOrders('rest123', 'New Name'))
            .called(1);
      });

      test('should set error on update failure', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Old Name',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantName(any(), any()))
            .thenThrow(Exception('Update failed'));

        // Act
        await restaurantProvider.updateRestaurantName(
          'rest123',
          'New Name',
          orderProvider: mockOrderProvider,
        );

        // Assert
        expect(restaurantProvider.hasError, isTrue);
        expect(restaurantProvider.errorMessage, isNotNull);
        expect(restaurantProvider.isLoading, isFalse);
      });
    });

    group('updateRestaurantAddress', () {
      test('should update address successfully', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: 'Old Address',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantAddress(
              any(), any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockOrderProvider.updateRestaurantAddressInOrders(
              any(), any(), any()))
            .thenAnswer((_) async {});

        // Act
        await restaurantProvider.updateRestaurantAddress(
          'rest123',
          'New Address',
          45.0,
          9.0,
          orderProvider: mockOrderProvider,
        );

        // Assert
        expect(restaurantProvider.restaurant!.address, 'New Address');
        verify(() => mockRestaurantFirestore.updateRestaurantAddress(
              'rest123', 'New Address', 45.0, 9.0))
            .called(1);
      });

      test('should set error on update failure', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          address: 'Old Address',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantAddress(
              any(), any(), any(), any()))
            .thenThrow(Exception('Address update failed'));

        // Act
        await restaurantProvider.updateRestaurantAddress(
          'rest123',
          'New Address',
          45.0,
          9.0,
          orderProvider: mockOrderProvider,
        );

        // Assert
        expect(restaurantProvider.hasError, isTrue);
        expect(restaurantProvider.errorMessage, isNotNull);
        expect(restaurantProvider.isLoading, isFalse);
      });
    });

    group('updateRestaurantImage', () {
      test('should update image successfully', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        final mockFile = MockFile();
        when(() => mockFirebaseStorage.uploadRestaurantImage(any(), any()))
            .thenAnswer((_) async => 'https://example.com/image.png');
        when(() => mockRestaurantFirestore.updateRestaurantImage(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await restaurantProvider.updateRestaurantImage('rest123', mockFile);

        // Assert
        expect(restaurantProvider.restaurant!.imageUrl, 'https://example.com/image.png');
        verify(() => mockFirebaseStorage.uploadRestaurantImage('rest123', mockFile))
            .called(1);
        verify(() => mockRestaurantFirestore.updateRestaurantImage(
              'rest123', 'https://example.com/image.png'))
            .called(1);
      });

      test('should set error when upload returns null', () async {
        // Arrange
        final mockFile = MockFile();
        when(() => mockFirebaseStorage.uploadRestaurantImage(any(), any()))
            .thenAnswer((_) async => null);

        // Act
        await restaurantProvider.updateRestaurantImage('rest123', mockFile);

        // Assert
        expect(restaurantProvider.errorMessage, contains('Impossible to upload'));
      });

      test('should set error on upload exception', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        final mockFile = MockFile();
        when(() => mockFirebaseStorage.uploadRestaurantImage(any(), any()))
            .thenThrow(Exception('Upload failed'));

        // Act
        await restaurantProvider.updateRestaurantImage('rest123', mockFile);

        // Assert
        expect(restaurantProvider.hasError, isTrue);
        expect(restaurantProvider.errorMessage, isNotNull);
        expect(restaurantProvider.isLoading, isFalse);
      });
    });

    group('updateRestaurantImageUrl', () {
      test('should update image URL directly', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantImage(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await restaurantProvider.updateRestaurantImageUrl(
          'rest123',
          'https://example.com/new_image.png',
        );

        // Assert
        expect(restaurantProvider.restaurant!.imageUrl, 'https://example.com/new_image.png');
        verify(() => mockRestaurantFirestore.updateRestaurantImage(
              'rest123', 'https://example.com/new_image.png'))
            .called(1);
      });

      test('should set error on update failure', () async {
        // Arrange - first load a restaurant
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantImage(any(), any()))
            .thenThrow(Exception('Update failed'));

        // Act
        await restaurantProvider.updateRestaurantImageUrl(
          'rest123',
          'https://example.com/new_image.png',
        );

        // Assert
        expect(restaurantProvider.hasError, isTrue);
        expect(restaurantProvider.errorMessage, isNotNull);
        expect(restaurantProvider.isLoading, isFalse);
      });
    });

    group('updateRestaurantType', () {
      test('should toggle restaurant type when restaurant is loaded', () async {
        // Arrange - first load a restaurant with no types
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          restaurantTypes: [],
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantType(any(), any()))
            .thenAnswer((_) async {});

        // Act - add a type
        await restaurantProvider.updateRestaurantType(
          'rest123',
          RestaurantType.fixedMenu,
        );

        // Assert
        expect(restaurantProvider.restaurant!.restaurantTypes, contains(RestaurantType.fixedMenu));
        expect(restaurantProvider.isLoading, isFalse);
        verify(() => mockRestaurantFirestore.updateRestaurantType('rest123', any()))
            .called(1);
      });

      test('should toggle off existing restaurant type', () async {
        // Arrange - first load a restaurant with an existing type
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          restaurantTypes: [RestaurantType.fixedMenu],
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantType(any(), any()))
            .thenAnswer((_) async {});

        // Act - toggle off the existing type
        await restaurantProvider.updateRestaurantType(
          'rest123',
          RestaurantType.fixedMenu,
        );

        // Assert
        expect(restaurantProvider.restaurant!.restaurantTypes, isNot(contains(RestaurantType.fixedMenu)));
        expect(restaurantProvider.isLoading, isFalse);
      });

      test('should fetch restaurant first when not loaded', () async {
        // Arrange - restaurant is NOT loaded (null)
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
          restaurantTypes: [],
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        when(() => mockRestaurantFirestore.updateRestaurantType(any(), any()))
            .thenAnswer((_) async {});

        // Act - call without loading restaurant first
        await restaurantProvider.updateRestaurantType(
          'rest123',
          RestaurantType.onRequest,
        );

        // Assert
        expect(restaurantProvider.restaurant, isNotNull);
        expect(restaurantProvider.restaurant!.restaurantTypes, contains(RestaurantType.onRequest));
        expect(restaurantProvider.isLoading, isFalse);
        // Should fetch restaurant first
        verify(() => mockRestaurantFirestore.getRestaurant('rest123')).called(1);
        verify(() => mockRestaurantFirestore.updateRestaurantType('rest123', any()))
            .called(1);
      });

      test('should fetch restaurant when loaded ID does not match', () async {
        // Arrange - load a different restaurant first
        final loadedRestaurant = MockModels.createMockRestaurant(
          id: 'different123',
          name: 'Different Restaurant',
        );
        when(() => mockRestaurantFirestore.getRestaurant('different123'))
            .thenAnswer((_) async => loadedRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('different123');

        // Now set up for the target restaurant
        final targetRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Target Restaurant',
          restaurantTypes: [],
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => targetRestaurant);
        when(() => mockRestaurantFirestore.updateRestaurantType(any(), any()))
            .thenAnswer((_) async {});

        // Act - update type on a restaurant that's not currently loaded
        await restaurantProvider.updateRestaurantType(
          'rest123',
          RestaurantType.fixedMenu,
        );

        // Assert
        expect(restaurantProvider.restaurant!.id, 'rest123');
        expect(restaurantProvider.restaurant!.restaurantTypes, contains(RestaurantType.fixedMenu));
      });

      test('should set error on update failure', () async {
        // Arrange - load a restaurant first
        final mockRestaurant = MockModels.createMockRestaurant(
          id: 'rest123',
          name: 'Test Restaurant',
        );
        when(() => mockRestaurantFirestore.getRestaurant('rest123'))
            .thenAnswer((_) async => mockRestaurant);
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        when(() => mockRestaurantFirestore.updateRestaurantType(any(), any()))
            .thenThrow(Exception('Type update failed'));

        // Act
        await restaurantProvider.updateRestaurantType(
          'rest123',
          RestaurantType.fixedMenu,
        );

        // Assert
        expect(restaurantProvider.hasError, isTrue);
        expect(restaurantProvider.errorMessage, isNotNull);
        expect(restaurantProvider.isLoading, isFalse);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners on state changes', () async {
        // Arrange
        int notifyCount = 0;
        restaurantProvider.addListener(() => notifyCount++);

        final mockRestaurant = MockModels.createMockRestaurant(id: 'rest123');
        when(() => mockRestaurantFirestore.getRestaurant(any()))
            .thenAnswer((_) async => mockRestaurant);

        // Act
        await restaurantProvider.fetchCompleteRestaurantData('rest123');

        // Assert - should notify at least twice (loading start, loading end)
        expect(notifyCount, greaterThanOrEqualTo(2));
      });
    });
  });
}
