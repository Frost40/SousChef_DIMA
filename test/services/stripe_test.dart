import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/services/stripe.dart';

/// Mock classes for Firebase Functions
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult<T> extends Mock
    implements HttpsCallableResult<T> {}

void main() {
  group('StripeService Tests', () {
    late StripeService stripeService;
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      stripeService = StripeService(functions: mockFunctions);
    });

    group('createPaymentIntent', () {
      test('should call createPaymentIntent callable with correct parameters',
          () async {
        // Arrange
        const amount = 1000;
        const currency = 'eur';
        final items = [
          {'name': 'Pizza', 'price': 1200}
        ];
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('createPaymentIntent'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'clientSecret': 'pi_xxx_secret_xxx',
          'orderIds': ['order1', 'order2'],
        });

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: amount,
          currency: currency,
          items: items,
        );

        // Assert
        expect(result['clientSecret'], 'pi_xxx_secret_xxx');
        expect(result['orderIds'], ['order1', 'order2']);
        verify(() => mockFunctions.httpsCallable('createPaymentIntent'))
            .called(1);
        verify(() => mockCallable.call({
              'amount': amount,
              'currency': currency,
              'items': items,
            })).called(1);
      });

      test('should use empty list when items is null', () async {
        // Arrange
        const amount = 500;
        const currency = 'usd';
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('createPaymentIntent'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'clientSecret': 'pi_test_secret',
          'orderIds': ['order1'],
        });

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: amount,
          currency: currency,
        );

        // Assert
        expect(result['clientSecret'], 'pi_test_secret');
        verify(() => mockCallable.call({
              'amount': amount,
              'currency': currency,
              'items': [],
            })).called(1);
      });

      test('should throw exception when response data is null', () async {
        // Arrange
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>?>();

        when(() => mockFunctions.httpsCallable('createPaymentIntent'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn(null);

        // Act & Assert
        expect(
          () => stripeService.createPaymentIntent(
            amount: 1000,
            currency: 'eur',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid response from server'),
          )),
        );
      });

      test('should throw exception when clientSecret is null', () async {
        // Arrange
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('createPaymentIntent'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'clientSecret': null,
          'orderIds': ['order1'],
        });

        // Act & Assert
        expect(
          () => stripeService.createPaymentIntent(
            amount: 1000,
            currency: 'eur',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid response from server'),
          )),
        );
      });

      test('should throw exception when orderIds is null', () async {
        // Arrange
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('createPaymentIntent'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'clientSecret': 'pi_xxx_secret',
          'orderIds': null,
        });

        // Act & Assert
        expect(
          () => stripeService.createPaymentIntent(
            amount: 1000,
            currency: 'eur',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid response from server'),
          )),
        );
      });

      test('should handle FirebaseFunctionsException', () async {
        // Arrange
        when(() => mockFunctions.httpsCallable('createPaymentIntent'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenThrow(
          FirebaseFunctionsException(
            code: 'invalid-argument',
            message: 'Amount must be positive',
          ),
        );

        // Act & Assert
        expect(
          () => stripeService.createPaymentIntent(
            amount: -100,
            currency: 'eur',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Firebase Error: invalid-argument'),
          )),
        );
      });

      test('should handle generic exceptions', () async {
        // Arrange
        when(() => mockFunctions.httpsCallable('createPaymentIntent'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any()))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => stripeService.createPaymentIntent(
            amount: 1000,
            currency: 'eur',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error creating payment intent'),
          )),
        );
      });
    });

    group('createRefund', () {
      test('should call createRefund callable with correct parameters',
          () async {
        // Arrange
        const paymentIntentId = 'pi_1234567890';
        const amount = 500;
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('createRefund'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'status': 'succeeded',
          'amount': 500,
        });

        // Act
        final result = await stripeService.createRefund(
          paymentIntentId: paymentIntentId,
          amount: amount,
        );

        // Assert
        expect(result['status'], 'succeeded');
        expect(result['amount'], 500);
        verify(() => mockFunctions.httpsCallable('createRefund')).called(1);
        verify(() => mockCallable.call({
              'payment_intent_id': paymentIntentId,
              'amount': amount,
            })).called(1);
      });

      test('should return response data from refund', () async {
        // Arrange
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();
        final expectedData = {
          'id': 're_123',
          'status': 'succeeded',
          'amount': 1000,
          'currency': 'eur',
        };

        when(() => mockFunctions.httpsCallable('createRefund'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn(expectedData);

        // Act
        final result = await stripeService.createRefund(
          paymentIntentId: 'pi_test',
          amount: 1000,
        );

        // Assert
        expect(result, expectedData);
      });

      test('should handle FirebaseFunctionsException on refund', () async {
        // Arrange
        when(() => mockFunctions.httpsCallable('createRefund'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenThrow(
          FirebaseFunctionsException(
            code: 'not-found',
            message: 'Payment intent not found',
          ),
        );

        // Act & Assert
        expect(
          () => stripeService.createRefund(
            paymentIntentId: 'pi_invalid',
            amount: 500,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Errore Firebase: not-found'),
          )),
        );
      });

      test('should handle generic exceptions on refund', () async {
        // Arrange
        when(() => mockFunctions.httpsCallable('createRefund'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any()))
            .thenThrow(Exception('Connection timeout'));

        // Act & Assert
        expect(
          () => stripeService.createRefund(
            paymentIntentId: 'pi_test',
            amount: 500,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Errore nella richiesta di rimborso'),
          )),
        );
      });
    });

    group('Service Initialization', () {
      test('should initialize with injected functions instance', () {
        final service = StripeService(functions: mockFunctions);
        expect(service, isNotNull);
      });

      test('should have createPaymentIntent method', () {
        expect(stripeService.createPaymentIntent, isNotNull);
      });

      test('should have createRefund method', () {
        expect(stripeService.createRefund, isNotNull);
      });
    });
  });
}
