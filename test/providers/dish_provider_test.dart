import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/providers/dish_provider.dart';
import 'package:sous_chef/models/dish.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_models.dart';
import 'dart:io';

/// Mock File class for image testing
class MockFile extends Mock implements File {}

void main() {
  group('DishProvider Tests', () {
    late DishProvider dishProvider;
    late MockDishFirestore mockDishFirestore;
    late MockFirebaseStorage mockFirebaseStorage;

    setUpAll(() {
      // Register fallback values
      registerFallbackValue(MockModels.createMockDish());
      registerFallbackValue(Course.mainDish);
      registerFallbackValue(Cuisine.italian);
      registerFallbackValue(MockFile());
    });

    setUp(() {
      mockDishFirestore = MockDishFirestore();
      mockFirebaseStorage = MockFirebaseStorage();

      // Create DishProvider with injected mocks
      dishProvider = DishProvider(
        dishFirestore: mockDishFirestore,
        firebaseStorage: mockFirebaseStorage,
      );
    });

    group('State Management', () {
      test('initial state should have empty dishes list and not loading', () {
        expect(dishProvider.dishes, isEmpty);
        expect(dishProvider.isLoading, false);
        expect(dishProvider.errorMessage, null);
        expect(dishProvider.currentRestaurantId, null);
      });
    });

    group('fetchDishes', () {
      test('should populate dishes list on successful fetch', () async {
        // Arrange
        final mockDishes = [
          MockModels.createMockDish(id: 'dish1', name: 'Pasta'),
          MockModels.createMockDish(id: 'dish2', name: 'Pizza'),
          MockModels.createMockDish(id: 'dish3', name: 'Salad'),
        ];

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => mockDishes);

        // Act
        await dishProvider.fetchDishes('restaurant123');

        // Assert
        expect(dishProvider.dishes.length, 3);
        expect(dishProvider.dishes[0].name, 'Pasta');
        expect(dishProvider.dishes[1].name, 'Pizza');
        expect(dishProvider.isLoading, false);
        expect(dishProvider.errorMessage, null);
        expect(dishProvider.currentRestaurantId, 'restaurant123');

        verify(() => mockDishFirestore.getRestaurantDishes('restaurant123')).called(1);
      });

      test('should return empty list when no dishes found', () async {
        // Arrange
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => []);

        // Act
        await dishProvider.fetchDishes('restaurant123');

        // Assert
        expect(dishProvider.dishes, isEmpty);
        expect(dishProvider.isLoading, false);
      });

      test('should set error message on fetch failure', () async {
        // Arrange
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenThrow(Exception('Network error'));

        // Act
        await dishProvider.fetchDishes('restaurant123');

        // Assert
        expect(dishProvider.dishes, isEmpty);
        expect(dishProvider.isLoading, false);
        expect(dishProvider.errorMessage, isNotNull);
      });

      test('should clear previous errors before fetching', () async {
        // Arrange - First fetch with error
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenThrow(Exception('Network error'));
        await dishProvider.fetchDishes('restaurant123');
        expect(dishProvider.errorMessage, isNotNull);

        // Arrange - Second fetch with success
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [MockModels.createMockDish()]);

        // Act
        await dishProvider.fetchDishes('restaurant123');

        // Assert
        expect(dishProvider.errorMessage, null);
      });
    });

    group('getDishById', () {
      test('should return dish when it exists', () async {
        // Arrange
        final mockDishes = [
          MockModels.createMockDish(id: 'dish1', name: 'Pasta'),
          MockModels.createMockDish(id: 'dish2', name: 'Pizza'),
        ];

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => mockDishes);
        await dishProvider.fetchDishes('restaurant123');

        // Act
        final result = dishProvider.getDishById('dish1');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'dish1');
        expect(result?.name, 'Pasta');
      });

      test('should return null when dish does not exist', () async {
        // Arrange
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [MockModels.createMockDish(id: 'dish1')]);
        await dishProvider.fetchDishes('restaurant123');

        // Act
        final result = dishProvider.getDishById('nonexistent');

        // Assert
        expect(result, null);
      });
    });

    group('deleteDish', () {
      test('should delete dish and update local state', () async {
        // Arrange
        final mockDishes = [
          MockModels.createMockDish(id: 'dish1', name: 'Pasta'),
          MockModels.createMockDish(id: 'dish2', name: 'Pizza'),
        ];

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => mockDishes);
        when(() => mockDishFirestore.deleteDish(any(), any()))
            .thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');
        expect(dishProvider.dishes.length, 2);

        // Act
        await dishProvider.deleteDish('restaurant123', 'dish1');

        // Assert
        expect(dishProvider.dishes.length, 1);
        expect(dishProvider.dishes[0].id, 'dish2');
        expect(dishProvider.isLoading, false);

        verify(() => mockDishFirestore.deleteDish('restaurant123', 'dish1')).called(1);
      });

      test('should delete dish image from storage when image exists', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          name: 'Pasta',
          imageUrl: 'https://example.com/image.jpg',
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.deleteDish(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockFirebaseStorage.deleteDishImage(any(), any()))
            .thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.deleteDish('restaurant123', 'dish1');

        // Assert
        verify(() => mockFirebaseStorage.deleteDishImage('restaurant123', 'dish1')).called(1);
      });

      test('should skip image deletion when dish has no image', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          name: 'Pasta',
          imageUrl: null,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.deleteDish(any(), any()))
            .thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.deleteDish('restaurant123', 'dish1');

        // Assert
        verifyNever(() => mockFirebaseStorage.deleteDishImage(any(), any()));
      });

      test('should skip image deletion when dish has empty string image', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          name: 'Pasta',
          imageUrl: '',
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.deleteDish(any(), any()))
            .thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.deleteDish('restaurant123', 'dish1');

        // Assert
        verifyNever(() => mockFirebaseStorage.deleteDishImage(any(), any()));
      });

      test('should continue deletion even if image deletion fails', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          name: 'Pasta',
          imageUrl: 'https://example.com/image.jpg',
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockFirebaseStorage.deleteDishImage(any(), any()))
            .thenThrow(Exception('Storage error'));
        when(() => mockDishFirestore.deleteDish(any(), any()))
            .thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.deleteDish('restaurant123', 'dish1');

        // Assert - should succeed even if image deletion failed
        expect(dishProvider.dishes, isEmpty);
        expect(dishProvider.isLoading, false);
        expect(dishProvider.errorMessage, null);
        verify(() => mockDishFirestore.deleteDish('restaurant123', 'dish1')).called(1);
      });

      test('should set error when dish not found in local state', () async {
        // Arrange - fetch dishes without the one we want to delete
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [MockModels.createMockDish(id: 'dish1')]);

        await dishProvider.fetchDishes('restaurant123');

        // Act - try to delete a dish that doesn't exist locally
        await dishProvider.deleteDish('restaurant123', 'nonexistent');

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
        expect(dishProvider.errorMessage, contains('Dish not found'));
        expect(dishProvider.isLoading, false);
      });

      test('should set error message on deletion failure', () async {
        // Arrange
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [MockModels.createMockDish(id: 'dish1')]);
        when(() => mockDishFirestore.deleteDish(any(), any()))
            .thenThrow(Exception('Deletion failed'));

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.deleteDish('restaurant123', 'dish1');

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
      });
    });

    group('updateDishAvailability', () {
      test('should update availability to false', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          isAvailable: true,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDishAvailability(any(), any(), any()))
            .thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');
        expect(dishProvider.dishes[0].isAvailable, true);

        // Act
        await dishProvider.updateDishAvailability('restaurant123', 'dish1', false);

        // Assert
        expect(dishProvider.dishes[0].isAvailable, false);
        expect(dishProvider.isLoading, false);

        verify(() => mockDishFirestore.updateDishAvailability('restaurant123', 'dish1', false)).called(1);
      });

      test('should update availability to true', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          isAvailable: false,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDishAvailability(any(), any(), any()))
            .thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDishAvailability('restaurant123', 'dish1', true);

        // Assert
        expect(dishProvider.dishes[0].isAvailable, true);
      });

      test('should set error on failure', () async {
        // Arrange
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [MockModels.createMockDish(id: 'dish1')]);
        when(() => mockDishFirestore.updateDishAvailability(any(), any(), any()))
            .thenThrow(Exception('Update failed'));

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDishAvailability('restaurant123', 'dish1', false);

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
      });
    });

    group('createDish', () {
      test('should create regular dish successfully', () async {
        // Arrange
        when(() => mockDishFirestore.createDish(
              restaurantId: any(named: 'restaurantId'),
              dish: any(named: 'dish'),
            )).thenAnswer((_) async => 'newDishId');

        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'New Pasta',
          description: 'Delicious pasta',
          price: 12.99,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: false,
          isAvailable: true,
        );

        // Assert
        expect(dishProvider.dishes.length, 1);
        expect(dishProvider.dishes[0].name, 'New Pasta');
        expect(dishProvider.dishes[0].id, 'newDishId');
        expect(dishProvider.isLoading, false);
        expect(dishProvider.errorMessage, null);
      });

      test('should create special dish with user info', () async {
        // Arrange
        when(() => mockDishFirestore.createDish(
              restaurantId: any(named: 'restaurantId'),
              dish: any(named: 'dish'),
            )).thenAnswer((_) async => 'specialDishId');

        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'Special Dish',
          description: 'A special request',
          price: 25.00,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: true,
          userUsername: 'customer123',
        );

        // Assert
        expect(dishProvider.dishes.length, 1);
        expect(dishProvider.dishes[0].isSpecial, true);
        expect(dishProvider.isLoading, false);
      });

      test('should fail when special dish missing user info', () async {
        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'Special Dish',
          description: 'A special request',
          price: 25.00,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: true,
          userUsername: null, // Missing required field
        );

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
        expect(dishProvider.dishes, isEmpty);
      });

      test('should fail when special dish has empty username', () async {
        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'Special Dish',
          description: 'A special request',
          price: 25.00,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: true,
          userUsername: '', // Empty string
        );

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
        expect(dishProvider.errorMessage, contains('username'));
        expect(dishProvider.dishes, isEmpty);
      });

      test('should fail when regular dish missing isAvailable', () async {
        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'Regular Dish',
          description: 'A regular dish',
          price: 15.00,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: false,
          isAvailable: null, // Missing required field for regular dishes
        );

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
        expect(dishProvider.errorMessage, contains('isAvailable'));
        expect(dishProvider.dishes, isEmpty);
        expect(dishProvider.isLoading, false);
      });

      test('should upload image when imageFile provided', () async {
        // Arrange
        final mockFile = MockFile();
        when(() => mockDishFirestore.createDish(
              restaurantId: any(named: 'restaurantId'),
              dish: any(named: 'dish'),
            )).thenAnswer((_) async => 'newDishId');
        when(() => mockFirebaseStorage.uploadDishImage(any(), any(), any()))
            .thenAnswer((_) async => 'https://example.com/new-image.jpg');
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'New Pasta',
          description: 'Delicious pasta',
          price: 12.99,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: false,
          isAvailable: true,
          imageFile: mockFile,
        );

        // Assert
        verify(() => mockFirebaseStorage.uploadDishImage('restaurant123', 'newDishId', mockFile)).called(1);
      });

      test('should set error on createDish service failure', () async {
        // Arrange
        when(() => mockDishFirestore.createDish(
              restaurantId: any(named: 'restaurantId'),
              dish: any(named: 'dish'),
            )).thenThrow(Exception('Create failed'));

        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'New Pasta',
          description: 'Delicious pasta',
          price: 12.99,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: false,
          isAvailable: true,
        );

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
        expect(dishProvider.dishes, isEmpty);
        expect(dishProvider.isLoading, false);
      });

      test('should create dish with custom minForewarningDays', () async {
        // Arrange
        when(() => mockDishFirestore.createDish(
              restaurantId: any(named: 'restaurantId'),
              dish: any(named: 'dish'),
            )).thenAnswer((_) async => 'newDishId');

        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'Special Order',
          description: 'Requires advance notice',
          price: 50.00,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: false,
          isAvailable: true,
          minForewarningDays: 3,
        );

        // Assert
        expect(dishProvider.dishes.length, 1);
        expect(dishProvider.dishes[0].minForewarningDays, 3);
      });

      test('should create dish with imageUrl', () async {
        // Arrange
        when(() => mockDishFirestore.createDish(
              restaurantId: any(named: 'restaurantId'),
              dish: any(named: 'dish'),
            )).thenAnswer((_) async => 'newDishId');

        // Act
        await dishProvider.createDish(
          restaurantId: 'restaurant123',
          name: 'New Pasta',
          description: 'Delicious pasta',
          price: 12.99,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          isSpecial: false,
          isAvailable: true,
          imageUrl: 'https://example.com/existing-image.jpg',
        );

        // Assert
        expect(dishProvider.dishes.length, 1);
        expect(dishProvider.dishes[0].imageUrl, 'https://example.com/existing-image.jpg');
      });
    });

    group('updateDish', () {
      test('should update dish fields', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          name: 'Old Name',
          price: 10.00,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          name: 'New Name',
          price: 15.00,
        );

        // Assert
        expect(dishProvider.dishes[0].name, 'New Name');
        expect(dishProvider.dishes[0].price, 15.00);
        expect(dishProvider.isLoading, false);
      });

      test('should update dish description', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          description: 'Old description',
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          description: 'New description',
        );

        // Assert
        expect(dishProvider.dishes[0].description, 'New description');
      });

      test('should update dish course and cuisine', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          course: Course.mainDish,
          cuisine: Cuisine.italian,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          course: Course.appetizer,
          cuisine: Cuisine.japanese,
        );

        // Assert
        expect(dishProvider.dishes[0].course, Course.appetizer);
        expect(dishProvider.dishes[0].cuisine, Cuisine.japanese);
      });

      test('should update dish minForewarningDays', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          minForewarningDays: 0,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          minForewarningDays: 5,
        );

        // Assert
        expect(dishProvider.dishes[0].minForewarningDays, 5);
      });

      test('should update availability for regular dish', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          isSpecial: false,
          isAvailable: true,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          isAvailable: false,
        );

        // Assert
        expect(dishProvider.dishes[0].isAvailable, false);
      });

      test('should update userUsername for special dish', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          isSpecial: true,
          userUsername: 'oldUser',
          isAvailable: null,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          userUsername: 'newUser',
        );

        // Assert
        expect(dishProvider.dishes[0].userUsername, 'newUser');
      });

      test('should preserve existing userUsername when not updating special dish', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          isSpecial: true,
          userUsername: 'existingUser',
          isAvailable: null,
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act - update name only, not userUsername
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          name: 'Updated Name',
        );

        // Assert - should preserve userUsername
        expect(dishProvider.dishes[0].userUsername, 'existingUser');
        expect(dishProvider.dishes[0].name, 'Updated Name');
      });

      test('should handle image update', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(id: 'dish1');
        final mockFile = MockFile();

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockFirebaseStorage.uploadDishImage(any(), any(), any()))
            .thenAnswer((_) async => 'https://example.com/updated-image.jpg');
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          imageFile: mockFile,
        );

        // Assert
        verify(() => mockFirebaseStorage.uploadDishImage('restaurant123', 'dish1', mockFile)).called(1);
        expect(dishProvider.dishes[0].imageUrl, 'https://example.com/updated-image.jpg');
      });

      test('should update imageUrl without file upload', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(
          id: 'dish1',
          imageUrl: 'https://example.com/old-image.jpg',
        );

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenAnswer((_) async {});

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          imageUrl: 'https://example.com/new-image.jpg',
        );

        // Assert
        verifyNever(() => mockFirebaseStorage.uploadDishImage(any(), any(), any()));
        expect(dishProvider.dishes[0].imageUrl, 'https://example.com/new-image.jpg');
      });

      test('should set error when dish not found locally', () async {
        // Arrange
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => []);

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'nonexistent',
          name: 'New Name',
        );

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
      });

      test('should set error on updateDish service failure', () async {
        // Arrange
        final mockDish = MockModels.createMockDish(id: 'dish1');

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [mockDish]);
        when(() => mockDishFirestore.updateDish(
              restaurantId: any(named: 'restaurantId'),
              dishId: any(named: 'dishId'),
              updates: any(named: 'updates'),
            )).thenThrow(Exception('Update failed'));

        await dishProvider.fetchDishes('restaurant123');

        // Act
        await dishProvider.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish1',
          name: 'New Name',
        );

        // Assert
        expect(dishProvider.errorMessage, isNotNull);
        expect(dishProvider.isLoading, false);
      });
    });

    group('clearErrors', () {
      test('should clear error message', () async {
        // Arrange - trigger an error
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenThrow(Exception('Some error'));
        await dishProvider.fetchDishes('restaurant123');
        expect(dishProvider.errorMessage, isNotNull);

        // Act
        dishProvider.clearErrors();

        // Assert
        expect(dishProvider.errorMessage, null);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners on state changes', () async {
        var notifyCount = 0;
        dishProvider.addListener(() {
          notifyCount++;
        });

        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenAnswer((_) async => [MockModels.createMockDish()]);

        // Trigger state change
        await dishProvider.fetchDishes('restaurant123');

        // Verify notification
        expect(notifyCount, greaterThan(0));
      });
    });

    group('Error Messages', () {
      test('should provide user-friendly error for permission denied', () async {
        // Arrange
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenThrow(Exception('permission-denied'));

        // Act
        await dishProvider.fetchDishes('restaurant123');

        // Assert
        expect(dishProvider.errorMessage, contains('permission'));
      });

      test('should provide user-friendly error for network failure', () async {
        // Arrange
        when(() => mockDishFirestore.getRestaurantDishes(any()))
            .thenThrow(Exception('network-request-failed'));

        // Act
        await dishProvider.fetchDishes('restaurant123');

        // Assert
        expect(dishProvider.errorMessage, contains('Network'));
      });
    });
  });
}
