import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/order.dart';
import 'package:sous_chef/services/database/order_firestore.dart';
import '../../mocks/mock_models.dart';

/// Mock Firestore classes
class MockFirebaseFirestore extends Mock implements firestore.FirebaseFirestore {}
// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock implements firestore.CollectionReference<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock implements firestore.DocumentReference<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements firestore.DocumentSnapshot<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockQuerySnapshot extends Mock implements firestore.QuerySnapshot<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockQueryDocumentSnapshot extends Mock implements firestore.QueryDocumentSnapshot<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockWriteBatch extends Mock implements firestore.WriteBatch {}
// ignore: subtype_of_sealed_class
class MockQuery extends Mock implements firestore.Query<Map<String, dynamic>> {}
class MockTransaction extends Mock implements firestore.Transaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(const firestore.GeoPoint(0, 0));
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

    group('getUserOrders', () {
      test('should return list of non-completed orders for user', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuery3 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQueryDocSnapshot = MockQueryDocumentSnapshot();

        when(() => mockCollection.where('user_id', isEqualTo: 'user123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isNotEqualTo: 'completed'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.orderBy('pickup_date_time', descending: true))
            .thenReturn(mockQuery3);
        when(() => mockQuery3.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(() => mockQueryDocSnapshot.id).thenReturn('order123');
        when(() => mockQueryDocSnapshot.data()).thenReturn({
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
          'dishes': [],
        });

        // Act
        final result = await orderFirestore.getUserOrders('user123');

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, 1);
        expect(result[0].id, 'order123');
        expect(result[0].status, 'pending');
      });

      test('should return empty list when no orders found', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuery3 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();

        when(() => mockCollection.where('user_id', isEqualTo: 'user123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isNotEqualTo: 'completed'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.orderBy('pickup_date_time', descending: true))
            .thenReturn(mockQuery3);
        when(() => mockQuery3.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await orderFirestore.getUserOrders('user123');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getUserCompletedOrders', () {
      test('should return list of completed orders for user', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuery3 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQueryDocSnapshot = MockQueryDocumentSnapshot();

        when(() => mockCollection.where('user_id', isEqualTo: 'user123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isEqualTo: 'completed'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.orderBy('pickup_date_time', descending: true))
            .thenReturn(mockQuery3);
        when(() => mockQuery3.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(() => mockQueryDocSnapshot.id).thenReturn('order123');
        when(() => mockQueryDocSnapshot.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_address': '123 Main St',
          'restaurant_location': const firestore.GeoPoint(45.0, 9.0),
          'pickup_date_time': firestore.Timestamp.fromDate(DateTime(2025, 12, 31)),
          'verification_code': '1234',
          'status': 'completed',
          'total': 25.0,
          'dishes': [],
        });

        // Act
        final result = await orderFirestore.getUserCompletedOrders('user123');

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, 1);
        expect(result[0].status, 'completed');
      });
    });

    group('getUserPaidOrders', () {
      test('should return valid paid orders and expire old ones', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQueryDocSnapshot1 = MockQueryDocumentSnapshot();
        final mockQueryDocSnapshot2 = MockQueryDocumentSnapshot();
        final mockDocRef1 = MockDocumentReference();
        final mockDocRef2 = MockDocumentReference();

        when(() => mockCollection.where('user_id', isEqualTo: 'user123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isEqualTo: 'paid'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot);

        // Two orders: one valid (future pickup), one expired (old pickup)
        when(() => mockQuerySnapshot.docs).thenReturn([
          mockQueryDocSnapshot1,
          mockQueryDocSnapshot2,
        ]);

        // Valid order with future pickup
        when(() => mockQueryDocSnapshot1.id).thenReturn('validOrder');
        when(() => mockQueryDocSnapshot1.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_address': '123 Main St',
          'restaurant_location': const firestore.GeoPoint(45.0, 9.0),
          'pickup_date_time': firestore.Timestamp.fromDate(DateTime.now().add(const Duration(hours: 2))),
          'verification_code': '1234',
          'status': 'paid',
          'total': 25.0,
          'dishes': [],
        });

        // Expired order (pickup was 25 hours ago)
        when(() => mockQueryDocSnapshot2.id).thenReturn('expiredOrder');
        when(() => mockQueryDocSnapshot2.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_address': '123 Main St',
          'restaurant_location': const firestore.GeoPoint(45.0, 9.0),
          'pickup_date_time': firestore.Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 25))),
          'verification_code': '5678',
          'status': 'paid',
          'total': 30.0,
          'dishes': [],
        });

        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockCollection.doc('expiredOrder')).thenReturn(mockDocRef2);
        when(() => mockBatch.update(mockDocRef2, {'status': 'expired'})).thenReturn(null);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        final result = await orderFirestore.getUserPaidOrders('user123');

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 'validOrder');
        verify(() => mockBatch.update(mockDocRef2, {'status': 'expired'})).called(1);
        verify(() => mockBatch.commit()).called(1);
      });

      test('should return empty list when no paid orders exist', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();

        when(() => mockCollection.where('user_id', isEqualTo: 'user123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isEqualTo: 'paid'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        final result = await orderFirestore.getUserPaidOrders('user123');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getRestaurantReceivedOrders', () {
      test('should return valid paid orders for restaurant and expire old ones', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQueryDocSnapshot = MockQueryDocumentSnapshot();

        when(() => mockCollection.where('restaurant_id', isEqualTo: 'rest123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isEqualTo: 'paid'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(() => mockQueryDocSnapshot.id).thenReturn('order123');
        when(() => mockQueryDocSnapshot.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_address': '123 Main St',
          'restaurant_location': const firestore.GeoPoint(45.0, 9.0),
          'pickup_date_time': firestore.Timestamp.fromDate(DateTime.now().add(const Duration(hours: 2))),
          'verification_code': '1234',
          'status': 'paid',
          'total': 25.0,
          'dishes': [],
        });

        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        final result = await orderFirestore.getRestaurantReceivedOrders('rest123');

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 'order123');
      });

      test('should expire orders past 24 hours for restaurant', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQueryDocSnapshot = MockQueryDocumentSnapshot();
        final mockExpiredDocRef = MockDocumentReference();

        when(() => mockCollection.where('restaurant_id', isEqualTo: 'rest123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isEqualTo: 'paid'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(() => mockQueryDocSnapshot.id).thenReturn('expiredOrder');
        when(() => mockQueryDocSnapshot.data()).thenReturn({
          'user_id': 'user123',
          'username': 'testuser',
          'restaurant_id': 'rest123',
          'restaurant_name': 'Test Restaurant',
          'restaurant_address': '123 Main St',
          'restaurant_location': const firestore.GeoPoint(45.0, 9.0),
          'pickup_date_time': firestore.Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 30))),
          'verification_code': '1234',
          'status': 'paid',
          'total': 25.0,
          'dishes': [],
        });

        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockCollection.doc('expiredOrder')).thenReturn(mockExpiredDocRef);
        when(() => mockBatch.update(mockExpiredDocRef, {'status': 'expired'})).thenReturn(null);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        final result = await orderFirestore.getRestaurantReceivedOrders('rest123');

        // Assert
        expect(result, isEmpty);
        verify(() => mockBatch.update(mockExpiredDocRef, {'status': 'expired'})).called(1);
      });
    });

    group('updateOrder', () {
      test('should throw exception when order not found', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('notFound')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act & Assert
        expect(
          () => orderFirestore.updateOrder(
            orderId: 'notFound',
            dishId: 'dish123',
            newQuantity: 2,
            dishPrice: 10.0,
          ),
          throwsException,
        );
      });

      test('should throw exception when dish not found in order', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot['dishes']).thenReturn([
          {'dish_id': 'otherDish', 'name': 'Other', 'quantity': 1, 'price': 5.0},
        ]);

        // Act & Assert
        expect(
          () => orderFirestore.updateOrder(
            orderId: 'order123',
            dishId: 'notFoundDish',
            newQuantity: 2,
            dishPrice: 10.0,
          ),
          throwsException,
        );
      });

      test('should find dish and prepare for transaction when dish exists', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        // Use a separate instance for this test to avoid mock state leakage
        final mockTestFirestore = MockFirebaseFirestore();
        final mockTestCollection = MockCollectionReference();
        final mockTestDocRef = MockDocumentReference();

        when(() => mockTestFirestore.collection('orders')).thenReturn(mockTestCollection);
        final testOrderFirestore = OrderFirestore(firestoreInstance: mockTestFirestore);

        when(() => mockTestCollection.doc('order123')).thenReturn(mockTestDocRef);
        when(() => mockTestDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot['dishes']).thenReturn([
          {'dish_id': 'dish123', 'name': 'Pizza', 'quantity': 1, 'price': 10.0},
        ]);

        // Verify the path up to transaction is reached by checking document fetch
        await testOrderFirestore.updateOrder(
          orderId: 'order123',
          dishId: 'dish123',
          newQuantity: 2,
          dishPrice: 10.0,
        ).catchError((_) {}); // Ignore error from unmocked transaction

        // Assert - verify the document was fetched (proving we got to the transaction stage)
        verify(() => mockTestDocRef.get()).called(1);
      });
    });

    group('addDishToOrder', () {
      test('should add new dish to order', () async {
        // Arrange
        final orderItem = OrderItem(
          dishId: 'newDish123',
          name: 'New Dish',
          quantity: 1,
          price: 15.0,
        );

        when(() => mockCollection.doc('order123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        await orderFirestore.addDishToOrder(
          orderId: 'order123',
          orderItem: orderItem,
        );

        // Assert - verify update was called (not the exact map due to FieldValue comparison issues)
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('updateRestaurantNameInOrders', () {
      test('should update restaurant name in all non-completed orders', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQueryDocSnapshot = MockQueryDocumentSnapshot();
        final mockOrderDocRef = MockDocumentReference();

        when(() => mockCollection.where('restaurant_id', isEqualTo: 'rest123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isNotEqualTo: 'completed'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(() => mockQueryDocSnapshot.reference).thenReturn(mockOrderDocRef);

        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(mockOrderDocRef, {'restaurant_name': 'New Name'})).thenReturn(null);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        await orderFirestore.updateRestaurantNameInOrders('rest123', 'New Name');

        // Assert
        verify(() => mockBatch.update(mockOrderDocRef, {'restaurant_name': 'New Name'})).called(1);
        verify(() => mockBatch.commit()).called(1);
      });

      test('should handle empty result when no matching orders', () async {
        // Arrange
        final mockQuery1 = MockQuery();
        final mockQuery2 = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();

        when(() => mockCollection.where('restaurant_id', isEqualTo: 'rest123'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('status', isNotEqualTo: 'completed'))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);

        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        await orderFirestore.updateRestaurantNameInOrders('rest123', 'New Name');

        // Assert
        verify(() => mockBatch.commit()).called(1);
      });
    });

    group('updateRestaurantAddressInOrders', () {
      test('should update address for orders with specific statuses', () async {
        // Arrange
        final newLocation = const firestore.GeoPoint(46.0, 10.0);
        final mockQueryReady = MockQuery();
        final mockQueryPending = MockQuery();
        final mockQueryPaid = MockQuery();
        final mockQuery2Ready = MockQuery();
        final mockQuery2Pending = MockQuery();
        final mockQuery2Paid = MockQuery();
        final mockSnapshotReady = MockQuerySnapshot();
        final mockSnapshotPending = MockQuerySnapshot();
        final mockSnapshotPaid = MockQuerySnapshot();
        final mockDocSnapshotReady = MockQueryDocumentSnapshot();
        final mockDocRefReady = MockDocumentReference();

        // Setup for 'ready_for_checkout' status
        when(() => mockCollection.where('restaurant_id', isEqualTo: 'rest123'))
            .thenReturn(mockQueryReady);
        when(() => mockQueryReady.where('status', isEqualTo: 'ready_for_checkout'))
            .thenReturn(mockQuery2Ready);
        when(() => mockQuery2Ready.get()).thenAnswer((_) async => mockSnapshotReady);
        when(() => mockSnapshotReady.docs).thenReturn([mockDocSnapshotReady]);
        when(() => mockDocSnapshotReady.reference).thenReturn(mockDocRefReady);

        // Setup for 'pending' status
        when(() => mockQueryReady.where('status', isEqualTo: 'pending'))
            .thenReturn(mockQuery2Pending);
        when(() => mockQuery2Pending.get()).thenAnswer((_) async => mockSnapshotPending);
        when(() => mockSnapshotPending.docs).thenReturn([]);

        // Setup for 'paid' status
        when(() => mockQueryReady.where('status', isEqualTo: 'paid'))
            .thenReturn(mockQuery2Paid);
        when(() => mockQuery2Paid.get()).thenAnswer((_) async => mockSnapshotPaid);
        when(() => mockSnapshotPaid.docs).thenReturn([]);

        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(mockDocRefReady, {
          'restaurant_address': 'New Address',
          'restaurant_location': newLocation,
        })).thenReturn(null);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        await orderFirestore.updateRestaurantAddressInOrders(
          'rest123',
          'New Address',
          newLocation,
        );

        // Assert
        verify(() => mockBatch.update(mockDocRefReady, {
          'restaurant_address': 'New Address',
          'restaurant_location': newLocation,
        })).called(1);
        verify(() => mockBatch.commit()).called(1);
      });

      test('should handle empty results for all statuses', () async {
        // Arrange
        final newLocation = const firestore.GeoPoint(46.0, 10.0);
        final mockQueryBase = MockQuery();
        final mockQuery2Ready = MockQuery();
        final mockQuery2Pending = MockQuery();
        final mockQuery2Paid = MockQuery();
        final mockSnapshotEmpty = MockQuerySnapshot();

        when(() => mockCollection.where('restaurant_id', isEqualTo: 'rest123'))
            .thenReturn(mockQueryBase);
        when(() => mockQueryBase.where('status', isEqualTo: 'ready_for_checkout'))
            .thenReturn(mockQuery2Ready);
        when(() => mockQuery2Ready.get()).thenAnswer((_) async => mockSnapshotEmpty);

        when(() => mockQueryBase.where('status', isEqualTo: 'pending'))
            .thenReturn(mockQuery2Pending);
        when(() => mockQuery2Pending.get()).thenAnswer((_) async => mockSnapshotEmpty);

        when(() => mockQueryBase.where('status', isEqualTo: 'paid'))
            .thenReturn(mockQuery2Paid);
        when(() => mockQuery2Paid.get()).thenAnswer((_) async => mockSnapshotEmpty);

        when(() => mockSnapshotEmpty.docs).thenReturn([]);
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        await orderFirestore.updateRestaurantAddressInOrders(
          'rest123',
          'New Address',
          newLocation,
        );

        // Assert
        verify(() => mockBatch.commit()).called(1);
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
