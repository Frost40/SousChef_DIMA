import 'package:cloud_functions/cloud_functions.dart';

class StripeService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final callable = _functions.httpsCallable('createPaymentIntent');
      final response = await callable.call({
        'amount': amount,
        'currency': currency,
        'items': items ?? [],
      });

      final data = response.data;
      if (data == null || data['clientSecret'] == null || data['orderIds'] == null) {
        throw Exception('Invalid response from server');
      }

      return {
        'clientSecret': data['clientSecret'],
        'orderIds': data['orderIds'],
      };
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Firebase Error: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<Map<String, dynamic>> createRefund({
    required String paymentIntentId,
    required int amount,
  }) async {
    try {
      final callable = _functions.httpsCallable('createRefund');
      final response = await callable.call({
        'payment_intent_id': paymentIntentId,
        'amount': amount,
      });

      return response.data;
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Errore Firebase: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Errore nella richiesta di rimborso: $e');
    }
  }
}