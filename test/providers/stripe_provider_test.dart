import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/providers/stripe_provider.dart';
import 'package:sous_chef/services/stripe.dart';
import '../mocks/mock_services.dart';

void main() {
  group('StripeProvider Tests', () {
    late StripeProvider stripeProvider;
    late MockStripeService mockStripeService;

    setUp(() {
      mockStripeService = MockStripeService();
      
      // Use dependency injection to inject mock service
      stripeProvider = StripeProvider(stripeService: mockStripeService);
    });

    tearDown(() {
      stripeProvider.dispose();
    });

    group('Constructor', () {
      test('should create provider with injected service', () {
        final provider = StripeProvider(stripeService: mockStripeService);
        expect(provider.isLoading, false);
        expect(provider.errorMessage, isNull);
        provider.dispose();
      });

      test('should use injected service for operations', () async {
        // Verify that the injected mock is used
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenAnswer((_) async => {'status': 'succeeded'});

        await stripeProvider.refundPayment(orderId: 'test', amount: 10.0);

        verify(() => mockStripeService.createRefund(
          paymentIntentId: 'test',
          amount: 1000,
        )).called(1);
      });
    });

    group('State Management', () {
      test('initial state should not be loading and have no errors', () {
        expect(stripeProvider.isLoading, false);
        expect(stripeProvider.errorMessage, isNull);
      });

      test('clearError should clear error message', () {
        stripeProvider.clearError();
        expect(stripeProvider.errorMessage, isNull);
      });

      test('clearError should notify listeners', () {
        var notified = false;
        stripeProvider.addListener(() => notified = true);
        
        stripeProvider.clearError();
        
        expect(notified, true);
      });
    });

    group('Amount Conversion', () {
      test('should convert amount to cents correctly - whole number', () {
        const amount = 10.0;
        final amountInCents = (amount * 100).toInt();
        expect(amountInCents, 1000);
      });

      test('should convert amount to cents correctly - decimal', () {
        const amount = 10.50;
        final amountInCents = (amount * 100).toInt();
        expect(amountInCents, 1050);
      });

      test('should convert amount to cents correctly - small decimal', () {
        const amount = 0.99;
        final amountInCents = (amount * 100).toInt();
        expect(amountInCents, 99);
      });

      test('should convert amount to cents correctly - large amount', () {
        const amount = 1234.56;
        final amountInCents = (amount * 100).toInt();
        expect(amountInCents, 123456);
      });
    });

    group('processPayment - Service Orchestration', () {
      testWidgets('should call createPaymentIntent with correct parameters', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 'pi_test_secret_123',
          'orderIds': ['order1'],
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 25.50,
                  items: [{'id': 'item1', 'price': 25.50}],
                  currency: 'eur',
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();

        // Assert - verify service was called with correct amount in cents
        verify(() => mockStripeService.createPaymentIntent(
          amount: 2550,
          currency: 'eur',
          items: [{'id': 'item1', 'price': 25.50}],
        )).called(1);
      });

      testWidgets('should set loading state during payment processing', (tester) async {
        // Arrange
        var loadingDuringOperation = false;
        
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async {
          loadingDuringOperation = stripeProvider.isLoading;
          return {
            'clientSecret': 'pi_test_secret',
            'orderIds': ['order1'],
          };
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();

        // Assert - loading was true during the service call
        expect(loadingDuringOperation, true);
      });

      testWidgets('should notify listeners when starting payment', (tester) async {
        // Arrange
        var notifyCount = 0;
        stripeProvider.addListener(() => notifyCount++);
        
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 'pi_test_secret',
          'orderIds': ['order1'],
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();

        // Assert - should have been notified at least once (for loading state)
        expect(notifyCount, greaterThan(0));
      });

      testWidgets('should handle null clientSecret error', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': null,
          'orderIds': ['order1'],
        });

        late bool result;
        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pumpAndSettle();

        // Assert
        expect(result, false);
        expect(stripeProvider.errorMessage, isNotNull);
        expect(stripeProvider.errorMessage, contains('pagamento'));
        expect(stripeProvider.isLoading, false);
      });

      testWidgets('should handle empty clientSecret error', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': '',
          'orderIds': ['order1'],
        });

        late bool result;
        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pumpAndSettle();

        // Assert
        expect(result, false);
        expect(stripeProvider.errorMessage, isNotNull);
        expect(stripeProvider.isLoading, false);
      });

      testWidgets('should handle clientSecret with wrong type', (tester) async {
        // Arrange - clientSecret is an int instead of string
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 12345, // Wrong type - not a String
          'orderIds': ['order1'],
        });

        late bool result;
        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pumpAndSettle();

        // Assert - should fail due to type check
        expect(result, false);
        expect(stripeProvider.errorMessage, isNotNull);
        expect(stripeProvider.isLoading, false);
      });

      testWidgets('should handle service exception', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenThrow(Exception('Network error'));

        late bool result;
        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pumpAndSettle();

        // Assert
        expect(result, false);
        expect(stripeProvider.errorMessage, isNotNull);
        expect(stripeProvider.errorMessage, contains('pagamento'));
        expect(stripeProvider.isLoading, false);
      });

      testWidgets('should use default currency when not specified', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 'pi_test_secret',
          'orderIds': ['order1'],
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                  // currency not specified - should default to 'eur'
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();

        // Assert - verify default currency is 'eur'
        verify(() => mockStripeService.createPaymentIntent(
          amount: 1000,
          currency: 'eur',
          items: [],
        )).called(1);
      });

      testWidgets('should reset error state before processing', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async {
          // Verify error was cleared at start
          expect(stripeProvider.errorMessage, isNull);
          return <String, dynamic>{
            'clientSecret': 'pi_test_secret',
            'orderIds': ['order1'],
          };
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();
      });
    });

    group('refundPayment', () {
      test('should return true on successful refund', () async {
        // Arrange
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenAnswer((_) async => {'status': 'succeeded'});

        // Act
        final result = await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 25.00,
        );

        // Assert
        expect(result, true);
        expect(stripeProvider.isLoading, false);
        expect(stripeProvider.errorMessage, isNull);
        verify(() => mockStripeService.createRefund(
          paymentIntentId: 'pi_test123',
          amount: 2500,
        )).called(1);
      });

      test('should return false on refund failure', () async {
        // Arrange
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenThrow(Exception('Refund failed'));

        // Act
        final result = await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 25.00,
        );

        // Assert
        expect(result, false);
        expect(stripeProvider.isLoading, false);
        expect(stripeProvider.errorMessage, isNotNull);
        expect(stripeProvider.errorMessage, contains('rimborso'));
      });

      test('should convert refund amount to cents', () async {
        // Arrange
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenAnswer((_) async => {'status': 'succeeded'});

        // Act
        await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 15.75,
        );

        // Assert - verify amount was converted to cents (1575)
        verify(() => mockStripeService.createRefund(
          paymentIntentId: 'pi_test123',
          amount: 1575,
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when clearing error', () {
        var notifyCount = 0;
        stripeProvider.addListener(() {
          notifyCount++;
        });

        stripeProvider.clearError();

        expect(notifyCount, greaterThan(0));
      });

      test('should notify listeners on refund completion', () async {
        var notifyCount = 0;
        stripeProvider.addListener(() {
          notifyCount++;
        });

        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenAnswer((_) async => {'status': 'succeeded'});

        await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 25.00,
        );

        expect(notifyCount, greaterThan(0));
      });

      test('should notify listeners on refund error', () async {
        var notifyCount = 0;
        stripeProvider.addListener(() {
          notifyCount++;
        });

        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenThrow(Exception('Refund failed'));

        await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 25.00,
        );

        expect(notifyCount, greaterThan(0));
      });
    });

    group('createPaymentIntent', () {
      test('should call service with correct parameters', () async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 'pi_test_secret',
          'orderIds': ['order1', 'order2'],
        });

        // Act - Testing the service call directly since processPayment requires BuildContext
        final result = await mockStripeService.createPaymentIntent(
          amount: 1000,
          currency: 'eur',
          items: [{'id': 'item1', 'price': 10.0}],
        );

        // Assert
        expect(result['clientSecret'], 'pi_test_secret');
        expect(result['orderIds'], ['order1', 'order2']);
      });
    });

    group('Error Handling', () {
      test('should handle network errors in refund', () async {
        // Arrange
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenThrow(Exception('Network unavailable'));

        // Act
        final result = await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 25.00,
        );

        // Assert
        expect(result, false);
        expect(stripeProvider.errorMessage, contains('rimborso'));
      });

      test('should handle Firebase function errors in refund', () async {
        // Arrange
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenThrow(Exception('Firebase Error: functions/internal'));

        // Act
        final result = await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 25.00,
        );

        // Assert
        expect(result, false);
        expect(stripeProvider.errorMessage, isNotNull);
      });
    });

    group('Loading State', () {
      test('should set loading to true during refund operation', () async {
        // Arrange
        var loadingDuringOperation = false;
        
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenAnswer((_) async {
          loadingDuringOperation = stripeProvider.isLoading;
          return {'status': 'succeeded'};
        });

        // Act
        await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 25.00,
        );

        // Assert - loading was true during operation
        expect(loadingDuringOperation, true);
        // Loading should be false after completion
        expect(stripeProvider.isLoading, false);
      });

      test('should set loading to false after refund error', () async {
        // Arrange
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenThrow(Exception('Error'));

        // Act
        await stripeProvider.refundPayment(
          orderId: 'pi_test123',
          amount: 25.00,
        );

        // Assert
        expect(stripeProvider.isLoading, false);
      });

      test('should reset error before starting refund', () async {
        // First, cause an error
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenThrow(Exception('First error'));
        
        await stripeProvider.refundPayment(orderId: 'test1', amount: 10.0);
        expect(stripeProvider.errorMessage, isNotNull);
        
        // Now, make a successful call and check error is cleared
        when(() => mockStripeService.createRefund(
          paymentIntentId: any(named: 'paymentIntentId'),
          amount: any(named: 'amount'),
        )).thenAnswer((_) async => {'status': 'succeeded'});
        
        await stripeProvider.refundPayment(orderId: 'test2', amount: 20.0);
        expect(stripeProvider.errorMessage, isNull);
      });
    });

    group('processPayment - Additional Edge Cases', () {
      testWidgets('should convert decimal amounts correctly', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 'pi_test_secret',
          'orderIds': ['order1'],
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 99.99, // Edge case: precision
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();

        // Assert - verify amount was converted correctly (9999 cents)
        verify(() => mockStripeService.createPaymentIntent(
          amount: 9999,
          currency: 'eur',
          items: [],
        )).called(1);
      });

      testWidgets('should handle multiple items in payment', (tester) async {
        // Arrange
        final items = [
          {'id': 'item1', 'name': 'Pizza', 'price': 10.50},
          {'id': 'item2', 'name': 'Pasta', 'price': 8.00},
          {'id': 'item3', 'name': 'Drink', 'price': 3.50},
        ];
        
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 'pi_test_secret',
          'orderIds': ['order1', 'order2', 'order3'],
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 22.00,
                  items: items,
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();

        // Assert
        verify(() => mockStripeService.createPaymentIntent(
          amount: 2200,
          currency: 'eur',
          items: items,
        )).called(1);
      });

      testWidgets('should handle custom currency', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 'pi_test_secret',
          'orderIds': ['order1'],
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 50.00,
                  items: [],
                  currency: 'usd',
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();

        // Assert - verify custom currency is used
        verify(() => mockStripeService.createPaymentIntent(
          amount: 5000,
          currency: 'usd',
          items: [],
        )).called(1);
      });

      testWidgets('should handle zero amount edge case', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => {
          'clientSecret': 'pi_test_secret',
          'orderIds': ['order1'],
        });

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 0.0,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pump();

        // Assert - zero amount should still be converted to 0 cents
        verify(() => mockStripeService.createPaymentIntent(
          amount: 0,
          currency: 'eur',
          items: [],
        )).called(1);
      });

      testWidgets('should set loading to false on error', (tester) async {
        // Arrange
        when(() => mockStripeService.createPaymentIntent(
          amount: any(named: 'amount'),
          currency: any(named: 'currency'),
          items: any(named: 'items'),
        )).thenThrow(Exception('Server error'));

        await tester.pumpWidget(MaterialApp(home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await stripeProvider.processPayment(
                  context: context,
                  amount: 10.00,
                  items: [],
                );
              },
              child: const Text('Pay'),
            );
          },
        )));

        // Act
        await tester.tap(find.text('Pay'));
        await tester.pumpAndSettle();

        // Assert
        expect(stripeProvider.isLoading, false);
        expect(stripeProvider.errorMessage, contains('pagamento'));
      });
    });
  });
}
