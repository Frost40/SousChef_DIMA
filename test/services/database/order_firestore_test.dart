import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/order.dart';
import 'package:sous_chef/services/database/order_firestore.dart';
import '../../mocks/mock_models.dart';

/// Mock Firestore classes
class MockFirebaseFirestore extends Mock implements firestore.FirebaseFirestore {}
class MockCollectionReference extends Mock implements firestore.CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements firestore.DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements firestore.DocumentSnapshot<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements firestore.QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements firestore.QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockWriteBatch extends Mock implements firestore.WriteBatch {}
class MockQuery extends Mock implements firestore.Query<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('OrderFirestore Service Tests', () {
    late OrderFirestore orderFirestore;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocRef;
    late MockWriteBatch mockBatch;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocRef = MockDocumentReference();
      mockBatch = MockWriteBatch();

      when(() => mockFirestore.collection('orders'))
          .thenReturn(mockCollection);

      orderFirestore = OrderFirestore(firestoreInstance: mockFirestore);
    });

    group('getOrderById', () {
      test('should return order when document exists', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('order123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_address': '123 Main St',
          'restaurant_location': const firestore.GeoPoint(45.0, 9.0),
          'pickup_date_time': firestore.Timestamp.fromDate(DateTime(2025, 12, 31)),
          'verification_code': '1234',
          'status': 'pending',
          'total': 25.0,
          'dishes': [
            {'dish_id': 'dish1', 'name': 'Pizza', 'quantity': 1, 'price': 12.0},
          ],
        });

        // Act
        final result = await orderFirestore.getOrderById('order123');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'order123');
        expect(result.userId, 'user123');
        expect(result.status, 'pending');
      });

      test('should return null when order not found', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('notFound')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act
        final result = await orderFirestore.getOrderById('notFound');

        // Assert
        expect(result, isNull);
      });
    });

    group('createNewOrder', () {
      test('should create order and return document ID', () async {
        // Arrange
        final order = MockModels.createMockOrder();
        when(() => mockCollection.add(any()))
            .thenAnswer((_) async => mockDocRef);
        when(() => mockDocRef.id).thenReturn('newOrder123');

        // Act
        final result = await orderFirestore.createNewOrder(order: order);

        // Assert
        expect(result, 'newOrder123');
        verify(() => mockCollection.add(any())).called(1);
      });
    });

    group('updateOrderStatus', () {
      test('should update order status to paid', () async {
        // Arrange
        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await orderFirestore.updateOrderStatus('order123', 'paid');

        // Assert
        verify(() => mockDocRef.update({'status': 'paid'})).called(1);
      });

      test('should update order status to completed', () async {
        // Arrange
        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await orderFirestore.updateOrderStatus('order123', 'completed');

        // Assert
        verify(() => mockDocRef.update({'status': 'completed'})).called(1);
      });

      test('should update order status to expired', () async {
        // Arrange
        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await orderFirestore.updateOrderStatus('order123', 'expired');

        // Assert
        verify(() => mockDocRef.update({'status': 'expired'})).called(1);
      });
    });

    group('deleteOrder', () {
      test('should delete order by ID', () async {
        // Arrange
        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.delete()).thenAnswer((_) async {});

        // Act
        await orderFirestore.deleteOrder('order123');

        // Assert
        verify(() => mockDocRef.delete()).called(1);
      });
    });

    group('verifyAndCompleteOrder', () {
      test('should return true and update status when code matches', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('order123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_address': '123 Main St',
          'restaurant_location': const firestore.GeoPoint(45.0, 9.0),
          'pickup_date_time': firestore.Timestamp.fromDate(DateTime(2025, 12, 31)),
          'verification_code': '1234',
          'status': 'paid',
          'total': 25.0,
          'dishes': [],
        });
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        final result = await orderFirestore.verifyAndCompleteOrder('order123', '1234');

        // Assert
        expect(result, true);
        verify(() => mockDocRef.update({'status': 'completed'})).called(1);
      });

      test('should return false when code does not match', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('order123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_address': '123 Main St',
          'restaurant_location': const firestore.GeoPoint(45.0, 9.0),
          'pickup_date_time': firestore.Timestamp.fromDate(DateTime(2025, 12, 31)),
          'verification_code': '1234',
          'status': 'paid',
          'total': 25.0,
          'dishes': [],
        });

        // Act
        final result = await orderFirestore.verifyAndCompleteOrder('order123', 'wrong');

        // Assert
        expect(result, false);
        verifyNever(() => mockDocRef.update(any()));
      });

      test('should throw exception when order not found', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('notFound')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act & Assert
        expect(
          () => orderFirestore.verifyAndCompleteOrder('notFound', '1234'),
          throwsException,
        );
      });
    });
  });

  group('Order Model Tests', () {
    group('OrderItem', () {
      test('should create OrderItem with correct properties', () {
        // Act
        final orderItem = OrderItem(
          dishId: 'dish123',
          name: 'Test Dish',
          quantity: 2,
          price: 10.0,
        );

        // Assert
        expect(orderItem.dishId, 'dish123');
        expect(orderItem.name, 'Test Dish');
        expect(orderItem.quantity, 2);
        expect(orderItem.price, 10.0);
      });

      test('should convert OrderItem to map correctly', () {
        // Arrange
        final orderItem = OrderItem(
          dishId: 'dish123',
          name: 'Test Dish',
          quantity: 2,
          price: 10.0,
        );

        // Act
        final map = orderItem.toMap();

        // Assert
        expect(map['dish_id'], 'dish123');
        expect(map['name'], 'Test Dish');
        expect(map['quantity'], 2);
        expect(map['price'], 10.0);
      });

      test('should create OrderItem from map correctly', () {
        // Arrange
        final map = {
          'dish_id': 'dish123',
          'name': 'Test Dish',
          'quantity': 3,
          'price': 15.0,
        };

        // Act
        final orderItem = OrderItem.fromMap(map);

        // Assert
        expect(orderItem.dishId, 'dish123');
        expect(orderItem.name, 'Test Dish');
        expect(orderItem.quantity, 3);
        expect(orderItem.price, 15.0);
      });

      test('should handle missing fields in map with defaults', () {
        // Arrange
        final map = <String, dynamic>{};

        // Act
        final orderItem = OrderItem.fromMap(map);

        // Assert
        expect(orderItem.dishId, '');
        expect(orderItem.name, '');
        expect(orderItem.quantity, 0);
        expect(orderItem.price, 0.0);
      });
    });

    group('Order', () {
      test('should create Order with correct properties using MockModels', () {
        // Act
        final order = MockModels.createMockOrder(
          id: 'order123',
          userId: 'user123',
          username: 'testuser',
          restaurantId: 'restaurant123',
          restaurantName: 'Test Restaurant',
          status: 'pending',
          total: 20.0,
        );

        // Assert
        expect(order.id, 'order123');
        expect(order.userId, 'user123');
        expect(order.username, 'testuser');
        expect(order.restaurantId, 'restaurant123');
        expect(order.restaurantName, 'Test Restaurant');
        expect(order.status, 'pending');
        expect(order.total, 20.0);
      });

      test('should have default dishes when not provided', () {
        // Act
        final order = MockModels.createMockOrder();

        // Assert
        expect(order.dishes, isNotEmpty);
        expect(order.dishes.length, 1);
        expect(order.dishes[0].name, 'Test Dish');
      });

      test('should convert Order to Firestore map correctly', () {
        // Arrange
        final order = MockModels.createMockOrder(
          userId: 'user123',
          username: 'testuser',
          restaurantId: 'restaurant123',
          restaurantName: 'Test Restaurant',
          status: 'pending',
          total: 25.0,
          verificationCode: '1234',
        );

        // Act
        final map = order.toFirestore();

        // Assert
        expect(map['user_id'], 'user123');
        expect(map['username'], 'testuser');
        expect(map['restaurant_id'], 'restaurant123');
        expect(map['restaurant_name'], 'Test Restaurant');
        expect(map['status'], 'pending');
        expect(map['total'], 25.0);
        expect(map['verification_code'], '1234');
        expect(map['dishes'], isA<List>());
      });

      test('should create Order copy with updated fields', () {
        // Arrange
        final order = MockModels.createMockOrder(
          id: 'order123',
          status: 'pending',
          total: 20.0,
        );

        // Act
        final updatedOrder = order.copyWith(
          status: 'paid',
          total: 25.0,
        );

        // Assert
        expect(updatedOrder.id, 'order123'); // Unchanged
        expect(updatedOrder.status, 'paid'); // Updated
        expect(updatedOrder.total, 25.0); // Updated
      });
    });

    group('Order Status Flow', () {
      test('should start with pending status', () {
        final order = MockModels.createMockOrder(status: 'pending');
        expect(order.status, 'pending');
      });

      test('should transition to paid status', () {
        final order = MockModels.createMockOrder(status: 'pending');
        final paidOrder = order.copyWith(status: 'paid');
        expect(paidOrder.status, 'paid');
      });

      test('should transition to completed status', () {
        final order = MockModels.createMockOrder(status: 'paid');
        final completedOrder = order.copyWith(status: 'completed');
        expect(completedOrder.status, 'completed');
      });

      test('should transition to expired status', () {
        final order = MockModels.createMockOrder(status: 'paid');
        final expiredOrder = order.copyWith(status: 'expired');
        expect(expiredOrder.status, 'expired');
      });
    });
  });
}
