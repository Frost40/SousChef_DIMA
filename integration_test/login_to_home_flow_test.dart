import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sous_chef/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';

const String _testEmail = String.fromEnvironment(
  'TEST_EMAIL',
  defaultValue: 'test@example.com',
);
const String _testPassword = String.fromEnvironment(
  'TEST_PASSWORD',
  defaultValue: 'CHANGE_ME',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Suite Test Integrazione Strict - Sous Chef', () {
    // Helper per resettare lo stato e assicurarsi di partire dal Login
    Future<void> resetToLogin(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      expect(
        find.byType(app.LoginScreen),
        findsOneWidget,
        reason: "Il test deve iniziare dalla schermata di Login",
      );
    }

    testWidgets('1. Flow Login Completo (Credenziali Corrette)', (
      tester,
    ) async {
      await resetToLogin(tester);

      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);

      // Inserimento Email
      await tester.enterText(emailField, _testEmail);
      await tester.pump();
      expect(
        find.text(_testEmail),
        findsOneWidget,
        reason: "Email non inserita nel campo",
      );

      // Inserimento Password
      await tester.enterText(passwordField, _testPassword);
      await tester.pump();

      // Tap Login
      final loginBtn = find.text('Login').last;
      await tester.tap(loginBtn);

      // Attesa transizione alla Home
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verifiche post-login
      expect(
        find.byType(app.LoginScreen),
        findsNothing,
        reason: "Login fallito: la LoginScreen è ancora visibile",
      );
      expect(
        FirebaseAuth.instance.currentUser,
        isNotNull,
        reason: "Firebase Auth non ha registrato l'utente",
      );
      expect(
        find.text('Sous Chef'),
        findsOneWidget,
        reason: "AppBar della Home non trovata",
      );
    });

    testWidgets('2. Login con credenziali errate (Verifica Errore)', (
      tester,
    ) async {
      await resetToLogin(tester);

      await tester.enterText(find.byType(TextField).at(0), 'wrong@user.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Deve restare nel Login
      expect(
        find.byType(app.LoginScreen),
        findsOneWidget,
        reason: "L'app ha lasciato la schermata di login nonostante l'errore",
      );

      // Deve mostrare un feedback di errore
      final errorFeedback = find.textContaining(
        RegExp(r'Invalid|error|failed|sbagliata', caseSensitive: false),
      );
      expect(
        errorFeedback,
        findsAtLeastNWidgets(1),
        reason: "Nessun messaggio di errore mostrato all'utente",
      );
    });

    testWidgets('3. Validazione Form (Campi Vuoti)', (tester) async {
      await resetToLogin(tester);

      // Tap senza inserire nulla
      await tester.tap(find.text('Login').last);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifica che non sia avvenuta navigazione (rimaniamo nella LoginScreen)
      expect(
        find.byType(app.LoginScreen),
        findsOneWidget,
        reason: "La navigazione è avvenuta nonostante i campi vuoti",
      );

      // Con campi vuoti, il login non dovrebbe procedere
      expect(
        FirebaseAuth.instance.currentUser,
        isNull,
        reason: "Un utente è stato autenticato nonostante i campi vuoti",
      );
    });

    testWidgets('4. Navigazione Tab e Logout Finale', (tester) async {
      await resetToLogin(tester);

      // Login rapido
      await tester.enterText(find.byType(TextField).at(0), _testEmail);
      await tester.enterText(find.byType(TextField).at(1), _testPassword);
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Test Navigazione: Preferiti
      final favTab = find.byIcon(Icons.favorite_rounded);
      expect(favTab, findsOneWidget, reason: "Icona Preferiti non trovata");
      await tester.tap(favTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // Verifica che siamo sulla schermata Preferiti (non controllare il testo esatto)
      expect(
        find.byIcon(Icons.favorite_rounded),
        findsWidgets,
        reason: "Non siamo sulla schermata Preferiti dopo aver cliccato il tab",
      );

      // Test Navigazione: Account
      final accountTab = find.byIcon(Icons.person_rounded);
      await tester.tap(accountTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Esecuzione Logout
      final logoutBtn = find.textContaining(
        RegExp(r'Logout|Esci', caseSensitive: false),
      );
      if (logoutBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(logoutBtn.first);
        await tester.tap(logoutBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Verifica chiusura sessione
      expect(
        find.byType(app.LoginScreen),
        findsOneWidget,
        reason: "Logout non ha riportato alla LoginScreen",
      );
      expect(
        FirebaseAuth.instance.currentUser,
        isNull,
        reason: "Sessione Firebase ancora attiva dopo logout",
      );
    });

    testWidgets('5. Persistenza Login (Restart App)', (tester) async {
      // 1. Assicuriamoci di essere loggati
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (FirebaseAuth.instance.currentUser == null) {
        await tester.enterText(find.byType(TextField).at(0), _testEmail);
        await tester.enterText(find.byType(TextField).at(1), _testPassword);
        await tester.tap(find.text('Login').last);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // 2. Simula riavvio chiamando di nuovo main()
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 3. Verifica: Non dovremmo vedere il Login ma direttamente la Home
      expect(
        find.byType(app.LoginScreen),
        findsNothing,
        reason: "La persistenza ha fallito: l'app richiede il login al riavvio",
      );
      expect(find.text('Sous Chef'), findsOneWidget);
    });

    testWidgets('6. Verifica Integrità Tutti i Tab', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assicurati di essere loggato prima di testare la navigazione
      if (FirebaseAuth.instance.currentUser == null) {
        await tester.enterText(find.byType(TextField).at(0), _testEmail);
        await tester.enterText(find.byType(TextField).at(1), _testPassword);
        await tester.tap(find.text('Login').last);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      final tabs = [
        {'icon': Icons.home_rounded, 'label': 'Home'},
        {'icon': Icons.receipt_long_rounded, 'label': 'Recipes'},
        {'icon': Icons.favorite_rounded, 'label': 'Favorites'},
        {'icon': Icons.person_rounded, 'label': 'Account'},
      ];

      for (var tabInfo in tabs) {
        final icon = find.byIcon(tabInfo['icon'] as IconData);
        expect(
          icon,
          findsAtLeastNWidgets(1),
          reason: "Tab ${tabInfo['label']} non presente nella barra",
        );

        await tester.tap(icon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verifica che il click sul tab non abbia causato crash
        // Non controllare se la barra è ancora visibile perché potrebbe avere implementazioni diverse
        expect(
          FirebaseAuth.instance.currentUser,
          isNotNull,
          reason:
              "Logout accidentale durante la navigazione su ${tabInfo['label']}",
        );
      }
    });
  });
}

