import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/dish.dart';

// Mock class for DocumentSnapshot
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('Dish Model Tests', () {
    group('Constructor', () {
      test('should create regular Dish with all required fields', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Pizza Margherita',
          price: 12.50,
          isSpecial: false,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
        );

        expect(dish.id, 'dish123');
        expect(dish.name, 'Pizza Margherita');
        expect(dish.price, 12.50);
        expect(dish.isSpecial, false);
        expect(dish.course, Course.mainDish);
        expect(dish.cuisine, Cuisine.italian);
        expect(dish.description, '');
        expect(dish.minForewarningDays, 0);
        expect(dish.imageUrl, '');
      });

      test('should create regular Dish with all optional fields', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Pizza Margherita',
          description: 'Classic Italian pizza',
          price: 12.50,
          isSpecial: false,
          isAvailable: true,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          minForewarningDays: 2,
          imageUrl: 'https://example.com/pizza.jpg',
        );

        expect(dish.description, 'Classic Italian pizza');
        expect(dish.isAvailable, true);
        expect(dish.minForewarningDays, 2);
        expect(dish.imageUrl, 'https://example.com/pizza.jpg');
      });

      test('should create special Dish with user attributes', () {
        final creationTime = DateTime(2025, 12, 27, 10, 30);
        final dish = Dish(
          id: 'dish123',
          name: 'Special Request',
          price: 25.00,
          isSpecial: true,
          course: Course.other,
          cuisine: Cuisine.other,
          userUsername: 'chef_mario',
          creationTime: creationTime,
        );

        expect(dish.isSpecial, true);
        expect(dish.userUsername, 'chef_mario');
        expect(dish.creationTime, creationTime);
      });

      test('should default description to empty string', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Test Dish',
          price: 10.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        expect(dish.description, '');
      });

      test('should default minForewarningDays to 0', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Test Dish',
          price: 10.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        expect(dish.minForewarningDays, 0);
      });

      test('should default imageUrl to empty string', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Test Dish',
          price: 10.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        expect(dish.imageUrl, '');
      });

      test('should handle null description', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Test Dish',
          description: null,
          price: 10.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        expect(dish.description, isNull);
      });

      test('should handle empty string values', () {
        final dish = Dish(
          id: '',
          name: '',
          description: '',
          price: 0.0,
          isSpecial: false,
          course: Course.other,
          cuisine: Cuisine.other,
        );

        expect(dish.id, '');
        expect(dish.name, '');
        expect(dish.description, '');
      });

      test('should handle special characters in name and description', () {
        final dish = Dish(
          id: 'dish123',
          name: "Giuseppe's Special Pizza & Pasta 🍕",
          description: 'Made with 100% organic ingredients',
          price: 15.00,
          isSpecial: false,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
        );

        expect(dish.name, "Giuseppe's Special Pizza & Pasta 🍕");
        expect(dish.description, 'Made with 100% organic ingredients');
      });

      test('should handle high minForewarningDays value', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Special Order',
          price: 50.0,
          isSpecial: false,
          course: Course.mainDish,
          cuisine: Cuisine.french,
          minForewarningDays: 30,
        );

        expect(dish.minForewarningDays, 30);
      });

      test('should handle decimal price values', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Precise Price Dish',
          price: 12.99,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        expect(dish.price, 12.99);
      });
    });

    group('fromFirestore - Regular Dish', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should create regular Dish from Firestore document with all fields', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Pizza Margherita',
          'description': 'Classic pizza',
          'price': 12.50,
          'is_special': false,
          'is_available': true,
          'course': 'mainDish',
          'cuisine': 'italian',
          'min_forewarning_days': 1,
          'image': 'https://example.com/pizza.jpg',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.id, 'dish123');
        expect(dish.name, 'Pizza Margherita');
        expect(dish.description, 'Classic pizza');
        expect(dish.price, 12.50);
        expect(dish.isSpecial, false);
        expect(dish.isAvailable, true);
        expect(dish.course, Course.mainDish);
        expect(dish.cuisine, Cuisine.italian);
        expect(dish.minForewarningDays, 1);
        expect(dish.imageUrl, 'https://example.com/pizza.jpg');
      });

      test('should handle missing name with empty string default', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.name, '');
      });

      test('should handle null name with empty string default', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': null,
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.name, '');
      });

      test('should handle missing description with empty string default', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'price': 10.0,
          'is_special': false,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.description, '');
      });

      test('should handle missing price with 0.0 default', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'is_special': false,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.price, 0.0);
      });

      test('should convert integer price to double', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'price': 15,
          'is_special': false,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.price, 15.0);
        expect(dish.price, isA<double>());
      });

      test('should handle missing is_special with false default', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'price': 10.0,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.isSpecial, false);
      });

      test('should handle missing min_forewarning_days with 0 default', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'price': 10.0,
          'is_special': false,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.minForewarningDays, 0);
      });

      test('should parse is_available for regular dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'price': 10.0,
          'is_special': false,
          'is_available': true,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.isAvailable, true);
      });

      test('should parse is_available as false for regular dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'price': 10.0,
          'is_special': false,
          'is_available': false,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.isAvailable, false);
      });

      test('should parse isAvailable for special dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Special Dish',
          'price': 20.0,
          'is_special': true,
          'is_available': true,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.isAvailable, true);
      });

      test('should parse image for regular dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'price': 10.0,
          'is_special': false,
          'image': 'https://example.com/dish.jpg',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.imageUrl, 'https://example.com/dish.jpg');
      });

      test('should parse imageUrl for special dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Special Dish',
          'price': 20.0,
          'is_special': true,
          'image': 'https://example.com/special.jpg',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.imageUrl, 'https://example.com/special.jpg');
      });
    });

    group('fromFirestore - Course Enum Parsing', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should parse appetizer course', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.appetizer);
      });

      test('should parse pastaDish course', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'pastaDish',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.pastaDish);
      });

      test('should parse mainDish course', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'mainDish',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.mainDish);
      });

      test('should parse side course', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'side',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.side);
      });

      test('should parse dessert course', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'dessert',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.dessert);
      });

      test('should parse drink course', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'drink',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.drink);
      });

      test('should parse other course', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'other',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.other);
      });

      test('should default to Course.other for unknown course string', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'unknownCourse',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.other);
      });

      test('should default to Course.other when course is null', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': null,
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.other);
      });

      test('should default to Course.other when course is missing', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.other);
      });

      test('should parse course for special dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': true,
          'course': 'mainDish',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.course, Course.mainDish);
      });
    });

    group('fromFirestore - Cuisine Enum Parsing', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should parse italian cuisine', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.italian);
      });

      test('should parse chinese cuisine', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'chinese',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.chinese);
      });

      test('should parse japanese cuisine', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'japanese',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.japanese);
      });

      test('should parse indian cuisine', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'indian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.indian);
      });

      test('should parse french cuisine', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'french',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.french);
      });

      test('should parse mexican cuisine', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'mexican',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.mexican);
      });

      test('should parse american cuisine', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'american',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.american);
      });

      test('should parse other cuisine', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'other',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.other);
      });

      test('should default to Cuisine.other for unknown cuisine string', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': 'unknownCuisine',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.other);
      });

      test('should default to Cuisine.other when cuisine is null', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
          'cuisine': null,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.other);
      });

      test('should default to Cuisine.other when cuisine is missing', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': false,
          'course': 'appetizer',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.other);
      });

      test('should parse cuisine for special dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test',
          'price': 10.0,
          'is_special': true,
          'course': 'appetizer',
          'cuisine': 'italian',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.cuisine, Cuisine.italian);
      });
    });

    group('fromFirestore - Special Dish', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should create special Dish from Firestore document with all fields', () {
        final creationTime = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Special Request Dish',
          'description': 'Custom made dish',
          'price': 50.00,
          'is_special': true,
          'user_username': 'chef_mario',
          'creation_time': creationTime,
          'min_forewarning_days': 3,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.id, 'dish123');
        expect(dish.name, 'Special Request Dish');
        expect(dish.description, 'Custom made dish');
        expect(dish.price, 50.00);
        expect(dish.isSpecial, true);
        expect(dish.userUsername, 'chef_mario');
        expect(dish.creationTime, creationTime.toDate());
        expect(dish.minForewarningDays, 3);
        expect(dish.isAvailable, isNull);
        expect(dish.imageUrl, isNull);
        expect(dish.course, Course.other);
        expect(dish.cuisine, Cuisine.other);
      });

      test('should set userUsername to null for regular dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Regular Dish',
          'price': 15.0,
          'is_special': false,
          'user_username': 'should_be_ignored',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.userUsername, isNull);
      });

      test('should set creationTime to null for regular dish', () {
        final creationTime = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Regular Dish',
          'price': 15.0,
          'is_special': false,
          'creation_time': creationTime, // Should be ignored
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.creationTime, isNull);
      });

      test('should handle missing creation_time for special dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Special Dish',
          'price': 25.0,
          'is_special': true,
          'user_username': 'chef',
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.creationTime, isNull);
      });

      test('should handle null creation_time for special dish', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Special Dish',
          'price': 25.0,
          'is_special': true,
          'user_username': 'chef',
          'creation_time': null,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.creationTime, isNull);
      });

      test('should handle empty Firestore document data', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({});

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.id, 'dish123');
        expect(dish.name, '');
        expect(dish.price, 0.0);
        expect(dish.isSpecial, false);
        expect(dish.course, Course.other);
        expect(dish.cuisine, Cuisine.other);
      });

      test('should handle Firestore document with extra fields', () {
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Test Dish',
          'price': 10.0,
          'is_special': false,
          'extra_field': 'should be ignored',
          'another_field': 123,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.id, 'dish123');
        expect(dish.name, 'Test Dish');
      });
    });

    group('toFirestore - Regular Dish', () {
      test('should convert regular Dish to Firestore map with all fields', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Pizza Margherita',
          description: 'Classic pizza',
          price: 12.50,
          isSpecial: false,
          isAvailable: true,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          minForewarningDays: 1,
          imageUrl: 'https://example.com/pizza.jpg',
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap['name'], 'Pizza Margherita');
        expect(firestoreMap['description'], 'Classic pizza');
        expect(firestoreMap['price'], 12.50);
        expect(firestoreMap['is_special'], false);
        expect(firestoreMap['is_available'], true);
        expect(firestoreMap['course'], 'mainDish');
        expect(firestoreMap['cuisine'], 'italian');
        expect(firestoreMap['min_forewarning_days'], 1);
        expect(firestoreMap['image'], 'https://example.com/pizza.jpg');
      });

      test('should not include id in Firestore map', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Test',
          price: 10.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap.containsKey('id'), isFalse);
      });

      test('should include is_available for regular dish', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Test',
          price: 10.0,
          isSpecial: false,
          isAvailable: true,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap.containsKey('is_available'), isTrue);
        expect(firestoreMap['is_available'], true);
      });

      test('should not include user_username for regular dish', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Test',
          price: 10.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap.containsKey('user_username'), isFalse);
      });

      test('should not include creation_time for regular dish', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Test',
          price: 10.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap.containsKey('creation_time'), isFalse);
      });

      test('should correctly convert Course enum to string', () {
        final courses = Course.values;
        
        for (final course in courses) {
          final dish = Dish(
            id: 'dish123',
            name: 'Test',
            price: 10.0,
            isSpecial: false,
            course: course,
            cuisine: Cuisine.italian,
          );

          final firestoreMap = dish.toFirestore();

          expect(firestoreMap['course'], course.toString().split('.').last);
        }
      });

      test('should correctly convert Cuisine enum to string', () {
        final cuisines = Cuisine.values;
        
        for (final cuisine in cuisines) {
          final dish = Dish(
            id: 'dish123',
            name: 'Test',
            price: 10.0,
            isSpecial: false,
            course: Course.appetizer,
            cuisine: cuisine,
          );

          final firestoreMap = dish.toFirestore();

          expect(firestoreMap['cuisine'], cuisine.toString().split('.').last);
        }
      });
    });

    group('toFirestore - Special Dish', () {
      test('should convert special Dish to Firestore map with all fields', () {
        final creationTime = DateTime(2025, 12, 27, 14, 30);
        final dish = Dish(
          id: 'dish123',
          name: 'Special Request',
          description: 'Custom dish',
          price: 50.00,
          isSpecial: true,
          course: Course.other,
          cuisine: Cuisine.other,
          userUsername: 'chef_mario',
          creationTime: creationTime,
          minForewarningDays: 3,
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap['name'], 'Special Request');
        expect(firestoreMap['description'], 'Custom dish');
        expect(firestoreMap['price'], 50.00);
        expect(firestoreMap['is_special'], true);
        expect(firestoreMap['user_username'], 'chef_mario');
        expect(firestoreMap['creation_time'], isA<Timestamp>());
        expect((firestoreMap['creation_time'] as Timestamp).toDate(), creationTime);
        expect(firestoreMap['min_forewarning_days'], 3);
      });

      test('should include is_available for special dish when set', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Special',
          price: 25.0,
          isSpecial: true,
          isAvailable: false,
          course: Course.other,
          cuisine: Cuisine.other,
          userUsername: 'chef',
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap['is_available'], false);
      });

      test('should include user_username for special dish', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Special',
          price: 25.0,
          isSpecial: true,
          course: Course.other,
          cuisine: Cuisine.other,
          userUsername: 'chef_mario',
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap.containsKey('user_username'), isTrue);
        expect(firestoreMap['user_username'], 'chef_mario');
      });

      test('should include creation_time for special dish when not null', () {
        final creationTime = DateTime(2025, 12, 27, 10, 0);
        final dish = Dish(
          id: 'dish123',
          name: 'Special',
          price: 25.0,
          isSpecial: true,
          course: Course.other,
          cuisine: Cuisine.other,
          userUsername: 'chef',
          creationTime: creationTime,
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap.containsKey('creation_time'), isTrue);
      });

      test('should not include creation_time for special dish when null', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Special',
          price: 25.0,
          isSpecial: true,
          course: Course.other,
          cuisine: Cuisine.other,
          userUsername: 'chef',
          creationTime: null,
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap.containsKey('creation_time'), isFalse);
      });

      test('should handle empty strings', () {
        final dish = Dish(
          id: '',
          name: '',
          description: '',
          price: 0.0,
          isSpecial: false,
          course: Course.other,
          cuisine: Cuisine.other,
          imageUrl: '',
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap['name'], '');
        expect(firestoreMap['description'], '');
        expect(firestoreMap['image'], '');
      });
    });

    group('copyWith', () {
      late Dish baseDish;

      setUp(() {
        baseDish = Dish(
          id: 'dish123',
          name: 'Original Dish',
          description: 'Original description',
          price: 15.0,
          isSpecial: false,
          isAvailable: true,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          minForewarningDays: 1,
          imageUrl: 'https://example.com/original.jpg',
        );
      });

      test('should create copy with no changes when no parameters provided', () {
        final copy = baseDish.copyWith();

        expect(copy.id, baseDish.id);
        expect(copy.name, baseDish.name);
        expect(copy.description, baseDish.description);
        expect(copy.price, baseDish.price);
        expect(copy.isSpecial, baseDish.isSpecial);
        expect(copy.isAvailable, baseDish.isAvailable);
        expect(copy.course, baseDish.course);
        expect(copy.cuisine, baseDish.cuisine);
        expect(copy.minForewarningDays, baseDish.minForewarningDays);
        expect(copy.imageUrl, baseDish.imageUrl);
      });

      test('should update id when provided', () {
        final copy = baseDish.copyWith(id: 'newId');

        expect(copy.id, 'newId');
        expect(copy.name, baseDish.name);
      });

      test('should update name when provided', () {
        final copy = baseDish.copyWith(name: 'New Name');

        expect(copy.name, 'New Name');
      });

      test('should update description when provided', () {
        final copy = baseDish.copyWith(description: 'New description');

        expect(copy.description, 'New description');
      });

      test('should update price when provided', () {
        final copy = baseDish.copyWith(price: 25.0);

        expect(copy.price, 25.0);
      });

      test('should update isSpecial when provided', () {
        final copy = baseDish.copyWith(isSpecial: true);

        expect(copy.isSpecial, true);
      });

      test('should update isAvailable when provided', () {
        final copy = baseDish.copyWith(isAvailable: false);

        expect(copy.isAvailable, false);
      });

      test('should update course when provided', () {
        final copy = baseDish.copyWith(course: Course.dessert);

        expect(copy.course, Course.dessert);
      });

      test('should update cuisine when provided', () {
        final copy = baseDish.copyWith(cuisine: Cuisine.japanese);

        expect(copy.cuisine, Cuisine.japanese);
      });

      test('should update minForewarningDays when provided', () {
        final copy = baseDish.copyWith(minForewarningDays: 5);

        expect(copy.minForewarningDays, 5);
      });

      test('should update imageUrl when provided', () {
        final copy = baseDish.copyWith(imageUrl: 'https://new.com/image.jpg');

        expect(copy.imageUrl, 'https://new.com/image.jpg');
      });

      test('should update userUsername when provided', () {
        final copy = baseDish.copyWith(userUsername: 'new_chef');

        expect(copy.userUsername, 'new_chef');
      });

      test('should update creationTime when provided', () {
        final newTime = DateTime(2025, 12, 28, 10, 0);
        final copy = baseDish.copyWith(creationTime: newTime);

        expect(copy.creationTime, newTime);
      });

      test('should update multiple fields at once', () {
        final copy = baseDish.copyWith(
          name: 'Updated Dish',
          price: 20.0,
          isAvailable: false,
          course: Course.appetizer,
        );

        expect(copy.name, 'Updated Dish');
        expect(copy.price, 20.0);
        expect(copy.isAvailable, false);
        expect(copy.course, Course.appetizer);
        expect(copy.id, baseDish.id);
        expect(copy.cuisine, baseDish.cuisine);
      });

      test('should not affect original dish when copying', () {
        final copy = baseDish.copyWith(name: 'Modified Name');

        expect(baseDish.name, 'Original Dish');
        expect(copy.name, 'Modified Name');
      });

      test('should convert regular dish to special dish', () {
        final copy = baseDish.copyWith(
          isSpecial: true,
          userUsername: 'chef_mario',
          creationTime: DateTime.now(),
        );

        expect(copy.isSpecial, true);
        expect(copy.userUsername, 'chef_mario');
        expect(copy.creationTime, isNotNull);
      });
    });

    group('Course Enum', () {
      test('should have appetizer value', () {
        expect(Course.appetizer, isNotNull);
        expect(Course.values, contains(Course.appetizer));
      });

      test('should have pastaDish value', () {
        expect(Course.pastaDish, isNotNull);
        expect(Course.values, contains(Course.pastaDish));
      });

      test('should have mainDish value', () {
        expect(Course.mainDish, isNotNull);
        expect(Course.values, contains(Course.mainDish));
      });

      test('should have side value', () {
        expect(Course.side, isNotNull);
        expect(Course.values, contains(Course.side));
      });

      test('should have dessert value', () {
        expect(Course.dessert, isNotNull);
        expect(Course.values, contains(Course.dessert));
      });

      test('should have drink value', () {
        expect(Course.drink, isNotNull);
        expect(Course.values, contains(Course.drink));
      });

      test('should have other value', () {
        expect(Course.other, isNotNull);
        expect(Course.values, contains(Course.other));
      });

      test('should have exactly 7 values', () {
        expect(Course.values.length, 7);
      });
    });

    group('Cuisine Enum', () {
      test('should have italian value', () {
        expect(Cuisine.italian, isNotNull);
        expect(Cuisine.values, contains(Cuisine.italian));
      });

      test('should have chinese value', () {
        expect(Cuisine.chinese, isNotNull);
        expect(Cuisine.values, contains(Cuisine.chinese));
      });

      test('should have japanese value', () {
        expect(Cuisine.japanese, isNotNull);
        expect(Cuisine.values, contains(Cuisine.japanese));
      });

      test('should have indian value', () {
        expect(Cuisine.indian, isNotNull);
        expect(Cuisine.values, contains(Cuisine.indian));
      });

      test('should have french value', () {
        expect(Cuisine.french, isNotNull);
        expect(Cuisine.values, contains(Cuisine.french));
      });

      test('should have mexican value', () {
        expect(Cuisine.mexican, isNotNull);
        expect(Cuisine.values, contains(Cuisine.mexican));
      });

      test('should have american value', () {
        expect(Cuisine.american, isNotNull);
        expect(Cuisine.values, contains(Cuisine.american));
      });

      test('should have other value', () {
        expect(Cuisine.other, isNotNull);
        expect(Cuisine.values, contains(Cuisine.other));
      });

      test('should have exactly 8 values', () {
        expect(Cuisine.values.length, 8);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity for regular dish through toFirestore and fromFirestore', () {
        final originalDish = Dish(
          id: 'dish123',
          name: 'Pizza Margherita',
          description: 'Classic Italian pizza',
          price: 12.50,
          isSpecial: false,
          isAvailable: true,
          course: Course.mainDish,
          cuisine: Cuisine.italian,
          minForewarningDays: 1,
          imageUrl: 'https://example.com/pizza.jpg',
        );

        final firestoreData = originalDish.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredDish = Dish.fromFirestore(mockDoc);

        expect(restoredDish.id, originalDish.id);
        expect(restoredDish.name, originalDish.name);
        expect(restoredDish.description, originalDish.description);
        expect(restoredDish.price, originalDish.price);
        expect(restoredDish.isSpecial, originalDish.isSpecial);
        expect(restoredDish.isAvailable, originalDish.isAvailable);
        expect(restoredDish.course, originalDish.course);
        expect(restoredDish.cuisine, originalDish.cuisine);
        expect(restoredDish.minForewarningDays, originalDish.minForewarningDays);
        expect(restoredDish.imageUrl, originalDish.imageUrl);
      });

      test('should maintain data integrity for special dish through toFirestore and fromFirestore', () {
        final creationTime = DateTime(2025, 12, 27, 14, 30);
        final originalDish = Dish(
          id: 'dish456',
          name: 'Special Request',
          description: 'Custom made dish',
          price: 50.00,
          isSpecial: true,
          course: Course.other,
          cuisine: Cuisine.other,
          userUsername: 'chef_mario',
          creationTime: creationTime,
          minForewarningDays: 3,
        );

        final firestoreData = originalDish.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('dish456');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredDish = Dish.fromFirestore(mockDoc);

        expect(restoredDish.id, originalDish.id);
        expect(restoredDish.name, originalDish.name);
        expect(restoredDish.description, originalDish.description);
        expect(restoredDish.price, originalDish.price);
        expect(restoredDish.isSpecial, originalDish.isSpecial);
        expect(restoredDish.userUsername, originalDish.userUsername);
        expect(restoredDish.creationTime, originalDish.creationTime);
        expect(restoredDish.minForewarningDays, originalDish.minForewarningDays);
        expect(restoredDish.isAvailable, originalDish.isAvailable);
        expect(restoredDish.imageUrl, originalDish.imageUrl);
      });

      test('should handle round-trip for all course types', () {
        for (final course in Course.values) {
          final originalDish = Dish(
            id: 'dish_${course.toString()}',
            name: 'Test ${course.toString()}',
            price: 10.0,
            isSpecial: false,
            course: course,
            cuisine: Cuisine.italian,
          );

          final firestoreData = originalDish.toFirestore();

          final mockDoc = MockDocumentSnapshot();
          when(() => mockDoc.id).thenReturn('dish_${course.toString()}');
          when(() => mockDoc.data()).thenReturn(firestoreData);

          final restoredDish = Dish.fromFirestore(mockDoc);

          expect(restoredDish.course, course);
        }
      });

      test('should handle round-trip for all cuisine types', () {
        for (final cuisine in Cuisine.values) {
          final originalDish = Dish(
            id: 'dish_${cuisine.toString()}',
            name: 'Test ${cuisine.toString()}',
            price: 10.0,
            isSpecial: false,
            course: Course.appetizer,
            cuisine: cuisine,
          );

          final firestoreData = originalDish.toFirestore();

          final mockDoc = MockDocumentSnapshot();
          when(() => mockDoc.id).thenReturn('dish_${cuisine.toString()}');
          when(() => mockDoc.data()).thenReturn(firestoreData);

          final restoredDish = Dish.fromFirestore(mockDoc);

          expect(restoredDish.cuisine, cuisine);
        }
      });
    });

    group('Edge Cases', () {
      test('should handle very high price', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Expensive Dish',
          price: 9999.99,
          isSpecial: false,
          course: Course.mainDish,
          cuisine: Cuisine.french,
        );

        expect(dish.price, 9999.99);
      });

      test('should handle zero price', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Free Dish',
          price: 0.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        expect(dish.price, 0.0);
      });

      test('should handle unicode in name and description', () {
        final dish = Dish(
          id: 'dish123',
          name: '寿司 🍣 Sushi',
          description: 'Délicieux poisson japonais 日本料理',
          price: 25.0,
          isSpecial: false,
          course: Course.mainDish,
          cuisine: Cuisine.japanese,
        );

        expect(dish.name, '寿司 🍣 Sushi');
        expect(dish.description, 'Délicieux poisson japonais 日本料理');
      });

      test('should handle very long description', () {
        final longDescription = 'A' * 1000;
        final dish = Dish(
          id: 'dish123',
          name: 'Long Description Dish',
          description: longDescription,
          price: 10.0,
          isSpecial: false,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
        );

        expect(dish.description!.length, 1000);
      });

      test('should handle dish with all null optional fields', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Minimal Dish',
          description: null,
          price: 10.0,
          isSpecial: true,
          course: Course.other,
          cuisine: Cuisine.other,
          isAvailable: null,
          imageUrl: null,
          userUsername: null,
          creationTime: null,
        );

        expect(dish.description, isNull);
        expect(dish.isAvailable, isNull);
        expect(dish.imageUrl, isNull);
        expect(dish.userUsername, isNull);
        expect(dish.creationTime, isNull);
      });

      test('should handle special dish with specific course and cuisine', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Special Italian Pasta',
          description: 'Custom request pasta',
          price: 30.0,
          isSpecial: true,
          course: Course.pastaDish,
          cuisine: Cuisine.italian,
          userUsername: 'customer123',
          creationTime: DateTime(2026, 1, 10),
          imageUrl: 'https://example.com/pasta.jpg',
        );

        expect(dish.isSpecial, true);
        expect(dish.course, Course.pastaDish);
        expect(dish.cuisine, Cuisine.italian);
        expect(dish.userUsername, 'customer123');
        expect(dish.imageUrl, 'https://example.com/pasta.jpg');
      });

      test('should handle special dish with isAvailable false', () {
        final dish = Dish(
          id: 'dish123',
          name: 'Unavailable Special',
          price: 25.0,
          isSpecial: true,
          isAvailable: false,
          course: Course.mainDish,
          cuisine: Cuisine.french,
          userUsername: 'chef_pierre',
        );

        expect(dish.isSpecial, true);
        expect(dish.isAvailable, false);
      });

      test('should handle regular dish with all cuisine types', () {
        for (final cuisine in Cuisine.values) {
          final dish = Dish(
            id: 'dish_${cuisine.name}',
            name: 'Test ${cuisine.name}',
            price: 15.0,
            isSpecial: false,
            course: Course.mainDish,
            cuisine: cuisine,
          );

          expect(dish.cuisine, cuisine);
          expect(dish.isSpecial, false);
        }
      });

      test('should handle special dish copyWith updating only course', () {
        final original = Dish(
          id: 'dish123',
          name: 'Special',
          price: 20.0,
          isSpecial: true,
          course: Course.appetizer,
          cuisine: Cuisine.italian,
          userUsername: 'user1',
        );

        final updated = original.copyWith(course: Course.dessert);

        expect(updated.course, Course.dessert);
        expect(updated.cuisine, Cuisine.italian);
        expect(updated.userUsername, 'user1');
        expect(updated.isSpecial, true);
      });

      test('should handle special dish copyWith updating imageUrl', () {
        final original = Dish(
          id: 'dish123',
          name: 'Special',
          price: 20.0,
          isSpecial: true,
          course: Course.mainDish,
          cuisine: Cuisine.chinese,
          userUsername: 'user1',
        );

        final updated = original.copyWith(
          imageUrl: 'https://example.com/new-image.jpg',
        );

        expect(updated.imageUrl, 'https://example.com/new-image.jpg');
        expect(updated.isSpecial, true);
        expect(updated.userUsername, 'user1');
      });

      test('should handle special dish toFirestore with all fields', () {
        final creationTime = DateTime(2026, 1, 10, 12, 30);
        final dish = Dish(
          id: 'dish123',
          name: 'Complete Special',
          description: 'Full details',
          price: 35.0,
          isSpecial: true,
          isAvailable: true,
          course: Course.mainDish,
          cuisine: Cuisine.japanese,
          minForewarningDays: 5,
          imageUrl: 'https://example.com/sushi.jpg',
          userUsername: 'sushi_master',
          creationTime: creationTime,
        );

        final firestoreMap = dish.toFirestore();

        expect(firestoreMap['name'], 'Complete Special');
        expect(firestoreMap['description'], 'Full details');
        expect(firestoreMap['price'], 35.0);
        expect(firestoreMap['is_special'], true);
        expect(firestoreMap['is_available'], true);
        expect(firestoreMap['course'], 'mainDish');
        expect(firestoreMap['cuisine'], 'japanese');
        expect(firestoreMap['min_forewarning_days'], 5);
        expect(firestoreMap['image'], 'https://example.com/sushi.jpg');
        expect(firestoreMap['user_username'], 'sushi_master');
        expect(firestoreMap['creation_time'], isA<Timestamp>());
      });

      test('should handle fromFirestore for special dish with all optional fields null', () {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('dish123');
        when(() => mockDoc.data()).thenReturn({
          'name': 'Minimal Special',
          'price': 20.0,
          'is_special': true,
        });

        final dish = Dish.fromFirestore(mockDoc);

        expect(dish.isSpecial, true);
        expect(dish.description, '');
        expect(dish.imageUrl, '');
        expect(dish.isAvailable, isNull);
        expect(dish.userUsername, isNull);
        expect(dish.creationTime, isNull);
        expect(dish.minForewarningDays, 0);
        expect(dish.course, Course.other);
        expect(dish.cuisine, Cuisine.other);
      });
    });
  });
}
