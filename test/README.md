# SousChef Unit Testing Suite

Complete unit testing infrastructure for the SousChef Flutter application.

## 📁 Directory Structure

```
test/
├── README.md                    # This file - complete testing guide
├── run_tests.sh                 # Test runner script
│
├── mocks/
│   ├── mock_services.dart       # Mock classes for all services
│   └── mock_models.dart         # Helper functions to create mock model instances
│
├── models/
│   ├── chat_test.dart           # Tests for Chat model
│   ├── dish_test.dart           # Tests for Dish model
│   ├── message_test.dart        # Tests for Message model
│   ├── order_test.dart          # Tests for Order model
│   ├── restaurant_test.dart     # Tests for Restaurant model
│   └── user_test.dart           # Tests for User model
│
├── services/
│   ├── authentication_test.dart # Tests for Authentication service
│   ├── firebase_storage_test.dart # Tests for Firebase Storage service
│   ├── stripe_test.dart         # Tests for Stripe service
│   └── database/
│       ├── dish_firestore_test.dart # Tests for DishFirestore service
│       ├── messages_firestore_test.dart # Tests for MessagesFirestore service
│       ├── order_firestore_test.dart # Tests for OrderFirestore service
│       ├── restaurant_firestore_test.dart # Tests for RestaurantFirestore service
│       └── user_firestore_test.dart # Tests for UserFirestore service
│
└── providers/
    ├── auth_provider_test.dart  # Tests for AuthProvider
    ├── chat_provider_test.dart  # Tests for ChatProvider
    ├── dish_provider_test.dart  # Tests for DishProvider
    ├── order_provider_test.dart # Tests for OrderProvider
    ├── restaurant_provider_test.dart # Tests for RestaurantProvider
    └── stripe_provider_test.dart # Tests for StripeProvider
```

## 🚀 Quick Start

### Prerequisites

Ensure your `pubspec.yaml` has the following dependencies:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
```

### Run All Tests

```bash
cd SousChef_DIMA
flutter test
```

### Run Specific Test Files

```bash
# All provider tests
flutter test test/providers/

# All service tests
flutter test test/services/

# All model tests
flutter test test/models/

# Specific test file
flutter test test/providers/auth_provider_test.dart
```

### Run with Coverage

```bash
flutter test --coverage

# Generate HTML report (requires lcov)
brew install lcov  # macOS only
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🎯 Testing Philosophy

### What We Test
- **Models**: Serialization (toMap/fromMap), equality, property validation
- **Services**: Data parsing, error handling, Firestore interactions
- **Providers (State Management)**: State changes, loading states, error handling, ChangeNotifier behavior

### What We DON'T Test (Widget/Integration Testing)
- UI rendering
- User interactions
- Navigation
- Full end-to-end flows

## 🔧 Dependency Injection Pattern

All providers and services support dependency injection for testability.

### Production Usage (Unchanged)

```dart
// App code - no changes needed!
final authProvider = AuthProvider();
final dishProvider = DishProvider();
```

### Test Usage (Inject Mocks)

```dart
// Test code - inject mocks!
final mockAuth = MockAuthentication();
final mockUserFirestore = MockUserFirestore();

final authProvider = AuthProvider(
  auth: mockAuth,
  userFirestore: mockUserFirestore,
);
```

## 📊 Test Coverage Summary

### Provider Tests

| Provider | Description |
|----------|-------------|
| AuthProvider | Sign in, sign up, sign out, password reset, account deletion |
| ChatProvider | Load chats, send messages, mark read, create/delete chats |
| DishProvider | CRUD operations, availability updates, image handling |
| OrderProvider | Fetch, create, update, delete orders, verification |
| RestaurantProvider | Restaurant management operations |
| StripeProvider | Payment processing, refunds, error handling |

### Service Tests

| Service | Description |
|---------|-------------|
| Authentication | Firebase Auth operations, Google Sign-in |
| FirebaseStorage | Image upload and retrieval |
| StripeService | Stripe payment interactions |
| DishFirestore | Firestore CRUD for dishes |
| MessagesFirestore | Chat message operations |
| OrderFirestore | Order model tests |
| RestaurantFirestore | Restaurant database operations |
| UserFirestore | User profile database operations |

### Model Tests

| Model | Description |
|-------|-------------|
| Chat | Chat model serialization, equality, properties |
| Dish | Dish model serialization, equality, properties |
| Message | Message model serialization, equality, properties |
| Order | Order model serialization, equality, properties |
| Restaurant | Restaurant model serialization, equality, properties |
| User | User model serialization, equality, properties |

## 📝 Test Structure Example

### Typical Test Pattern

