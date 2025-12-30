import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/stripe.dart';

class StripeProvider with ChangeNotifier {
  final StripeService _stripeService;
  bool _isLoading = false;
  String? _errorMessage;

  /// Constructor with dependency injection for testability
  /// In production, defaults to real service instance
  StripeProvider({
    StripeService? stripeService,
  }) : _stripeService = stripeService ?? StripeService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Inizializza Stripe
  static Future<void> initialize() async {
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    if (publishableKey == null || publishableKey.isEmpty) {
      throw Exception('Chiave pubblicabile di Stripe non trovata');
    }
    Stripe.publishableKey = publishableKey;
    Stripe.urlScheme = 'souschef-stripe';
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
      print('[StripeProvider] Starting payment process...');

      // 1. Converti l'importo in centesimi
      final amountInCents = (amount * 100).toInt();

      // 2. Chiama la Cloud Function per creare l'intent
      final paymentData = await _stripeService.createPaymentIntent(
        amount: amountInCents,
        currency: currency,
        items: items,
      );
      print('[StripeProvider] Received payment data from server: $paymentData');

      final clientSecret = paymentData['clientSecret'];
      final orderIds = paymentData['orderIds'];

      // [FIX] Add a null and type check for the client secret to prevent a native crash.
      // The flutter_stripe plugin can crash the app if this value is not a valid string.
      print('[StripeProvider] Validating client secret...');
      if (clientSecret == null ||
          clientSecret is! String ||
          clientSecret.isEmpty) {
        print(
          '[StripeProvider] Client secret is INVALID. Secret: "$clientSecret"',
        );
        throw Exception('Il client secret ricevuto dal server non è valido.');
      }
      print(
        '[StripeProvider] Client secret is valid. Initializing payment sheet...',
      );

      // Check context is still mounted before proceeding
      if (!context.mounted) {
        throw Exception('Context is no longer mounted');
      }

      // 3. Configura il foglio di pagamento Stripe with minimal configuration
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SousChef',
          style: ThemeMode.system,
        ),
      );
      print('[StripeProvider] Payment sheet initialized. Presenting...');

      // 4. Ensure context is valid right before presentation
      if (!context.mounted) {
        throw Exception('Context was unmounted during initialization');
      }

      // 5. Present on main thread with try-catch for iOS specific issues
      try {
        await Stripe.instance.presentPaymentSheet();
        print('[StripeProvider] Payment sheet presented successfully.');
      } on StripeException catch (e) {
        // Handle user cancellation gracefully
        if (e.error.code == FailureCode.Canceled) {
          print('[StripeProvider] Payment was cancelled by user');
          _isLoading = false;
          notifyListeners();
          return false;
        }
        rethrow;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('[StripeProvider] An error occurred in processPayment: $e');
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
    required String orderId,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final amountInCents = (amount * 100).toInt();
      await _stripeService.createRefund(
        paymentIntentId: orderId,
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
