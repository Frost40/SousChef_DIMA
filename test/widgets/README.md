# Widget Testing - SousChef

Documentazione completa dei test per i widget dell'applicazione SousChef.

## 📊 Panoramica

- **Totale Test Widget**: 313
- **File di Test**: 37
- **Framework**: Flutter Test + Mocktail
- **Coverage**: Widget UI, interazioni, stati

---

## 🚀 Comandi per Eseguire i Test

### Eseguire tutti i widget test
```bash
flutter test test/widgets/
```

### Eseguire un singolo file di test
```bash
flutter test test/widgets/<nome_file>_test.dart
```

### Eseguire test con output dettagliato
```bash
flutter test test/widgets/ --reporter expanded
```

### Eseguire test con coverage
```bash
flutter test test/widgets/ --coverage
```

### Eseguire test in parallelo (più veloce)
```bash
flutter test test/widgets/ --concurrency=4
```

### Eseguire test specifici per nome
```bash
flutter test test/widgets/ --name "renders correctly"
```

---

## 📁 Struttura dei Test

```
test/
├── helpers/
│   ├── pump_app.dart           # Helper per wrappare widget con providers
│   └── mock_providers.dart     # Mock dei provider (Mocktail)
├── mocks/
│   └── ...                     # Mock condivisi
└── widgets/
    ├── README.md               # Questo file
    └── *_test.dart             # File di test widget
```

---

## 📋 Elenco Widget Test

### 🔘 Bottoni e Interazioni

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `AnimatedButton` | `animated_button_test.dart` | ~8 | Bottone con animazione al tap |
| `CircularButton` | `circular_button_test.dart` | ~8 | Bottone circolare con icona |
| `CustomSocialButton` | `custom_social_button_test.dart` | ~4 | Bottoni social login (Google, Apple) |
| `FavoriteIconButton` | `favorite_icon_button_test.dart` | ~16 | Toggle preferiti con animazione |
| `ImageUploadButton` | `image_upload_button_test.dart` | ~20 | Upload immagini con preview |
| `PersonalizedButton` | `personalized_button_test.dart` | ~12 | Bottone customizzabile |

### 📝 Input e Form

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `AuthInputField` | `auth_input_field_test.dart` | ~6 | Campo input autenticazione |
| `PasswordFieldSignup` | `password_field_signup_test.dart` | ~14 | Campo password con validazione |
| `PersonalizedTextfield` | `personalized_textfield_test.dart` | ~8 | TextField personalizzato |
| `CircularNumberInput` | `circular_number_input_test.dart` | ~18 | Selezione numerica circolare |
| `CustomDropdownMenu` | `custom_dropdown_menu_test.dart` | ~16 | Menu dropdown customizzato |
| `VerificationCodeInput` | `verification_code_input_test.dart` | ~10 | Input codice OTP a 6 cifre |

### 🏠 Account e Profilo

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `AccountField` | `account_field_test.dart` | ~4 | Campo info account |
| `AccountSettingsField` | `account_settings_field_test.dart` | ~8 | Campo impostazioni account |
| `ThemeSwitch` | `theme_switch_test.dart` | ~20 | Toggle tema chiaro/scuro |

### 🍽️ Ristoranti

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `RestaurantListTile` | `restaurant_list_tile_test.dart` | ~24 | Tile ristorante in lista |
| `RestaurantTile` | `restaurant_tile_test.dart` | ~6 | Card ristorante principale |
| `RestaurantInfo` | `restaurant_info_test.dart` | ~4 | Info dettagliate ristorante |
| `AddressField` | `address_field_test.dart` | ~8 | Campo indirizzo editabile |
| `AddressDisplay` | `address_display_test.dart` | ~4 | Visualizzazione indirizzo |
| `ServiceType` | `service_type_test.dart` | ~12 | Toggle delivery/takeaway |
| `OpenCloseButton` | `open_close_button_test.dart` | ~10 | Stato aperto/chiuso ristorante |
| `PriceTag` | `price_tag_test.dart` | ~20 | Tag prezzo con valuta |
| `DistanceSelector` | `distance_selector_test.dart` | ~18 | Slider selezione distanza |
| `MapViewer` | `map_viewer_test.dart` | ~8 | Viewer mappa con markers |

