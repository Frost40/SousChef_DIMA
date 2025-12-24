# Quick Start: Running Your First Test

Follow these steps to get your testing environment up and running.

## 🚀 Setup (5 minutes)

### Step 1: Install Dependencies
```bash
cd SousChef_DIMA
flutter pub get
```

This will install the new testing dependencies (`mocktail` and `fake_cloud_firestore`) from `pubspec.yaml`.

### Step 2: Verify Installation
```bash
flutter test --version
```

You should see Flutter test version information.

---

## 🎯 Run Your First Test (2 minutes)

### Run All Tests
```bash
flutter test
```

**Expected Output:**
```
00:01 +0 -1: loading SousChef_DIMA/test/widget_test.dart
00:02 +1: All tests passed!
```

The tests are currently placeholders (they just verify true == true), so they'll all pass. That's normal!

---

## 📝 Your First Real Test Implementation

Let's implement ONE complete test to see how it all works.

### Step 1: Refactor AuthProvider

Open [lib/providers/auth_provider.dart](../lib/providers/auth_provider.dart) and make this change:

**Find this (around line 17-20):**
```dart
class AuthProvider with ChangeNotifier {
  // Authentication service instance used to interact with Firebase
  final Authentication _auth = Authentication();

  final UserFirestore _userFirestore = UserFirestore();
```

**Replace with:**
```dart
class AuthProvider with ChangeNotifier {
  // Authentication service instance used to interact with Firebase
  final Authentication _auth;

  final UserFirestore _userFirestore;

  // Constructor with dependency injection for testability
  AuthProvider({
    Authentication? auth,
    UserFirestore? userFirestore,
  }) : _auth = auth ?? Authentication(),
       _userFirestore = userFirestore ?? UserFirestore() {
    _initializeCurrentUser();
  }
```

**Remove the old constructor:**
```dart
  // Delete this:
  AuthProvider() {
    _initializeCurrentUser();
  }
```

### Step 2: Run the App

Make sure your app still works:
```bash
flutter run
```

Everything should work exactly the same! The `??` operator ensures production code uses real services.

### Step 3: Implement a Real Test

Open [test/providers/auth_provider_test.dart](providers/auth_provider_test.dart)

**Find this test (around line 73):**
```dart
test('should set user and isAuthenticated to true on successful sign in', () async {
  // Expected flow:
  // ...
  expect(true, true); // Placeholder
});
```

**Replace with:**
```dart
test('should set user and isAuthenticated to true on successful sign in', () async {
  // Arrange
  final mockUser = MockModels.createMockUser(
    id: 'user123',
    email: 'test@example.com',
    username: 'testuser',
  );

  when(() => mockAuth.signIn(any(), any()))
      .thenAnswer((_) async => mockUser);

  // Act
  await authProvider.signIn('test@example.com', 'password123');

  // Assert
  expect(authProvider.isAuthenticated, true);
  expect(authProvider.user, isNotNull);
  expect(authProvider.user?.id, 'user123');
  expect(authProvider.isLoading, false);
  expect(authProvider.errorMessage, null);

  // Verify service was called correctly
  verify(() => mockAuth.signIn('test@example.com', 'password123')).called(1);
});
```

**Update setUp() method (around line 24):**
```dart
setUp(() {
  mockAuth = MockAuthentication();
  mockUserFirestore = MockUserFirestore();
  
  // NOW YOU CAN DO THIS:
  authProvider = AuthProvider(
    auth: mockAuth,
    userFirestore: mockUserFirestore,
  );
});
```

**Update tearDown() method (around line 33):**
```dart
tearDown(() {
  authProvider.dispose();  // Uncomment this
});
```

### Step 4: Run the Test

```bash
flutter test test/providers/auth_provider_test.dart
```

**Expected Output:**
```
00:02 +1: AuthProvider Tests State Management initial state should be not authenticated and not loading
00:02 +2: AuthProvider Tests signIn should set user and isAuthenticated to true on successful sign in
...
00:03 +X: All tests passed!
```

---

## 🎉 Success!

You've just:
1. ✅ Refactored code for testability
2. ✅ Written your first working unit test
3. ✅ Verified it passes

---

## 🔄 Next Steps

### Option A: Implement More AuthProvider Tests
Continue with other test cases in `auth_provider_test.dart`:
- Error handling
- Sign up
- Sign out
- Password reset

### Option B: Move to Another Provider
Refactor and test another provider:
1. DishProvider (simpler, good next step)
2. OrderProvider
3. ChatProvider

### Option C: Test Coverage
See what's tested:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📚 Resources at Your Fingertips

- **[README.md](README.md)** - Full testing guide
- **[REFACTORING_GUIDE.md](REFACTORING_GUIDE.md)** - Step-by-step refactoring patterns
- **[examples/auth_provider_complete_example_test.dart](examples/auth_provider_complete_example_test.dart)** - Fully commented example

---

## 🆘 Troubleshooting

### "Type 'Null' is not a subtype of type 'X' in type cast"
**Solution:** You forgot to refactor the provider to use DI. Go back to Step 1.

### "Bad state: No method stub was called"
**Solution:** Add this to `setUpAll()`:
```dart
setUpAll(() {
  registerFallbackValue(MockModels.createMockUser());
});
```

### "Cannot instantiate provider"
**Solution:** Make sure the constructor parameters are **optional** (use `?`):
```dart
AuthProvider({Authentication? auth})  // ✅ Optional
AuthProvider({Authentication auth})   // ❌ Required
```

### Tests pass but app crashes
**Solution:** You forgot the `??` operator:
```dart
: _auth = auth ?? Authentication()  // ✅ Correct
: _auth = auth                      // ❌ Will be null in production
```

---

## 💡 Pro Tips

1. **Start Small**: Don't try to test everything at once
2. **One Provider at a Time**: Complete one before moving to next
3. **Run Tests Frequently**: `flutter test` after each change
4. **Read Error Messages**: They usually tell you exactly what's wrong
5. **Use the Example**: Copy patterns from `auth_provider_complete_example_test.dart`

---

## ⏱️ Time Estimates

- Refactor one provider: ~10 minutes
- Implement one test group: ~15 minutes
- Complete one provider's tests: ~1 hour
- All providers: ~4-6 hours (spread over days)

**Don't rush!** Quality tests are an investment in your code's future.

---

Ready to write bulletproof code? Let's go! 🚀

```bash
flutter test
```