```dart
group('FeatureName Tests', () {
  late Provider provider;
  late MockService mockService;

  setUp(() {
    mockService = MockService();
    provider = Provider(service: mockService);
    registerFallbackValue(MockModels.createMockEntity());
  });

  tearDown(() {
    provider.dispose();
  });

  group('methodName', () {
    test('should do expected thing when condition', () async {
      // Arrange
      when(() => mockService.someMethod(any()))
          .thenAnswer((_) async => expectedResult);

      // Act
      await provider.methodUnderTest();

      // Assert
      expect(provider.someState, expectedValue);
      verify(() => mockService.someMethod(any())).called(1);
    });

    test('should handle errors gracefully', () async {
      // Arrange
      when(() => mockService.someMethod(any()))
          .thenThrow(Exception('Error'));

      // Act
      await provider.methodUnderTest();

      // Assert
      expect(provider.errorMessage, isNotNull);
    });
  });
});
```

## 🛠️ Mock Classes

### Available Mock Services (mock_services.dart)

```dart
class MockAuthentication extends Mock implements Authentication {}
class MockDishFirestore extends Mock implements DishFirestore {}
class MockChatFirestore extends Mock implements ChatFirestore {}
class MockOrderFirestore extends Mock implements OrderFirestore {}
class MockRestaurantFirestore extends Mock implements RestaurantFirestore {}
class MockUserFirestore extends Mock implements UserFirestore {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockStripeService extends Mock implements StripeService {}
```

### Available Mock Model Helpers (mock_models.dart)

```dart
MockModels.createMockUser(id: 'user123', email: 'test@example.com')
MockModels.createMockDish(id: 'dish123', name: 'Pizza', price: 12.50)
MockModels.createMockOrder(id: 'order123', status: 'pending')
MockModels.createMockRestaurant(id: 'rest123', name: 'Test Restaurant')
MockModels.createMockChat(id: 'chat123', user1Id: 'user1', user2Id: 'user2')
MockModels.createMockMessage(id: 'msg123', message: 'Hello')
```

## 🐛 Debugging Tests

### Common Issues

**1. "No stub found" error**
```dart
// Make sure to register fallback values for any() matchers
registerFallbackValue(MockModels.createMockOrder());
```

**2. "Type 'Null' is not a subtype" error**
```dart
// Ensure mocks return non-null values
when(() => mockService.getData()).thenAnswer((_) async => []);
```

**3. Tests hanging**
```dart
// Use async/await properly
test('async test', () async {
  await provider.asyncMethod();  // Don't forget await!
});
```

### Verbose Test Output

```bash
flutter test --reporter expanded
```

### Run Single Test

```bash
flutter test --name "should return User when sign in is successful"
```

## 📂 Refactored Files

### Providers (with DI support)

| File | Injectable Parameters |
|------|----------------------|
| `lib/providers/auth_provider.dart` | `Authentication?`, `UserFirestore?` |
| `lib/providers/dish_provider.dart` | `DishFirestore?`, `FirebaseStorage?` |
| `lib/providers/order_provider.dart` | `OrderFirestore?` |
| `lib/providers/chat_provider.dart` | `ChatFirestore?`, `FirebaseFirestore?` |
| `lib/providers/stripe_provider.dart` | `StripeService?` |

### Services (with DI support)

| File | Injectable Parameters |
|------|----------------------|
| `lib/services/authentication.dart` | `FirebaseAuth?`, `FirebaseFirestore?`, `GoogleSignIn?` |
| `lib/services/database/dish_firestore.dart` | `FirebaseFirestore?` |
| `lib/services/database/order_firestore.dart` | `FirebaseFirestore?` |
| `lib/services/database/messages_firestore.dart` | `FirebaseFirestore?` |
| `lib/services/database/user_firestore.dart` | `FirebaseAuth?`, `FirebaseFirestore?` |
| `lib/services/firebase_storage.dart` | `FirebaseStorage?` |

## ⚡ Test Runner Script

Make the script executable (first time only):
```bash
chmod +x test/run_tests.sh
```

Usage:
```bash
./test/run_tests.sh all          # All tests
./test/run_tests.sh providers    # Provider tests only
./test/run_tests.sh services     # Service tests only
./test/run_tests.sh coverage     # Generate coverage report
./test/run_tests.sh help         # Show all options
```

## 📋 Test Checklist

When adding new tests:

- [ ] Create mock class in `mock_services.dart` if needed
- [ ] Add mock model helper in `mock_models.dart` if needed
- [ ] Register fallback values for complex types
- [ ] Test happy path scenarios
- [ ] Test error handling
- [ ] Test edge cases (empty lists, null values)
- [ ] Verify ChangeNotifier behavior (listeners notified)
- [ ] Clean up in `tearDown`

## 🎯 Best Practices

1. **One assertion per test** - Make tests focused and clear
2. **Descriptive names** - Test names should explain the expected behavior
3. **AAA pattern** - Arrange, Act, Assert
4. **Isolated tests** - Each test should be independent
5. **Mock external dependencies** - Never hit real Firebase in unit tests
6. **Test edge cases** - Empty lists, null values, errors
7. **Keep tests fast** - Unit tests should run in milliseconds

---

## 📞 Need Help?

For Flutter testing documentation:
- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)