### 🍕 Menu e Piatti

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `MenuItem` | `menu_item_test.dart` | ~7 | Item menu con prezzo |
| `DishPopupDialog` | `dish_popup_dialog_test.dart` | ~2 | Dialog dettaglio piatto |
| `DishAvailabilityButton` | `dish_availability_button_test.dart` | ~11 | Toggle disponibilità piatto |

### 📦 Ordini

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `OrderCard` | `order_card_test.dart` | ~12 | Card ordine espandibile |
| `OrderTile` | `order_tile_test.dart` | ~10 | Tile singolo ordine |

### 🧭 Navigazione

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `CustomNavigationBar` | `custom_navigation_bar_test.dart` | ~6 | Bottom navigation bar |
| `NavigationTabbar` | `navigation_tabbar_test.dart` | ~6 | Tab bar navigazione |

### 📅 Calendario e Data

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `CalendarWidget` | `calendar_widget_test.dart` | ~4 | DateTimePicker customizzato |

### 💬 Dialog e Alert

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `CustomAlertDialog` | `custom_alert_dialog_test.dart` | ~8 | Dialog alert personalizzato |

### 🎨 UI Components

| Widget | File | N° Test | Descrizione |
|--------|------|---------|-------------|
| `DividerWithText` | `or_divider_test.dart` | ~10 | Divider con testo centrale |
| `ShakeWidget` | `shake_widget_test.dart` | ~4 | Animazione shake per errori |
| `ChatIconWithBadge` | `chat_icon_with_badge_test.dart` | ~6 | Icona chat con badge notifiche |

---

## 🔧 Helper di Test

### `pump_app.dart`

Estensione per `WidgetTester` che semplifica il setup dei test:

```dart
// Wrappa il widget con MaterialApp e tutti i provider necessari
await tester.pumpApp(MyWidget());

// Wrappa solo con MaterialApp (senza provider)
await tester.pumpWidget_(MyWidget());

// Wrappa con Scaffold (utile per widget che richiedono Scaffold)
await tester.pumpAppWithScaffold(MyWidget());
```

### `mock_providers.dart`

Mock dei provider usando Mocktail:

```dart
class MockThemeProvider extends Mock implements ThemeProvider {}
class MockUserProvider extends Mock implements UserProvider {}
// ... altri mock
```

---

## 🧪 Struttura di un Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/my_widget.dart';
import '../helpers/pump_app.dart';

void main() {
  group('MyWidget', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpApp(const MyWidget(title: 'Test'));
      
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('handles tap', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        MyWidget(onTap: () => tapped = true),
      );
      
      await tester.tap(find.byType(MyWidget));
      await tester.pump();
      
      expect(tapped, isTrue);
    });
  });
}
```

---

## 📈 Coverage

Per generare il report di coverage:

```bash
# Genera coverage
flutter test test/widgets/ --coverage

# Genera report HTML (richiede lcov)
genhtml coverage/lcov.info -o coverage/html

# Apri report
open coverage/html/index.html
```

---

## ⚠️ Note

- I widget che usano `NetworkImage` vengono testati come unit test (non widget test) per evitare errori HTTP
- I widget con dipendenze complesse da provider usano test delle proprietà
- Alcuni widget richiedono `pumpAndSettle()` per attendere le animazioni

---

## 🔄 Aggiornamento Test

Quando aggiungi un nuovo widget:

1. Crea il file `test/widgets/<widget_name>_test.dart`
2. Importa gli helper necessari
3. Scrivi i test principali:
   - Rendering corretto
   - Stati diversi (enabled/disabled, loading, error)
   - Interazioni (tap, input, scroll)
   - Callback
4. Esegui `flutter test test/widgets/<widget_name>_test.dart`
5. Aggiorna questo README

---

*Ultimo aggiornamento: 2 Gennaio 2026*
