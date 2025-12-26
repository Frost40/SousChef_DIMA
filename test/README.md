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
├── services/
│   ├── authentication_test.dart # Tests for Authentication service
│   ├── dish_firestore_test.dart # Tests for DishFirestore service
│   └── order_firestore_test.dart # Tests for OrderFirestore service (Order model)
│
└── providers/
    ├── auth_provider_test.dart  # Tests for AuthProvider
    ├── dish_provider_test.dart  # Tests for DishProvider
    ├── order_provider_test.dart # Tests for OrderProvider
    ├── chat_provider_test.dart  # Tests for ChatProvider
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

| Provider | Tests | Description |
|----------|-------|-------------|
| AuthProvider | 24 | Sign in, sign up, sign out, password reset, account deletion |
| DishProvider | 25 | CRUD operations, availability updates, image handling |
| OrderProvider | 24 | Fetch, create, update, delete orders, verification |
| ChatProvider | 27 | Load chats, send messages, mark read, create/delete chats |
| StripeProvider | 15 | Payment processing, refunds, error handling |

### Service Tests

| Service | Tests | Description |
|---------|-------|-------------|
| Authentication | 26 | Firebase Auth operations, Google Sign-in |
| DishFirestore | 13 | Firestore CRUD for dishes |
| OrderFirestore | 22 | Order model tests |

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

