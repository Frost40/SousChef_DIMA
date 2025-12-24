# Unit Testing Guide for SousChef

This directory contains unit tests for the SousChef application, following Flutter best practices and focusing on pure logic testing in a mock environment.

## 📁 Directory Structure

```
test/
├── mocks/
│   ├── mock_services.dart      # Mock implementations of all services
│   └── mock_models.dart         # Helper functions to create mock model instances
├── services/
│   ├── authentication_test.dart
│   ├── dish_firestore_test.dart
│   └── order_firestore_test.dart
├── providers/
│   ├── auth_provider_test.dart
│   ├── dish_provider_test.dart
│   ├── order_provider_test.dart
│   ├── chat_provider_test.dart
│   └── stripe_provider_test.dart
└── README.md
```

## 🎯 Testing Philosophy

### What We Test
1. **Services**: Verify data parsing, error handling, and HTTP/Firestore interactions
2. **Providers (State Management)**: Verify state changes, loading states, and error states

### What We DON'T Test (Widget/Integration Testing)
- UI rendering
- User interactions
- Navigation
- Full end-to-end flows

## 🛠️ Setup and Installation

### 1. Add Test Dependencies

Ensure your `pubspec.yaml` has the following dependencies:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  fake_cloud_firestore: ^2.4.0  # Optional: for Firestore testing
```

### 2. Install Dependencies

```bash
flutter pub get
```

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/providers/auth_provider_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report (requires lcov)
```bash
# Install lcov (macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

## 📝 Test Structure

### Service Tests Example

```dart
group('DishFirestore Service Tests', () {
  late DishFirestore dishFirestore;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    // Initialize mocks and service
  });

  group('getRestaurantDishes', () {
    test('should return list of dishes when dishes exist', () async {
      // Arrange: Setup mock data
      // Act: Call service method
      // Assert: Verify results
    });
  });
});
```

### Provider Tests Example

```dart
group('AuthProvider Tests', () {
  late AuthProvider authProvider;
  late MockAuthentication mockAuth;

  setUp(() {
    mockAuth = MockAuthentication();
    authProvider = AuthProvider(auth: mockAuth);
  });

  test('should set user and isAuthenticated on successful sign in', () async {
    // Arrange
    when(() => mockAuth.signIn(any(), any()))
      .thenAnswer((_) async => mockUser);
    
    // Act
    await authProvider.signIn('test@test.com', 'password');
    
    // Assert
    expect(authProvider.isAuthenticated, true);
    expect(authProvider.user, isNotNull);
    verify(() => mockAuth.signIn('test@test.com', 'password')).called(1);
  });
});
```

## ⚠️ Important: Required Refactoring

**The test files are currently STRUCTURAL EXAMPLES.** To make them fully functional, you need to refactor your services and providers to support **Dependency Injection**.

### Why Dependency Injection?

Current implementation:
```dart
class DishProvider with ChangeNotifier {
  final DishFirestore _dishFirestore = DishFirestore(); // ❌ Hard to test
  final FirebaseStorage _firebaseStorage = FirebaseStorage();
}
```

Refactored for testability:
```dart
class DishProvider with ChangeNotifier {
  final DishFirestore _dishFirestore;
  final FirebaseStorage _firebaseStorage;

  DishProvider({
    DishFirestore? dishFirestore,
    FirebaseStorage? firebaseStorage,
  }) : _dishFirestore = dishFirestore ?? DishFirestore(),
       _firebaseStorage = firebaseStorage ?? FirebaseStorage(); // ✅ Easy to test
}
```

### Files That Need Refactoring

1. **Providers:**
   - `lib/providers/auth_provider.dart`
   - `lib/providers/dish_provider.dart`
   - `lib/providers/order_provider.dart`
   - `lib/providers/chat_provider.dart`
   - `lib/providers/stripe_provider.dart`

2. **Services:**
   - `lib/services/authentication.dart`
   - `lib/services/database/dish_firestore.dart`
   - `lib/services/database/order_firestore.dart`
   - `lib/services/database/messages_firestore.dart`
   - `lib/services/stripe.dart`

## 🧪 Testing Checklist

### For Each Provider
- [ ] Initial state is correct
- [ ] Loading state changes during async operations
- [ ] Success state updates correctly
- [ ] Error state is set on failure
- [ ] Error messages are user-friendly
- [ ] ChangeNotifier notifies listeners
- [ ] Multiple operations can be chained
- [ ] State persists across operations

### For Each Service
- [ ] Correct Firestore/API calls are made
- [ ] Data is parsed correctly
- [ ] Errors are thrown appropriately
- [ ] Edge cases are handled (empty data, null values)
- [ ] Return types are correct

## 📊 Test Coverage Goals

- **Providers:** Aim for 80%+ coverage
- **Services:** Aim for 70%+ coverage
- **Models:** 90%+ coverage (add model tests if needed)

## 🔍 Debugging Tests

### Common Issues

1. **"Bad state: No method stub was called"**
   - Ensure you register fallback values: `registerFallbackValue(mockObject);`

2. **"Type mismatch"**
   - Verify mock class extends/implements correct interface
   - Check that `when()` matches actual method signature

3. **"Null check operator used on null value"**
   - Mock dependencies might not be set up
   - Check that all required mocks are initialized in `setUp()`

### Enable Verbose Logging

```dart
test('my test', () async {
  // Add debug prints
  print('Before action');
  await provider.someMethod();
  print('After action: ${provider.state}');
  
  expect(provider.state, expectedValue);
});
```

## 📚 Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Flutter Test Best Practices](https://docs.flutter.dev/testing/best-practices)

## 🎓 Learning Path

1. Start with **Service Tests** (simpler, no state management)
2. Move to **Provider Tests** (state management complexity)
3. Refactor one provider at a time to use DI
4. Implement actual test logic incrementally
5. Aim for high coverage on critical paths

## 💡 Tips

- **Keep tests isolated**: Each test should be independent
- **Use descriptive names**: Test names should explain what they verify
- **Follow AAA pattern**: Arrange, Act, Assert
- **Mock external dependencies**: Never call real Firebase/APIs in unit tests
- **Test edge cases**: Null values, empty lists, network errors
- **Keep tests fast**: Unit tests should run in milliseconds

## 🏁 Next Steps

1. **Refactor your first provider** (recommended: AuthProvider)
2. **Implement one test group** completely
3. **Run tests and iterate** until they pass
4. **Expand to other providers** using the same pattern
5. **Set up CI/CD** to run tests automatically

---

**Remember:** These tests are an investment in code quality. They make refactoring safer and catch bugs early!
