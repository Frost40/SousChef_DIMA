import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/stripe.dart';

class StripeProvider with ChangeNotifier {
  final StripeService _stripeService = StripeService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? _lastPaymentResult;

  // Inizializza Stripe
  static Future<void> initialize() async {
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    if (publishableKey == null || publishableKey.isEmpty) {
      throw Exception('Chiave pubblicabile di Stripe non trovata');
    }
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    required List<Map<String, dynamic>> items,
    String currency = 'eur',
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Converti l'importo in centesimi
      final amountInCents = (amount * 100).toInt();

      // 2. Chiama la Cloud Function per creare l'intent
      final paymentData = await _stripeService.createPaymentIntent(
        amount: amountInCents,
        currency: currency,
        items: items,
      );

      final clientSecret = paymentData['clientSecret'];
      final orderIds = paymentData['orderIds'];

      // 3. Configura il foglio di pagamento Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SousChef',
          style: ThemeMode.system,
        ),
      );

      // 4. Presenta il foglio di pagamento
      await Stripe.instance.presentPaymentSheet();

      // 5. Salva il risultato per riferimento futuro
      _lastPaymentResult = {
        'success': true,
        'orderIds': orderIds,
      };

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;

      if (e is StripeException) {
        _errorMessage = 'Errore Stripe: ${e.error.localizedMessage}';
      } else {
        _errorMessage = 'Errore durante il pagamento: $e';
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> refundPayment({
    required String paymentIntentId,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final amountInCents = (amount * 100).toInt();
      await _stripeService.createRefund(
        paymentIntentId: paymentIntentId,
        amount: amountInCents,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il rimborso: $e';
      notifyListeners();
      return false;
    }
  }
}