import 'package:firebase_core/firebase_core.dart';
import 'package:sous_chef/firebase_options.dart';

/// Environment types for the application
enum Environment { dev, test, production }

/// Application configuration manager
class AppConfig {
  static Environment env = Environment.dev;

  /// Get Firebase options based on current environment
  static FirebaseOptions get firebaseOptions {
    switch (env) {
      case Environment.test:
        // For integration tests, you can:
        // 1. Use a separate Firebase test project
        // 2. Use Firebase Emulators
        // For now, using the same options (can be changed later)
        return DefaultFirebaseOptions.currentPlatform;
      case Environment.dev:
        return DefaultFirebaseOptions.currentPlatform;
      case Environment.production:
        return DefaultFirebaseOptions.currentPlatform;
    }
  }

  /// Check if running in test mode
  static bool get isTest => env == Environment.test;

  /// Check if running in production
  static bool get isProduction => env == Environment.production;

  /// Check if running in development
  static bool get isDev => env == Environment.dev;
}
