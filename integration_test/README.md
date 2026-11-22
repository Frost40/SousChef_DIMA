# Integration Tests - Setup Guide

## Overview

Questi sono **veri test di integrazione** che usano:
- ✅ **Firebase Authentication reale**
- ✅ **Firestore Database reale**
- ✅ **Provider State Management reale**
- ✅ **Nessun Mock!**

## Prerequisites

### 1. Crea un utente di test in Firebase

Nel Firebase Console del tuo progetto:

1. Vai su **Authentication** → **Users**
2. Clicca su **Add user** e crea gli account di test dedicati (cliente + ristoratore)
3. Passa le credenziali via `--dart-define` durante l'esecuzione:
   ```bash
   flutter test integration_test/ \
     --dart-define=TEST_EMAIL=your-test-user@example.com \
     --dart-define=TEST_PASSWORD=your-test-password \
     --dart-define=TEST_OWNER_EMAIL=your-test-owner@example.com \
     --dart-define=TEST_OWNER_PASSWORD=your-owner-password
   ```

> **Nota**: Non salvare mai credenziali reali nel repository; usa sempre `--dart-define` o un project Firebase Emulator isolato.

### 2. (Opzionale) Usa Firebase Emulators per i test

Se vuoi evitare di usare il database di produzione, puoi configurare Firebase Emulators:

```bash
# Installa Firebase CLI se non l'hai già
npm install -g firebase-tools

# Inizializza gli emulators
firebase init emulators

# Avvia gli emulators
firebase emulators:start
```

Poi modifica `lib/config/environment.dart` per puntare agli emulators in modalità test.

## Come Eseguire i Test

### Su Android Emulator

```bash
# 1. Avvia un emulatore Android
flutter emulators --launch <emulator_id>

# 2. Verifica che sia in running
flutter devices

# 3. Esegui i test
flutter test integration_test/login_to_home_flow_test.dart
```

### Su iOS Simulator

```bash
# 1. Avvia un simulatore iOS
open -a Simulator

# 2. Verifica che sia in running
flutter devices

# 3. Esegui i test
flutter test integration_test/login_to_home_flow_test.dart -d <simulator_id>
```

### Su Dispositivo Fisico

```bash
# 1. Collega il dispositivo via USB
# 2. Abilita USB debugging (Android) o Developer mode (iOS)
# 3. Verifica connessione
flutter devices

# 4. Esegui i test
flutter test integration_test/login_to_home_flow_test.dart -d <device_id>
```

### Esegui tutti i test di integrazione

```bash
flutter test integration_test/
```

## Test Implementati

### 1. **Complete login flow with real Firebase**
- ✅ Lancia l'app reale
- ✅ Verifica di essere sulla LoginScreen
- ✅ Inserisce credenziali reali
- ✅ Esegue il login
- ✅ Verifica di essere nella HomeScreen
- ✅ Verifica che i dati utente siano caricati

### 2. **Login with wrong credentials shows error**
- ✅ Testa il flusso di errore con credenziali sbagliate
- ✅ Verifica che Firebase ritorni un errore
- ✅ Verifica che l'utente rimanga sulla LoginScreen

### 3. **Login with empty fields shows validation**
- ✅ Verifica la validazione locale dei campi
- ✅ Assicura che non venga fatta nemmeno la chiamata a Firebase

### 4. **Complete flow: Login → Navigate to Favorites → Logout**
- ✅ Login completo
- ✅ Navigazione tra le tab
- ✅ Logout
- ✅ Verifica di tornare alla LoginScreen

### 5. **Login persists across app restart**
- ✅ Verifica che lo stato di autenticazione persista

### 6. **Navigate through all tabs**
- ✅ Testa la navigazione in tutte le tab della BottomNavigationBar

## Struttura dei File

```
integration_test/
  └── login_to_home_flow_test.dart  # Test di integrazione completi

lib/
  ├── config/
  │   └── environment.dart           # Configurazione environment (dev/test/prod)
  └── main.dart                      # Modificato per supportare testOptions
```

## Differenze dai Test Unitari

| Aspetto | Unit Test | Integration Test |
|---------|-----------|------------------|
| **Providers** | Mock | Reali |
| **Firebase** | Mock | Reale |
| **Database** | Fake | Firestore Reale |
| **Auth** | Simulato | Firebase Auth Reale |
| **Network** | Mock | Chiamate API Reali |
| **Cosa testa** | Logica isolata | **Sistema completo** |
| **Velocità** | Velocissimi (~ms) | Più lenti (~secondi) |
| **Affidabilità** | Alta (isolati) | Altissima (sistema reale) |

## Best Practices

### 1. **Usa dati di test dedicati**
- Non testare mai con dati di produzione
- Crea utenti specifici per i test
- Usa un progetto Firebase separato se possibile

### 2. **Pulisci dopo i test**
- Se crei dati durante i test, eliminali alla fine
- Considera l'uso di Firebase Emulators per evitare accumulo di dati

### 3. **Gestisci i timeout**
- I test di integrazione sono più lenti
- Usa timeout appropriati: `Duration(seconds: 3-5)`
- Usa `pumpAndSettle()` per aspettare le animazioni

### 4. **Test indipendenti**
- Ogni test deve poter essere eseguito indipendentemente
- Non dipendere dallo stato lasciato da test precedenti

### 5. **Gestione errori**
- Testa sia i flussi di successo che di errore
- Verifica i messaggi di errore da Firebase

## Troubleshooting

### Test falliscono con "Element not found"

```dart
// Aumenta i timeout
await tester.pumpAndSettle(const Duration(seconds: 10));

// Usa find.textContaining() invece di find.text()
expect(find.textContaining('Login'), findsOneWidget);
```

### Firebase non si connette

```bash
# Verifica di aver eseguito
flutter pub get

# Assicurati che google-services.json (Android) 
# e GoogleService-Info.plist (iOS) siano configurati correttamente
```

### Test lenti

- Usa Firebase Emulators invece di Firebase reale
- Riduci il numero di `pumpAndSettle()`
- Esegui i test su emulatore invece che dispositivo fisico

## CI/CD Integration

Per eseguire questi test in CI/CD, dovrai:

1. Configurare Firebase Emulators
2. Usare un emulatore Android/iOS headless
3. Fornire le credenziali Firebase in modo sicuro

Esempio GitHub Actions:

```yaml
- name: Run Integration Tests
  run: |
    firebase emulators:exec --only auth,firestore \
    "flutter test integration_test/"
```

## Risorse Utili

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Integration Test Package](https://pub.dev/packages/integration_test)

---

**Happy Testing! 🧪**
