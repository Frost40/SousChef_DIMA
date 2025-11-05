# Configurazione Google Maps API

## ✅ Componenti Creati

1. **MapViewer Widget** (`lib/widgets/map_viewer.dart`)
   - Widget riutilizzabile per mostrare mappe Google Maps
   - Centrato su Milano di default (lat: 45.4642, lng: 9.1900)
   - Include marker opzionale e controlli zoom

2. **Home Screen aggiornato** (`lib/screens/home_screen.dart`)
   - Bottone "Apri Mappa Milano" che apre il MapViewer
   - Design Material 3 con icona mappa

## 🔑 Configurazione Necessaria

### 1. Ottieni la Google Maps API Key

1. Vai su [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuovo progetto o seleziona uno esistente
3. Abilita le seguenti API:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
4. Vai su "Credentials" → "Create Credentials" → "API Key"
5. Copia la tua API key

### 2. Configura Android

Apri `android/app/src/main/AndroidManifest.xml` e aggiungi dentro `<application>`:

```xml
<application>
    <!-- ... altre configurazioni ... -->
    
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="LA_TUA_API_KEY_QUI"/>
        
</application>
```

### 3. Configura iOS

Apri `ios/Runner/AppDelegate.swift` e modifica il file così:

```swift
import UIKit
import Flutter
import GoogleMaps  // Aggiungi questa riga

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("LA_TUA_API_KEY_QUI")  // Aggiungi questa riga
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Permessi iOS (opzionale per location)

Se vuoi usare la posizione dell'utente, aggiungi in `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Questa app ha bisogno di accedere alla tua posizione per mostrarti i ristoranti vicini</string>
```

## 🎨 Funzionalità del Widget

### MapViewer

```dart
// Uso base - Mappa di Milano
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MapViewer(),
  ),
);

// Personalizzato
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MapViewer(
      latitude: 45.4642,
      longitude: 9.1900,
      zoom: 14.0,
      markerTitle: 'Centro di Milano',
    ),
  ),
);
```

### Parametri disponibili:
- `latitude` - Latitudine iniziale (default: 45.4642 - Milano)
- `longitude` - Longitudine iniziale (default: 9.1900 - Milano)
- `zoom` - Livello zoom iniziale (default: 12.0)
- `markerTitle` - Titolo del marker centrale (opzionale)

### Controlli della mappa:
- ✅ Zoom con pinch gesture
- ✅ Pan per muovere la mappa
- ✅ Bottone per ricentrare su Milano
- ✅ Bussola per orientamento
- ✅ Visualizzazione edifici 3D

## 🚀 Test

1. Configura le API keys come descritto sopra
2. Esegui l'app:
   ```bash
   flutter run
   ```
3. Premi il bottone "Apri Mappa Milano" nella home screen
4. La mappa si aprirà centrata su Milano

## 🔮 Prossimi Sviluppi

Puoi estendere il MapViewer per:
- Mostrare marker multipli (es. ristoranti)
- Aggiungere clustering per molti marker
- Implementare ricerca sulla mappa
- Mostrare il percorso verso un ristorante
- Filtrare ristoranti per distanza

## ⚠️ Note Importanti

1. **API Key Security**: Per produzione, limita la tua API key a specifici bundle/package names
2. **Quota Limiti**: Google Maps ha limiti gratuiti, monitora l'uso
3. **Testing**: Testa sia su iOS che Android perché la configurazione è diversa
4. **Simulatore iOS**: Potrebbe non funzionare perfettamente, testa su device reale

## 📱 Problemi Comuni

### Android - Mappa vuota/grigia
- Verifica che la API key sia corretta in AndroidManifest.xml
- Assicurati di aver abilitato "Maps SDK for Android"
- Controlla i log con `flutter run --verbose`

### iOS - Crash all'avvio mappa
- Verifica la configurazione in AppDelegate.swift
- Assicurati di aver abilitato "Maps SDK for iOS"
- Pulisci e rebuilda: `flutter clean && flutter run`

### Mappa lenta
- Riduci il numero di marker
- Usa clustering per molti punti
- Ottimizza le immagini dei marker personalizzati
