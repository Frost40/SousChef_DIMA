import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/providers/order_provider.dart';
import 'package:sous_chef/services/database/order_firestore.dart';
import 'package:sous_chef/models/order.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_models.dart';

void main() {
  group('OrderProvider Tests', () {
    late OrderProvider orderProvider;
    late MockOrderFirestore mockOrderFirestore;

    setUp(() {
      mockOrderFirestore = MockOrderFirestore();
      
      // Use dependency injection to inject mock service
      orderProvider = OrderProvider(orderFirestore: mockOrderFirestore);
      
      // Register fallback values
      registerFallbackValue(MockModels.createMockOrder());
    });

    tearDown(() {
      orderProvider.dispose();
    });

    group('State Management', () {
      test('initial state should have empty orders list and not loading', () {
        expect(orderProvider.userOrders, isEmpty);
        expect(orderProvider.isLoading, false);
        expect(orderProvider.errorMessage, null);
      });

      test('clearErrors should clear error message', () {
        orderProvider.clearErrors();
        expect(orderProvider.errorMessage, isNull);
      });
    });

    group('fetchUserOrders', () {
      test('should populate orders list on successful fetch', () async {
        // Arrange
        final mockOrders = [
          MockModels.createMockOrder(id: 'order1', total: 25.0),
          MockModels.createMockOrder(id: 'order2', total: 35.0),
        ];
        
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenAnswer((_) async => mockOrders);

        // Act
        await orderProvider.fetchUserOrders('user123');

        // Assert
        expect(orderProvider.userOrders.length, 2);
        expect(orderProvider.userOrders[0].id, 'order1');
        expect(orderProvider.userOrders[1].id, 'order2');
        expect(orderProvider.isLoading, false);
        expect(orderProvider.errorMessage, isNull);
        verify(() => mockOrderFirestore.getUserOrders('user123')).called(1);
      });

      test('should set error message on fetch failure', () async {
        // Arrange
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenThrow(Exception('Network error'));

        // Act
        await orderProvider.fetchUserOrders('user123');

        // Assert
        expect(orderProvider.isLoading, false);
        expect(orderProvider.errorMessage, isNotNull);
        expect(orderProvider.errorMessage, contains('error'));
      });

      test('should refresh orders when forceRefresh is true', () async {
        // Arrange
        final mockOrders = [MockModels.createMockOrder(id: 'order1')];
        final newMockOrders = [MockModels.createMockOrder(id: 'order2')];
        
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenAnswer((_) async => mockOrders);

        // First fetch
        await orderProvider.fetchUserOrders('user123');
        expect(orderProvider.userOrders.length, 1);

        // Setup new return value
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenAnswer((_) async => newMockOrders);

        // Force refresh
        await orderProvider.fetchUserOrders('user123', forceRefresh: true);

        // Assert - should have called service twice
        verify(() => mockOrderFirestore.getUserOrders('user123')).called(2);
      });
    });

    group('fetchUserCompletedOrders', () {
      test('should return completed orders', () async {
        // Arrange
        final completedOrders = [
          MockModels.createMockOrder(id: 'order1', status: 'completed'),
          MockModels.createMockOrder(id: 'order2', status: 'completed'),
        ];
        
        when(() => mockOrderFirestore.getUserCompletedOrders(any()))
            .thenAnswer((_) async => completedOrders);

        // Act
        final result = await orderProvider.fetchUserCompletedOrders('user123');

        // Assert
        expect(result.length, 2);
        expect(result.every((o) => o.status == 'completed'), true);
        verify(() => mockOrderFirestore.getUserCompletedOrders('user123')).called(1);
      });

      test('should return empty list when no completed orders', () async {
        // Arrange
        when(() => mockOrderFirestore.getUserCompletedOrders(any()))
            .thenAnswer((_) async => []);

        // Act
        final result = await orderProvider.fetchUserCompletedOrders('user123');

        // Assert
        expect(result, isEmpty);
      });

      test('should set error message on failure', () async {
        // Arrange
        when(() => mockOrderFirestore.getUserCompletedOrders(any()))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await orderProvider.fetchUserCompletedOrders('user123');

        // Assert
        expect(result, isEmpty);
        expect(orderProvider.errorMessage, isNotNull);
      });
    });

    group('fetchUserPaidOrders', () {
      test('should return paid orders', () async {
        // Arrange
        final paidOrders = [
          MockModels.createMockOrder(id: 'order1', status: 'paid'),
        ];
        
        when(() => mockOrderFirestore.getUserPaidOrders(any()))
            .thenAnswer((_) async => paidOrders);

        // Act
        final result = await orderProvider.fetchUserPaidOrders('user123');

        // Assert
        expect(result.length, 1);
        expect(result[0].status, 'paid');
        verify(() => mockOrderFirestore.getUserPaidOrders('user123')).called(1);
      });

      test('should handle empty paid orders', () async {
        // Arrange
        when(() => mockOrderFirestore.getUserPaidOrders(any()))
            .thenAnswer((_) async => []);

        // Act
        final result = await orderProvider.fetchUserPaidOrders('user123');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('fetchRestaurantReceivedOrders', () {
      test('should return orders for restaurant', () async {
        // Arrange
        final restaurantOrders = [
          MockModels.createMockOrder(id: 'order1', restaurantId: 'rest123'),
          MockModels.createMockOrder(id: 'order2', restaurantId: 'rest123'),
        ];
        
        when(() => mockOrderFirestore.getRestaurantReceivedOrders(any()))
            .thenAnswer((_) async => restaurantOrders);

        // Act
        final result = await orderProvider.fetchRestaurantReceivedOrders('rest123');

        // Assert
        expect(result.length, 2);
        verify(() => mockOrderFirestore.getRestaurantReceivedOrders('rest123')).called(1);
      });

      test('should handle empty restaurant orders', () async {
        // Arrange
        when(() => mockOrderFirestore.getRestaurantReceivedOrders(any()))
            .thenAnswer((_) async => []);

        // Act
        final result = await orderProvider.fetchRestaurantReceivedOrders('rest123');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getOrderById', () {
      test('should return order when it exists in local list', () async {
        // Arrange
        final mockOrders = [
          MockModels.createMockOrder(id: 'order1'),
          MockModels.createMockOrder(id: 'order2'),
        ];
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenAnswer((_) async => mockOrders);
        await orderProvider.fetchUserOrders('user123');

        // Act
        final result = orderProvider.getOrderById('order1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'order1');
      });

      test('should return null when order does not exist', () {
        final result = orderProvider.getOrderById('nonexistent');
        expect(result, isNull);
      });
    });

    group('updateOrderStatus', () {
      test('should update order status successfully', () async {
        // Arrange
        when(() => mockOrderFirestore.updateOrderStatus(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await orderProvider.updateOrderStatus('order123', 'completed');

        // Assert
        expect(orderProvider.isLoading, false);
        expect(orderProvider.errorMessage, isNull);
        verify(() => mockOrderFirestore.updateOrderStatus('order123', 'completed')).called(1);
      });

      test('should set error on status update failure', () async {
        // Arrange
        when(() => mockOrderFirestore.updateOrderStatus(any(), any()))
            .thenThrow(Exception('Update failed'));

        // Act
        await orderProvider.updateOrderStatus('order123', 'completed');

        // Assert
        expect(orderProvider.isLoading, false);
        expect(orderProvider.errorMessage, isNotNull);
      });
    });

    group('deleteOrder', () {
      test('should delete order and remove from local list', () async {
        // Arrange
        final mockOrders = [
          MockModels.createMockOrder(id: 'order1'),
          MockModels.createMockOrder(id: 'order2'),
        ];
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenAnswer((_) async => mockOrders);
        when(() => mockOrderFirestore.deleteOrder(any()))
            .thenAnswer((_) async {});
        await orderProvider.fetchUserOrders('user123');
        expect(orderProvider.userOrders.length, 2);

        // Act
        await orderProvider.deleteOrder('order1');

        // Assert
        expect(orderProvider.userOrders.length, 1);
        expect(orderProvider.userOrders.first.id, 'order2');
        verify(() => mockOrderFirestore.deleteOrder('order1')).called(1);
      });

      test('should set error on delete failure', () async {
        // Arrange
        when(() => mockOrderFirestore.deleteOrder(any()))
            .thenThrow(Exception('Delete failed'));

        // Act
        await orderProvider.deleteOrder('order123');

        // Assert
        expect(orderProvider.isLoading, false);
        expect(orderProvider.errorMessage, isNotNull);
      });
    });

    group('verifyAndCompleteOrder', () {
      test('should return true on successful verification', () async {
        // Arrange
        final mockOrders = [MockModels.createMockOrder(id: 'order1', status: 'paid')];
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenAnswer((_) async => mockOrders);
        when(() => mockOrderFirestore.verifyAndCompleteOrder(any(), any()))
            .thenAnswer((_) async => true);
        await orderProvider.fetchUserOrders('user123');

        // Act
        final result = await orderProvider.verifyAndCompleteOrder('order1', '1234');

        // Assert
        expect(result, true);
        expect(orderProvider.userOrders, isEmpty);
        verify(() => mockOrderFirestore.verifyAndCompleteOrder('order1', '1234')).called(1);
      });

      test('should return false on failed verification', () async {
        // Arrange
        when(() => mockOrderFirestore.verifyAndCompleteOrder(any(), any()))
            .thenAnswer((_) async => false);

        // Act
        final result = await orderProvider.verifyAndCompleteOrder('order1', 'wrong');

        // Assert
        expect(result, false);
      });

      test('should handle verification error', () async {
        // Arrange
        when(() => mockOrderFirestore.verifyAndCompleteOrder(any(), any()))
            .thenThrow(Exception('Verification failed'));

        // Act & Assert
        expect(
          () => orderProvider.verifyAndCompleteOrder('order1', '1234'),
          throwsException,
        );
      });
    });

    group('hasPendingOrderDateTime', () {
      test('should return index when pending order exists', () async {
        // Arrange
        final pickupTime = DateTime.now().add(const Duration(hours: 2));
        final mockOrders = [
          MockModels.createMockOrder(
            id: 'order1',
            restaurantId: 'rest123',
            status: 'ready_for_checkout',
            pickupDateTime: pickupTime,
          ),
        ];
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenAnswer((_) async => mockOrders);
        await orderProvider.fetchUserOrders('user123');

        // Act
        final result = await orderProvider.hasPendingOrderDateTime('rest123', pickupTime);

        // Assert
        expect(result, 0);
      });

      test('should return null when no pending order for datetime', () async {
        // Arrange
        final pickupTime = DateTime.now().add(const Duration(hours: 2));
        final differentTime = DateTime.now().add(const Duration(hours: 5));
        final mockOrders = [
          MockModels.createMockOrder(
            id: 'order1',
            restaurantId: 'rest123',
            status: 'ready_for_checkout',
            pickupDateTime: pickupTime,
          ),
        ];
        when(() => mockOrderFirestore.getUserOrders(any()))
            .thenAnswer((_) async => mockOrders);
        await orderProvider.fetchUserOrders('user123');

        // Act
        final result = await orderProvider.hasPendingOrderDateTime('rest123', differentTime);

        // Assert
        expect(result, isNull);
      });
    });

    group('updateRestaurantNameInOrders', () {
      test('should update restaurant name successfully', () async {
        // Arrange
        when(() => mockOrderFirestore.updateRestaurantNameInOrders(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await orderProvider.updateRestaurantNameInOrders('rest123', 'New Name');

        // Assert
        verify(() => mockOrderFirestore.updateRestaurantNameInOrders('rest123', 'New Name')).called(1);
        expect(orderProvider.isLoading, false);
      });

      test('should set error on update failure', () async {
        // Arrange
        when(() => mockOrderFirestore.updateRestaurantNameInOrders(any(), any()))
            .thenThrow(Exception('Update failed'));

        // Act
        await orderProvider.updateRestaurantNameInOrders('rest123', 'New Name');

        // Assert
        expect(orderProvider.errorMessage, isNotNull);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners on state changes', () {
        var notifyCount = 0;
        orderProvider.addListener(() {
          notifyCount++;
        });

        orderProvider.clearErrors();

        expect(notifyCount, greaterThan(0));
      });
    });
  });
}
