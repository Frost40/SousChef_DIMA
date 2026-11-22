# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in **SousChef**, please report it responsibly rather than opening a public issue:

- Contact the maintainers privately via GitHub Security Advisories (**Security → Advisories → Report a vulnerability**).
- Include reproduction steps, affected component (`lib/`, `functions/`, or native platform config), and potential impact.

## Secret & Key Management

- **Client environment variables (`.env`)**: Never commit `.env` or `.env.*` files. Use [`.env.example`](.env.example) as a template.
- **Native Maps keys**: Android reads `GOOGLE_MAPS_API_KEY` via Gradle `manifestPlaceholders` (from environment or `.env`); iOS reads `$(GOOGLE_MAPS_API_KEY)` from `ios/Flutter/Secrets.xcconfig` (gitignored). Restrict Google Maps API keys in Google Cloud Console by Android package + SHA-1 fingerprint, iOS bundle ID, and enabled APIs (Maps SDK for Android/iOS, Places API).
- **Server-side secrets**: `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` are managed exclusively through Google Cloud Secret Manager (`firebase functions:secrets:set`) and are never exposed to the Flutter client.
- **Firebase hardening**: Client Firebase configuration (`google-services.json`, `firebase_options.dart`) identifies the Firebase project and must be paired with strict **Firestore Security Rules**, **Firebase Storage Rules**, and **Firebase App Check** in the Firebase Console.
- **Release builds**: Configure a production keystore via `android/key.properties` (gitignored) before publishing release APKs/AABs.
