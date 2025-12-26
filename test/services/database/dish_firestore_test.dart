import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/services/database/dish_firestore.dart';
import '../../mocks/mock_models.dart';

/// Mock Firestore classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('DishFirestore Service Tests', () {
    late DishFirestore dishFirestore;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockRestaurantCollection;
    late MockDocumentReference mockRestaurantDoc;
    late MockCollectionReference mockDishesCollection;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockRestaurantCollection = MockCollectionReference();
      mockRestaurantDoc = MockDocumentReference();
      mockDishesCollection = MockCollectionReference();

      // IMPORTANT: Setup chain BEFORE creating DishFirestore because
      // the constructor calls _firestore.collection('restaurants')
      when(() => mockFirestore.collection('restaurants'))
          .thenReturn(mockRestaurantCollection);
      when(() => mockRestaurantCollection.doc(any()))
          .thenReturn(mockRestaurantDoc);
      when(() => mockRestaurantDoc.collection('dishes'))
          .thenReturn(mockDishesCollection);

      // Create DishFirestore with mock Firestore (AFTER mocks are set up)
      dishFirestore = DishFirestore(firestore: mockFirestore);
    });

    group('getRestaurantDishes', () {
      test('should return list of dishes when dishes exist', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();
        
        when(() => mockDishesCollection.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        
        when(() => mockDoc1.id).thenReturn('dish1');
        when(() => mockDoc1.data()).thenReturn({
          'name': 'Pizza Margherita',
          'description': 'Classic pizza',
          'price': 12.50,
          'course': 'main',
          'cuisine': 'italian',
          'is_available': true,
          'is_special': false,
        });
        
        when(() => mockDoc2.id).thenReturn('dish2');
        when(() => mockDoc2.data()).thenReturn({
          'name': 'Tiramisu',
          'description': 'Italian dessert',
          'price': 8.00,
          'course': 'dessert',
          'cuisine': 'italian',
          'is_available': true,
          'is_special': false,
        });

        // Act
        final result = await dishFirestore.getRestaurantDishes('restaurant123');

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'dish1');
        expect(result[0].name, 'Pizza Margherita');
        expect(result[1].id, 'dish2');
        expect(result[1].name, 'Tiramisu');
        verify(() => mockDishesCollection.get()).called(1);
      });

      test('should return empty list when no dishes found', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        when(() => mockDishesCollection.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await dishFirestore.getRestaurantDishes('restaurant123');

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when Firestore fails', () async {
        // Arrange
        when(() => mockDishesCollection.get())
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Connection failed'));

        // Act & Assert
        expect(
          () => dishFirestore.getRestaurantDishes('restaurant123'),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('deleteDish', () {
      test('should call delete on correct document reference', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        when(() => mockDishesCollection.doc(any())).thenReturn(mockDishDoc);
        when(() => mockDishDoc.delete()).thenAnswer((_) async {});

        // Act
        await dishFirestore.deleteDish('restaurant123', 'dish456');

        // Assert
        verify(() => mockDishesCollection.doc('dish456')).called(1);
        verify(() => mockDishDoc.delete()).called(1);
      });

      test('should throw exception when dish not found', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        when(() => mockDishesCollection.doc(any())).thenReturn(mockDishDoc);
        when(() => mockDishDoc.delete())
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Document not found'));

        // Act & Assert
        expect(
          () => dishFirestore.deleteDish('restaurant123', 'nonexistent'),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('updateDishAvailability', () {
      test('should update availability to true successfully', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        when(() => mockDishesCollection.doc(any())).thenReturn(mockDishDoc);
        when(() => mockDishDoc.update(any())).thenAnswer((_) async {});

        // Act
        await dishFirestore.updateDishAvailability('restaurant123', 'dish456', true);

        // Assert
        verify(() => mockDishDoc.update({'is_available': true})).called(1);
      });

      test('should update availability to false successfully', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        when(() => mockDishesCollection.doc(any())).thenReturn(mockDishDoc);
        when(() => mockDishDoc.update(any())).thenAnswer((_) async {});

        // Act
        await dishFirestore.updateDishAvailability('restaurant123', 'dish456', false);

        // Assert
        verify(() => mockDishDoc.update({'is_available': false})).called(1);
      });

      test('should throw exception on update failure', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        when(() => mockDishesCollection.doc(any())).thenReturn(mockDishDoc);
        when(() => mockDishDoc.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Update failed'));

        // Act & Assert
        expect(
          () => dishFirestore.updateDishAvailability('restaurant123', 'dish456', true),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('createDish', () {
      test('should create dish and return document ID', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        final mockDish = MockModels.createMockDish(
          name: 'New Dish',
          price: 15.0,
        );
        
        when(() => mockDishesCollection.add(any()))
            .thenAnswer((_) async => mockDishDoc);
        when(() => mockDishDoc.id).thenReturn('newDish123');

        // Act
        final result = await dishFirestore.createDish(
          restaurantId: 'restaurant123',
          dish: mockDish,
        );

        // Assert
        expect(result, 'newDish123');
        verify(() => mockDishesCollection.add(any())).called(1);
      });

      test('should create special dish with user info', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        final mockSpecialDish = MockModels.createMockDish(
          name: 'Special Dish',
          isSpecial: true,
          userUsername: 'chef123',
          minForewarningDays: 2,
        );
        
        when(() => mockDishesCollection.add(any()))
            .thenAnswer((_) async => mockDishDoc);
        when(() => mockDishDoc.id).thenReturn('specialDish123');

        // Act
        final result = await dishFirestore.createDish(
          restaurantId: 'restaurant123',
          dish: mockSpecialDish,
        );

        // Assert
        expect(result, 'specialDish123');
        expect(mockSpecialDish.isSpecial, true);
        expect(mockSpecialDish.userUsername, 'chef123');
      });

      test('should throw exception on creation failure', () async {
        // Arrange
        final mockDish = MockModels.createMockDish();
        when(() => mockDishesCollection.add(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Creation failed'));

        // Act & Assert
        expect(
          () => dishFirestore.createDish(
            restaurantId: 'restaurant123',
            dish: mockDish,
          ),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('updateDish', () {
      test('should update dish with provided fields only', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        when(() => mockDishesCollection.doc(any())).thenReturn(mockDishDoc);
        when(() => mockDishDoc.update(any())).thenAnswer((_) async {});

        final updates = {
          'name': 'Updated Name',
          'price': 20.0,
        };

        // Act
        await dishFirestore.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish456',
          updates: updates,
        );

        // Assert
        verify(() => mockDishDoc.update(updates)).called(1);
      });

      test('should not update when updates map is empty', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        when(() => mockDishesCollection.doc(any())).thenReturn(mockDishDoc);

        // Act
        await dishFirestore.updateDish(
          restaurantId: 'restaurant123',
          dishId: 'dish456',
          updates: {},
        );

        // Assert - update should not be called
        verifyNever(() => mockDishDoc.update(any()));
      });

      test('should throw exception on update failure', () async {
        // Arrange
        final mockDishDoc = MockDocumentReference();
        when(() => mockDishesCollection.doc(any())).thenReturn(mockDishDoc);
        when(() => mockDishDoc.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Update failed'));

        // Act & Assert
        expect(
          () => dishFirestore.updateDish(
            restaurantId: 'restaurant123',
            dishId: 'dish456',
            updates: {'name': 'New Name'},
          ),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('Mock Models Integration', () {
      test('createMockDish should create valid dish instance', () {
        final mockDish = MockModels.createMockDish(
          id: 'test123',
          name: 'Test Dish',
          price: 10.0,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
        );

        expect(mockDish.id, 'test123');
        expect(mockDish.name, 'Test Dish');
        expect(mockDish.price, 10.0);
        expect(mockDish.course, Course.mainDish);
        expect(mockDish.cuisine, Cuisine.italian);
      });

      test('createMockDish should handle special dish fields', () {
        final specialDish = MockModels.createMockDish(
          isSpecial: true,
          userUsername: 'specialchef',
          minForewarningDays: 3,
        );

        expect(specialDish.isSpecial, true);
        expect(specialDish.userUsername, 'specialchef');
        expect(specialDish.minForewarningDays, 3);
      });
    });
  });
}
