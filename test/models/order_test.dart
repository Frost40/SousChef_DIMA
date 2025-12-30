import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/order.dart';

// Mock class for DocumentSnapshot
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('OrderItem Model Tests', () {
    group('Constructor', () {
      test('should create OrderItem with all required fields', () {
        final orderItem = OrderItem(
          dishId: 'dish123',
          name: 'Pizza Margherita',
          quantity: 2,
          price: 12.50,
        );

        expect(orderItem.dishId, 'dish123');
        expect(orderItem.name, 'Pizza Margherita');
        expect(orderItem.quantity, 2);
        expect(orderItem.price, 12.50);
      });

      test('should handle empty string values', () {
        final orderItem = OrderItem(
          dishId: '',
          name: '',
          quantity: 0,
          price: 0.0,
        );

        expect(orderItem.dishId, '');
        expect(orderItem.name, '');
        expect(orderItem.quantity, 0);
        expect(orderItem.price, 0.0);
      });

      test('should handle large quantity values', () {
        final orderItem = OrderItem(
          dishId: 'dish123',
          name: 'Bulk Item',
          quantity: 1000,
          price: 5.0,
        );

        expect(orderItem.quantity, 1000);
      });

      test('should handle decimal price values', () {
        final orderItem = OrderItem(
          dishId: 'dish123',
          name: 'Precise Price Item',
          quantity: 1,
          price: 12.99,
        );

        expect(orderItem.price, 12.99);
      });

      test('should handle special characters in name', () {
        final orderItem = OrderItem(
          dishId: 'dish123',
          name: "Giuseppe's Special Pizza & Pasta 🍕",
          quantity: 1,
          price: 15.00,
        );

        expect(orderItem.name, "Giuseppe's Special Pizza & Pasta 🍕");
      });
    });

    group('fromMap', () {
      test('should create OrderItem from map with all fields', () {
        final map = {
          'dish_id': 'dish123',
          'name': 'Pizza',
          'quantity': 2,
          'price': 12.50,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.dishId, 'dish123');
        expect(orderItem.name, 'Pizza');
        expect(orderItem.quantity, 2);
        expect(orderItem.price, 12.50);
      });

      test('should handle missing dish_id with empty string default', () {
        final map = {
          'name': 'Pizza',
          'quantity': 2,
          'price': 12.50,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.dishId, '');
      });

      test('should handle null dish_id with empty string default', () {
        final map = {
          'dish_id': null,
          'name': 'Pizza',
          'quantity': 2,
          'price': 12.50,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.dishId, '');
      });

      test('should handle missing name with empty string default', () {
        final map = {
          'dish_id': 'dish123',
          'quantity': 2,
          'price': 12.50,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.name, '');
      });

      test('should handle missing quantity with 0 default', () {
        final map = {
          'dish_id': 'dish123',
          'name': 'Pizza',
          'price': 12.50,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.quantity, 0);
      });

      test('should handle null quantity with 0 default', () {
        final map = {
          'dish_id': 'dish123',
          'name': 'Pizza',
          'quantity': null,
          'price': 12.50,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.quantity, 0);
      });

      test('should handle missing price with 0.0 default', () {
        final map = {
          'dish_id': 'dish123',
          'name': 'Pizza',
          'quantity': 2,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.price, 0.0);
      });

      test('should handle null price with 0.0 default', () {
        final map = {
          'dish_id': 'dish123',
          'name': 'Pizza',
          'quantity': 2,
          'price': null,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.price, 0.0);
      });

      test('should convert integer price to double', () {
        final map = {
          'dish_id': 'dish123',
          'name': 'Pizza',
          'quantity': 2,
          'price': 12,
        };

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.price, 12.0);
        expect(orderItem.price, isA<double>());
      });

      test('should handle empty map', () {
        final map = <String, dynamic>{};

        final orderItem = OrderItem.fromMap(map);

        expect(orderItem.dishId, '');
        expect(orderItem.name, '');
        expect(orderItem.quantity, 0);
        expect(orderItem.price, 0.0);
      });
    });

    group('toMap', () {
      test('should convert OrderItem to map with all fields', () {
        final orderItem = OrderItem(
          dishId: 'dish123',
          name: 'Pizza',
          quantity: 2,
          price: 12.50,
        );

        final map = orderItem.toMap();

        expect(map['dish_id'], 'dish123');
        expect(map['name'], 'Pizza');
        expect(map['quantity'], 2);
        expect(map['price'], 12.50);
      });

      test('should return map with exactly 4 keys', () {
        final orderItem = OrderItem(
          dishId: 'dish123',
          name: 'Pizza',
          quantity: 2,
          price: 12.50,
        );

        final map = orderItem.toMap();

        expect(map.length, 4);
        expect(map.containsKey('dish_id'), isTrue);
        expect(map.containsKey('name'), isTrue);
        expect(map.containsKey('quantity'), isTrue);
        expect(map.containsKey('price'), isTrue);
      });

      test('should handle empty strings', () {
        final orderItem = OrderItem(
          dishId: '',
          name: '',
          quantity: 0,
          price: 0.0,
        );

        final map = orderItem.toMap();

        expect(map['dish_id'], '');
        expect(map['name'], '');
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toMap and fromMap', () {
        final original = OrderItem(
          dishId: 'dish123',
          name: 'Test Pizza',
          quantity: 3,
          price: 15.99,
        );

        final map = original.toMap();
        final restored = OrderItem.fromMap(map);

        expect(restored.dishId, original.dishId);
        expect(restored.name, original.name);
        expect(restored.quantity, original.quantity);
        expect(restored.price, original.price);
      });
    });
  });

  group('Order Model Tests', () {
    group('Constructor', () {
      test('should create Order with all required fields', () {
        final pickupTime = DateTime(2025, 12, 27, 18, 30);
        final dishes = [
          OrderItem(dishId: 'dish1', name: 'Pizza', quantity: 1, price: 12.0),
        ];
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: pickupTime,
          verificationCode: '1234',
          status: 'pending',
          total: 12.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(45.4642, 9.1900),
          dishes: dishes,
        );

        expect(order.id, 'order123');
        expect(order.userId, 'user123');
        expect(order.username, 'testuser');
        expect(order.restaurantName, 'Test Restaurant');
        expect(order.restaurantId, 'rest123');
        expect(order.pickupDateTime, pickupTime);
        expect(order.verificationCode, '1234');
        expect(order.status, 'pending');
        expect(order.total, 12.0);
        expect(order.restaurantAddress, '123 Main St');
        expect(order.restaurantLocation.latitude, 45.4642);
        expect(order.restaurantLocation.longitude, 9.1900);
        expect(order.dishes.length, 1);
      });

      test('should create Order with empty dishes list', () {
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: '1234',
          status: 'pending',
          total: 0.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        expect(order.dishes, isEmpty);
      });

      test('should create Order with multiple dishes', () {
        final dishes = [
          OrderItem(dishId: 'dish1', name: 'Pizza', quantity: 2, price: 12.0),
          OrderItem(dishId: 'dish2', name: 'Pasta', quantity: 1, price: 10.0),
          OrderItem(dishId: 'dish3', name: 'Salad', quantity: 1, price: 8.0),
        ];
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: '1234',
          status: 'pending',
          total: 42.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: dishes,
        );

        expect(order.dishes.length, 3);
      });

      test('should handle different order statuses', () {
        final statuses = ['pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled'];
        
        for (final status in statuses) {
          final order = Order(
            id: 'order123',
            userId: 'user123',
            username: 'testuser',
            restaurantName: 'Test Restaurant',
            restaurantId: 'rest123',
            pickupDateTime: DateTime.now(),
            verificationCode: '1234',
            status: status,
            total: 10.0,
            restaurantAddress: '123 Main St',
            restaurantLocation: const GeoPoint(0, 0),
            dishes: [],
          );

          expect(order.status, status);
        }
      });

      test('should handle special characters in fields', () {
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: "john.o'connor",
          restaurantName: "Giuseppe's Trattoria & Café",
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: 'ABC-123',
          status: 'pending',
          total: 25.50,
          restaurantAddress: '123 Main St, Apt #5, 東京',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        expect(order.username, "john.o'connor");
        expect(order.restaurantName, "Giuseppe's Trattoria & Café");
        expect(order.restaurantAddress, '123 Main St, Apt #5, 東京');
      });
    });

    group('fromFirestore', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should create Order from Firestore document with all fields', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 18, 30));

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 24.50,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(45.4642, 9.1900),
          'dishes': [
            {'dish_id': 'dish1', 'name': 'Pizza', 'quantity': 2, 'price': 12.25},
          ],
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.id, 'order123');
        expect(order.userId, 'user123');
        expect(order.username, 'testuser');
        expect(order.restaurantName, 'Test Restaurant');
        expect(order.restaurantId, 'rest123');
        expect(order.pickupDateTime, timestamp.toDate());
        expect(order.verificationCode, '1234');
        expect(order.status, 'pending');
        expect(order.total, 24.50);
        expect(order.restaurantAddress, '123 Main St');
        expect(order.restaurantLocation.latitude, 45.4642);
        expect(order.dishes.length, 1);
        expect(order.dishes.first.name, 'Pizza');
      });

      test('should handle missing user_id with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.userId, '');
      });

      test('should handle missing username with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.username, '');
      });

      test('should handle missing restaurant_name with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.restaurantName, '');
      });

      test('should handle missing restaurant_id with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.restaurantId, '');
      });

      test('should handle null verification_code with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': null,
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.verificationCode, '');
      });

      test('should handle integer verification_code by converting to string', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': 5678,
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.verificationCode, '5678');
      });

      test('should handle missing status with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.status, '');
      });

      test('should handle missing total with 0.0 default', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.total, 0.0);
      });

      test('should convert integer total to double', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 25,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.total, 25.0);
        expect(order.total, isA<double>());
      });

      test('should handle missing restaurant_address with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.restaurantAddress, '');
      });

      test('should handle missing restaurant_location with default GeoPoint(0, 0)', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.restaurantLocation.latitude, 0);
        expect(order.restaurantLocation.longitude, 0);
      });

      test('should handle null dishes with empty list', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
          'dishes': null,
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.dishes, isEmpty);
      });

      test('should handle missing dishes with empty list', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.dishes, isEmpty);
      });

      test('should handle multiple dishes in array', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 30.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
          'dishes': [
            {'dish_id': 'dish1', 'name': 'Pizza', 'quantity': 1, 'price': 12.0},
            {'dish_id': 'dish2', 'name': 'Pasta', 'quantity': 2, 'price': 9.0},
          ],
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.dishes.length, 2);
        expect(order.dishes[0].name, 'Pizza');
        expect(order.dishes[1].name, 'Pasta');
        expect(order.dishes[1].quantity, 2);
      });

      test('should handle Firestore document with extra fields', () {
        final timestamp = Timestamp.fromDate(DateTime.now());

        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_name': 'Test Restaurant',
          'restaurant_id': 'rest123',
          'pickup_date_time': timestamp,
          'verification_code': '1234',
          'status': 'pending',
          'total': 10.0,
          'restaurant_address': '123 Main St',
          'restaurant_location': const GeoPoint(0, 0),
          'extra_field': 'should be ignored',
          'another_field': 123,
        });

        final order = Order.fromFirestore(mockDoc);

        expect(order.id, 'order123');
        expect(order.userId, 'user123');
      });
    });

    group('toFirestore', () {
      test('should convert Order to Firestore map with all fields', () {
        final pickupTime = DateTime(2025, 12, 27, 18, 30);
        final dishes = [
          OrderItem(dishId: 'dish1', name: 'Pizza', quantity: 2, price: 12.0),
        ];
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: pickupTime,
          verificationCode: '1234',
          status: 'pending',
          total: 24.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(45.4642, 9.1900),
          dishes: dishes,
        );

        final firestoreMap = order.toFirestore();

        expect(firestoreMap['user_id'], 'user123');
        expect(firestoreMap['username'], 'testuser');
        expect(firestoreMap['restaurant_name'], 'Test Restaurant');
        expect(firestoreMap['restaurant_id'], 'rest123');
        expect(firestoreMap['pickup_date_time'], isA<Timestamp>());
        expect((firestoreMap['pickup_date_time'] as Timestamp).toDate(), pickupTime);
        expect(firestoreMap['verification_code'], '1234');
        expect(firestoreMap['status'], 'pending');
        expect(firestoreMap['total'], 24.0);
        expect(firestoreMap['restaurant_address'], '123 Main St');
        expect(firestoreMap['restaurant_location'], isA<GeoPoint>());
        expect(firestoreMap['dishes'], isA<List>());
        expect((firestoreMap['dishes'] as List).length, 1);
      });

      test('should not include id in Firestore map', () {
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: '1234',
          status: 'pending',
          total: 10.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        final firestoreMap = order.toFirestore();

        expect(firestoreMap.containsKey('id'), isFalse);
      });

      test('should return map with exactly 11 keys', () {
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: '1234',
          status: 'pending',
          total: 10.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        final firestoreMap = order.toFirestore();

        expect(firestoreMap.length, 11);
      });

      test('should handle empty dishes list', () {
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: '1234',
          status: 'pending',
          total: 0.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        final firestoreMap = order.toFirestore();

        expect(firestoreMap['dishes'], isEmpty);
      });

      test('should correctly serialize multiple dishes', () {
        final dishes = [
          OrderItem(dishId: 'dish1', name: 'Pizza', quantity: 1, price: 12.0),
          OrderItem(dishId: 'dish2', name: 'Pasta', quantity: 2, price: 10.0),
        ];
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: '1234',
          status: 'pending',
          total: 32.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: dishes,
        );

        final firestoreMap = order.toFirestore();
        final dishesList = firestoreMap['dishes'] as List;

        expect(dishesList.length, 2);
        expect(dishesList[0]['name'], 'Pizza');
        expect(dishesList[1]['name'], 'Pasta');
      });

      test('should handle empty strings', () {
        final order = Order(
          id: '',
          userId: '',
          username: '',
          restaurantName: '',
          restaurantId: '',
          pickupDateTime: DateTime.now(),
          verificationCode: '',
          status: '',
          total: 0.0,
          restaurantAddress: '',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        final firestoreMap = order.toFirestore();

        expect(firestoreMap['user_id'], '');
        expect(firestoreMap['username'], '');
        expect(firestoreMap['restaurant_name'], '');
        expect(firestoreMap['restaurant_id'], '');
        expect(firestoreMap['verification_code'], '');
        expect(firestoreMap['status'], '');
        expect(firestoreMap['restaurant_address'], '');
      });
    });

    group('copyWith', () {
      late Order baseOrder;

      setUp(() {
        baseOrder = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime(2025, 12, 27, 18, 30),
          verificationCode: '1234',
          status: 'pending',
          total: 25.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(45.0, 9.0),
          dishes: [
            OrderItem(dishId: 'dish1', name: 'Pizza', quantity: 1, price: 15.0),
            OrderItem(dishId: 'dish2', name: 'Pasta', quantity: 1, price: 10.0),
          ],
        );
      });

      test('should create copy with no changes when no parameters provided', () {
        final copy = baseOrder.copyWith();

        expect(copy.id, baseOrder.id);
        expect(copy.userId, baseOrder.userId);
        expect(copy.username, baseOrder.username);
        expect(copy.restaurantName, baseOrder.restaurantName);
        expect(copy.restaurantId, baseOrder.restaurantId);
        expect(copy.pickupDateTime, baseOrder.pickupDateTime);
        expect(copy.verificationCode, baseOrder.verificationCode);
        expect(copy.status, baseOrder.status);
        expect(copy.total, baseOrder.total);
        expect(copy.restaurantAddress, baseOrder.restaurantAddress);
        expect(copy.restaurantLocation, baseOrder.restaurantLocation);
        expect(copy.dishes.length, baseOrder.dishes.length);
      });

      test('should update id when provided', () {
        final copy = baseOrder.copyWith(id: 'newOrderId');

        expect(copy.id, 'newOrderId');
        expect(copy.userId, baseOrder.userId);
      });

      test('should update userId when provided', () {
        final copy = baseOrder.copyWith(userId: 'newUserId');

        expect(copy.userId, 'newUserId');
      });

      test('should update username when provided', () {
        final copy = baseOrder.copyWith(username: 'newUsername');

        expect(copy.username, 'newUsername');
      });

      test('should update restaurantName when provided', () {
        final copy = baseOrder.copyWith(restaurantName: 'New Restaurant');

        expect(copy.restaurantName, 'New Restaurant');
      });

      test('should update restaurantId when provided', () {
        final copy = baseOrder.copyWith(restaurantId: 'newRestId');

        expect(copy.restaurantId, 'newRestId');
      });

      test('should update pickupDateTime when provided', () {
        final newPickupTime = DateTime(2025, 12, 28, 19, 0);
        final copy = baseOrder.copyWith(pickupDateTime: newPickupTime);

        expect(copy.pickupDateTime, newPickupTime);
      });

      test('should update verificationCode when provided', () {
        final copy = baseOrder.copyWith(verificationCode: '5678');

        expect(copy.verificationCode, '5678');
      });

      test('should update status when provided', () {
        final copy = baseOrder.copyWith(status: 'confirmed');

        expect(copy.status, 'confirmed');
      });

      test('should update total when provided', () {
        final copy = baseOrder.copyWith(total: 50.0);

        expect(copy.total, 50.0);
      });

      test('should update restaurantAddress when provided', () {
        final copy = baseOrder.copyWith(restaurantAddress: '456 New St');

        expect(copy.restaurantAddress, '456 New St');
      });

      test('should update restaurantLocation when provided', () {
        final newLocation = const GeoPoint(50.0, 10.0);
        final copy = baseOrder.copyWith(restaurantLocation: newLocation);

        expect(copy.restaurantLocation.latitude, 50.0);
        expect(copy.restaurantLocation.longitude, 10.0);
      });

      test('should update dishes when provided', () {
        final newDishes = [
          OrderItem(dishId: 'dish3', name: 'Salad', quantity: 1, price: 8.0),
        ];
        final copy = baseOrder.copyWith(dishes: newDishes);

        expect(copy.dishes.length, 1);
        expect(copy.dishes.first.name, 'Salad');
      });

      test('should update specific dish using updatedDishes map', () {
        final updatedDishes = {
          'dish1': OrderItem(dishId: 'dish1', name: 'Pizza', quantity: 3, price: 15.0),
        };
        final copy = baseOrder.copyWith(updatedDishes: updatedDishes);

        expect(copy.dishes.length, 2);
        expect(copy.dishes.first.quantity, 3);
        expect(copy.dishes.last.name, 'Pasta');
      });

      test('should update multiple dishes using updatedDishes map', () {
        final updatedDishes = {
          'dish1': OrderItem(dishId: 'dish1', name: 'Pizza XL', quantity: 2, price: 20.0),
          'dish2': OrderItem(dishId: 'dish2', name: 'Pasta Special', quantity: 3, price: 12.0),
        };
        final copy = baseOrder.copyWith(updatedDishes: updatedDishes);

        expect(copy.dishes.length, 2);
        expect(copy.dishes[0].name, 'Pizza XL');
        expect(copy.dishes[0].quantity, 2);
        expect(copy.dishes[1].name, 'Pasta Special');
        expect(copy.dishes[1].quantity, 3);
      });

      test('should ignore non-matching dishIds in updatedDishes', () {
        final updatedDishes = {
          'nonExistentDish': OrderItem(dishId: 'nonExistentDish', name: 'Ghost', quantity: 1, price: 1.0),
        };
        final copy = baseOrder.copyWith(updatedDishes: updatedDishes);

        expect(copy.dishes.length, 2);
        expect(copy.dishes[0].name, 'Pizza');
        expect(copy.dishes[1].name, 'Pasta');
      });

      test('should handle empty updatedDishes map', () {
        final copy = baseOrder.copyWith(updatedDishes: {});

        expect(copy.dishes.length, baseOrder.dishes.length);
        expect(copy.dishes[0].name, baseOrder.dishes[0].name);
      });

      test('should prioritize dishes over updatedDishes when both provided', () {
        final newDishes = [
          OrderItem(dishId: 'dish3', name: 'Salad', quantity: 1, price: 8.0),
        ];
        final updatedDishes = {
          'dish1': OrderItem(dishId: 'dish1', name: 'Updated Pizza', quantity: 5, price: 25.0),
        };
        final copy = baseOrder.copyWith(dishes: newDishes, updatedDishes: updatedDishes);

        expect(copy.dishes.length, 1);
        expect(copy.dishes.first.name, 'Salad');
      });

      test('should update multiple fields at once', () {
        final copy = baseOrder.copyWith(
          status: 'completed',
          total: 30.0,
          verificationCode: 'DONE123',
        );

        expect(copy.status, 'completed');
        expect(copy.total, 30.0);
        expect(copy.verificationCode, 'DONE123');
        expect(copy.id, baseOrder.id);
      });

      test('should not affect original order when copying', () {
        final copy = baseOrder.copyWith(status: 'confirmed');

        expect(baseOrder.status, 'pending');
        expect(copy.status, 'confirmed');
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toFirestore and fromFirestore', () {
        final pickupTime = DateTime(2025, 12, 27, 18, 30);
        final originalOrder = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: pickupTime,
          verificationCode: '1234',
          status: 'pending',
          total: 35.50,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(45.4642, 9.1900),
          dishes: [
            OrderItem(dishId: 'dish1', name: 'Pizza', quantity: 2, price: 12.0),
            OrderItem(dishId: 'dish2', name: 'Pasta', quantity: 1, price: 11.50),
          ],
        );

        final firestoreData = originalOrder.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('order123');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredOrder = Order.fromFirestore(mockDoc);

        expect(restoredOrder.id, originalOrder.id);
        expect(restoredOrder.userId, originalOrder.userId);
        expect(restoredOrder.username, originalOrder.username);
        expect(restoredOrder.restaurantName, originalOrder.restaurantName);
        expect(restoredOrder.restaurantId, originalOrder.restaurantId);
        expect(restoredOrder.pickupDateTime, originalOrder.pickupDateTime);
        expect(restoredOrder.verificationCode, originalOrder.verificationCode);
        expect(restoredOrder.status, originalOrder.status);
        expect(restoredOrder.total, originalOrder.total);
        expect(restoredOrder.restaurantAddress, originalOrder.restaurantAddress);
        expect(restoredOrder.dishes.length, originalOrder.dishes.length);
        expect(restoredOrder.dishes[0].name, originalOrder.dishes[0].name);
        expect(restoredOrder.dishes[1].price, originalOrder.dishes[1].price);
      });

      test('should handle round-trip with empty dishes', () {
        final originalOrder = Order(
          id: 'order456',
          userId: 'user456',
          username: 'emptyuser',
          restaurantName: 'Empty Restaurant',
          restaurantId: 'rest456',
          pickupDateTime: DateTime.now(),
          verificationCode: '0000',
          status: 'new',
          total: 0.0,
          restaurantAddress: '456 Empty St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        final firestoreData = originalOrder.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('order456');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredOrder = Order.fromFirestore(mockDoc);

        expect(restoredOrder.dishes, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle order with many dishes', () {
        final dishes = List.generate(
          50,
          (i) => OrderItem(
            dishId: 'dish$i',
            name: 'Item $i',
            quantity: i + 1,
            price: (i + 1) * 1.5,
          ),
        );

        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: '1234',
          status: 'pending',
          total: 1912.5,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: dishes,
        );

        expect(order.dishes.length, 50);
        expect(order.dishes.first.name, 'Item 0');
        expect(order.dishes.last.name, 'Item 49');
      });

      test('should handle future pickup date', () {
        final futureDate = DateTime(2030, 6, 15, 12, 0);
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: futureDate,
          verificationCode: '1234',
          status: 'pending',
          total: 10.0,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        expect(order.pickupDateTime, futureDate);
      });

      test('should handle very high total amount', () {
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantName: 'Test Restaurant',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: '1234',
          status: 'pending',
          total: 999999.99,
          restaurantAddress: '123 Main St',
          restaurantLocation: const GeoPoint(0, 0),
          dishes: [],
        );

        expect(order.total, 999999.99);
      });

      test('should handle unicode in fields', () {
        final order = Order(
          id: 'order123',
          userId: 'user123',
          username: '用户名',
          restaurantName: '寿司レストラン 🍣',
          restaurantId: 'rest123',
          pickupDateTime: DateTime.now(),
          verificationCode: 'コード123',
          status: '準備中',
          total: 50.0,
          restaurantAddress: '東京都渋谷区',
          restaurantLocation: const GeoPoint(35.6762, 139.6503),
          dishes: [],
        );

        expect(order.username, '用户名');
        expect(order.restaurantName, '寿司レストラン 🍣');
        expect(order.restaurantAddress, '東京都渋谷区');
      });
    });
  });
}
