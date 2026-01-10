import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/services/database/dish_firestore.dart';
import '../../mocks/mock_models.dart';

/// Mock Firestore classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockWriteBatch extends Mock implements WriteBatch {}

/// Fake classes for fallback values
class FakeDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDocumentReference());
    registerFallbackValue(<String, dynamic>{});
  });
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

    group('getSpecialDishesByUsername', () {
      test('should return special dishes for a given username across restaurants', () async {
        // Arrange
        final mockRestaurantsSnapshot = MockQuerySnapshot();
        final mockRestaurantDoc1 = MockQueryDocumentSnapshot();
        final mockRestaurantDoc2 = MockQueryDocumentSnapshot();

        final mockDishesSnapshot1 = MockQuerySnapshot();
        final mockDishDoc1 = MockQueryDocumentSnapshot();

        final mockDishesSnapshot2 = MockQuerySnapshot();
        final mockDishDoc2 = MockQueryDocumentSnapshot();

        final mockDishesCollection1 = MockCollectionReference();
        final mockDishesCollection2 = MockCollectionReference();
        final mockRestaurantDoc1Ref = MockDocumentReference();
        final mockRestaurantDoc2Ref = MockDocumentReference();

        // Setup restaurant collection
        when(() => mockRestaurantCollection.get())
            .thenAnswer((_) async => mockRestaurantsSnapshot);
        when(() => mockRestaurantsSnapshot.docs)
            .thenReturn([mockRestaurantDoc1, mockRestaurantDoc2]);

        when(() => mockRestaurantDoc1.id).thenReturn('restaurant1');
        when(() => mockRestaurantDoc2.id).thenReturn('restaurant2');

        // Setup dishes queries
        when(() => mockRestaurantCollection.doc('restaurant1'))
            .thenReturn(mockRestaurantDoc1Ref);
        when(() => mockRestaurantCollection.doc('restaurant2'))
            .thenReturn(mockRestaurantDoc2Ref);

        when(() => mockRestaurantDoc1Ref.collection('dishes'))
            .thenReturn(mockDishesCollection1);
        when(() => mockRestaurantDoc2Ref.collection('dishes'))
            .thenReturn(mockDishesCollection2);

        when(() => mockDishesCollection1.where('is_special', isEqualTo: true))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.where('user_username', isEqualTo: 'chef123'))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.get())
            .thenAnswer((_) async => mockDishesSnapshot1);

        when(() => mockDishesCollection2.where('is_special', isEqualTo: true))
            .thenReturn(mockDishesCollection2);
        when(() => mockDishesCollection2.where('user_username', isEqualTo: 'chef123'))
            .thenReturn(mockDishesCollection2);
        when(() => mockDishesCollection2.get())
            .thenAnswer((_) async => mockDishesSnapshot2);

        when(() => mockDishesSnapshot1.docs).thenReturn([mockDishDoc1]);
        when(() => mockDishesSnapshot2.docs).thenReturn([mockDishDoc2]);

        when(() => mockDishDoc1.id).thenReturn('dish1');
        when(() => mockDishDoc1.data()).thenReturn({
          'name': 'Special Pasta',
          'description': 'Chef special',
          'price': 25.0,
          'course': 'main',
          'cuisine': 'italian',
          'is_available': true,
          'is_special': true,
          'user_username': 'chef123',
          'min_forewarning_days': 2,
        });

        when(() => mockDishDoc2.id).thenReturn('dish2');
        when(() => mockDishDoc2.data()).thenReturn({
          'name': 'Special Pizza',
          'description': 'Chef special pizza',
          'price': 30.0,
          'course': 'main',
          'cuisine': 'italian',
          'is_available': true,
          'is_special': true,
          'user_username': 'chef123',
          'min_forewarning_days': 3,
        });

        // Act
        final result = await dishFirestore.getSpecialDishesByUsername('chef123');

        // Assert
        expect(result.length, 2);
        expect(result[0]['restaurantId'], 'restaurant1');
        expect(result[0]['dishId'], 'dish1');
        expect(result[0]['dish'].name, 'Special Pasta');
        expect(result[1]['restaurantId'], 'restaurant2');
        expect(result[1]['dishId'], 'dish2');
        expect(result[1]['dish'].name, 'Special Pizza');
      });

      test('should return empty list when no special dishes found for username', () async {
        // Arrange
        final mockRestaurantsSnapshot = MockQuerySnapshot();
        final mockRestaurantDoc = MockQueryDocumentSnapshot();
        final mockDishesSnapshot = MockQuerySnapshot();
        final mockDishesCollection1 = MockCollectionReference();
        final mockRestaurantDocRef = MockDocumentReference();

        when(() => mockRestaurantCollection.get())
            .thenAnswer((_) async => mockRestaurantsSnapshot);
        when(() => mockRestaurantsSnapshot.docs)
            .thenReturn([mockRestaurantDoc]);

        when(() => mockRestaurantDoc.id).thenReturn('restaurant1');

        when(() => mockRestaurantCollection.doc('restaurant1'))
            .thenReturn(mockRestaurantDocRef);
        when(() => mockRestaurantDocRef.collection('dishes'))
            .thenReturn(mockDishesCollection1);

        when(() => mockDishesCollection1.where('is_special', isEqualTo: true))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.where('user_username', isEqualTo: 'nonexistent'))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.get())
            .thenAnswer((_) async => mockDishesSnapshot);
        when(() => mockDishesSnapshot.docs).thenReturn([]);

        // Act
        final result = await dishFirestore.getSpecialDishesByUsername('nonexistent');

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when Firestore fails during query', () async {
        // Arrange
        when(() => mockRestaurantCollection.get())
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Query failed'));

        // Act & Assert
        expect(
          () => dishFirestore.getSpecialDishesByUsername('chef123'),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('updateUsernameForSpecialDishes', () {
      test('should update username for all special dishes in batch', () async {
        // Arrange
        final mockRestaurantsSnapshot = MockQuerySnapshot();
        final mockRestaurantDoc = MockQueryDocumentSnapshot();
        final mockDishesSnapshot = MockQuerySnapshot();
        final mockDishDoc = MockQueryDocumentSnapshot();
        final mockDishesCollection1 = MockCollectionReference();
        final mockRestaurantDocRef = MockDocumentReference();
        final mockDishDocRef = MockDocumentReference();
        final mockWriteBatch = MockWriteBatch();

        // Setup for getSpecialDishesByUsername call
        when(() => mockRestaurantCollection.get())
            .thenAnswer((_) async => mockRestaurantsSnapshot);
        when(() => mockRestaurantsSnapshot.docs)
            .thenReturn([mockRestaurantDoc]);

        when(() => mockRestaurantDoc.id).thenReturn('restaurant1');

        when(() => mockRestaurantCollection.doc('restaurant1'))
            .thenReturn(mockRestaurantDocRef);
        when(() => mockRestaurantDocRef.collection('dishes'))
            .thenReturn(mockDishesCollection1);

        when(() => mockDishesCollection1.where('is_special', isEqualTo: true))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.where('user_username', isEqualTo: 'oldchef'))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.get())
            .thenAnswer((_) async => mockDishesSnapshot);

        when(() => mockDishesSnapshot.docs).thenReturn([mockDishDoc]);

        when(() => mockDishDoc.id).thenReturn('dish1');
        when(() => mockDishDoc.data()).thenReturn({
          'name': 'Special Dish',
          'description': 'Description',
          'price': 20.0,
          'course': 'main',
          'cuisine': 'italian',
          'is_available': true,
          'is_special': true,
          'user_username': 'oldchef',
          'min_forewarning_days': 2,
        });

        when(() => mockDishesCollection1.doc('dish1'))
            .thenReturn(mockDishDocRef);

        // Setup batch
        when(() => mockFirestore.batch()).thenReturn(mockWriteBatch);
        when(() => mockWriteBatch.update(any(), any())).thenReturn(null);
        when(() => mockWriteBatch.commit()).thenAnswer((_) async => []);

        // Act
        await dishFirestore.updateUsernameForSpecialDishes(
          oldUsername: 'oldchef',
          newUsername: 'newchef',
        );

        // Assert
        verify(() => mockFirestore.batch()).called(1);
        verify(() => mockWriteBatch.update(
          mockDishDocRef,
          {'user_username': 'newchef'},
        )).called(1);
        verify(() => mockWriteBatch.commit()).called(1);
      });

      test('should handle no special dishes to update', () async {
        // Arrange
        final mockRestaurantsSnapshot = MockQuerySnapshot();
        final mockRestaurantDoc = MockQueryDocumentSnapshot();
        final mockDishesSnapshot = MockQuerySnapshot();
        final mockDishesCollection1 = MockCollectionReference();
        final mockRestaurantDocRef = MockDocumentReference();
        final mockWriteBatch = MockWriteBatch();

        when(() => mockRestaurantCollection.get())
            .thenAnswer((_) async => mockRestaurantsSnapshot);
        when(() => mockRestaurantsSnapshot.docs)
            .thenReturn([mockRestaurantDoc]);

        when(() => mockRestaurantDoc.id).thenReturn('restaurant1');

        when(() => mockRestaurantCollection.doc('restaurant1'))
            .thenReturn(mockRestaurantDocRef);
        when(() => mockRestaurantDocRef.collection('dishes'))
            .thenReturn(mockDishesCollection1);

        when(() => mockDishesCollection1.where('is_special', isEqualTo: true))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.where('user_username', isEqualTo: 'oldchef'))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.get())
            .thenAnswer((_) async => mockDishesSnapshot);

        when(() => mockDishesSnapshot.docs).thenReturn([]);

        when(() => mockFirestore.batch()).thenReturn(mockWriteBatch);
        when(() => mockWriteBatch.commit()).thenAnswer((_) async => []);

        // Act
        await dishFirestore.updateUsernameForSpecialDishes(
          oldUsername: 'oldchef',
          newUsername: 'newchef',
        );

        // Assert
        verify(() => mockFirestore.batch()).called(1);
        verify(() => mockWriteBatch.commit()).called(1);
        verifyNever(() => mockWriteBatch.update(any(), any()));
      });

      test('should throw exception when batch commit fails', () async {
        // Arrange
        final mockRestaurantsSnapshot = MockQuerySnapshot();
        final mockRestaurantDoc = MockQueryDocumentSnapshot();
        final mockDishesSnapshot = MockQuerySnapshot();
        final mockDishDoc = MockQueryDocumentSnapshot();
        final mockDishesCollection1 = MockCollectionReference();
        final mockRestaurantDocRef = MockDocumentReference();
        final mockDishDocRef = MockDocumentReference();
        final mockWriteBatch = MockWriteBatch();

        when(() => mockRestaurantCollection.get())
            .thenAnswer((_) async => mockRestaurantsSnapshot);
        when(() => mockRestaurantsSnapshot.docs)
            .thenReturn([mockRestaurantDoc]);

        when(() => mockRestaurantDoc.id).thenReturn('restaurant1');

        when(() => mockRestaurantCollection.doc('restaurant1'))
            .thenReturn(mockRestaurantDocRef);
        when(() => mockRestaurantDocRef.collection('dishes'))
            .thenReturn(mockDishesCollection1);

        when(() => mockDishesCollection1.where('is_special', isEqualTo: true))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.where('user_username', isEqualTo: 'oldchef'))
            .thenReturn(mockDishesCollection1);
        when(() => mockDishesCollection1.get())
            .thenAnswer((_) async => mockDishesSnapshot);

        when(() => mockDishesSnapshot.docs).thenReturn([mockDishDoc]);

        when(() => mockDishDoc.id).thenReturn('dish1');
        when(() => mockDishDoc.data()).thenReturn({
          'name': 'Special Dish',
          'description': 'Description',
          'price': 20.0,
          'course': 'main',
          'cuisine': 'italian',
          'is_available': true,
          'is_special': true,
          'user_username': 'oldchef',
          'min_forewarning_days': 2,
        });

        when(() => mockDishesCollection1.doc('dish1'))
            .thenReturn(mockDishDocRef);

        when(() => mockFirestore.batch()).thenReturn(mockWriteBatch);
        when(() => mockWriteBatch.update(any(), any())).thenReturn(null);
        when(() => mockWriteBatch.commit())
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Batch commit failed'));

        // Act & Assert
        expect(
          () => dishFirestore.updateUsernameForSpecialDishes(
            oldUsername: 'oldchef',
            newUsername: 'newchef',
          ),
          throwsA(isA<FirebaseException>()),
        );
      });
    });
  });
}
