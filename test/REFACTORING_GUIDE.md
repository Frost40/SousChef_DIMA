# Step-by-Step Refactoring Guide for Testability

This guide shows you exactly how to refactor your code to make it testable using Dependency Injection (DI).

## 📋 Table of Contents
1. [Why Refactor?](#why-refactor)
2. [Refactoring Services](#refactoring-services)
3. [Refactoring Providers](#refactoring-providers)
4. [Testing After Refactoring](#testing-after-refactoring)
5. [Checklist](#checklist)

---

## Why Refactor?

### Current Problem ❌

```dart
class DishProvider with ChangeNotifier {
  final DishFirestore _dishFirestore = DishFirestore();
  final FirebaseStorage _firebaseStorage = FirebaseStorage();
  
  // Cannot inject mocks for testing!
}
```

### Solution ✅

```dart
class DishProvider with ChangeNotifier {
  final DishFirestore _dishFirestore;
  final FirebaseStorage _firebaseStorage;

  DishProvider({
    DishFirestore? dishFirestore,
    FirebaseStorage? firebaseStorage,
  }) : _dishFirestore = dishFirestore ?? DishFirestore(),
       _firebaseStorage = firebaseStorage ?? FirebaseStorage();
  
  // Can inject mocks for testing!
}
```

**Benefits:**
- ✅ Easy to test with mocks
- ✅ More flexible and maintainable
- ✅ Same behavior in production (uses `??` operator)
- ✅ No changes needed in existing app code

---

## Refactoring Services

### Example 1: DishFirestore

#### BEFORE:
```dart
class DishFirestore {
  final CollectionReference _restaurantTable =
      FirebaseFirestore.instance.collection('restaurants');

  Future<List<Dish>> getRestaurantDishes(String restaurantId) async {
    final QuerySnapshot dishesSnapshot = await _restaurantTable
        .doc(restaurantId)
        .collection('dishes')
        .get();

    if (dishesSnapshot.docs.isEmpty) {
      return [];
    }

    return dishesSnapshot.docs
        .map((doc) => Dish.fromFirestore(doc))
        .toList();
  }
}
```

#### AFTER:
```dart
class DishFirestore {
  final FirebaseFirestore _firestore;
  late final CollectionReference _restaurantTable;

  DishFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _restaurantTable = _firestore.collection('restaurants');
  }

  Future<List<Dish>> getRestaurantDishes(String restaurantId) async {
    final QuerySnapshot dishesSnapshot = await _restaurantTable
        .doc(restaurantId)
        .collection('dishes')
        .get();

    if (dishesSnapshot.docs.isEmpty) {
      return [];
    }

    return dishesSnapshot.docs
        .map((doc) => Dish.fromFirestore(doc))
        .toList();
  }
}
```

**Changes Made:**
1. Added `FirebaseFirestore` parameter to constructor
2. Changed `_restaurantTable` from `final` to `late final`
3. Initialize in constructor body instead of inline
4. Use `??` operator for default value

### Example 2: Authentication

#### BEFORE:
```dart
class Authentication {
  final firebase_auth.FirebaseAuth _firebaseAuth = 
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User> signIn(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
    // ...
  }
}
```

#### AFTER:
```dart
class Authentication {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Authentication({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<User> signIn(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
    // ...
  }
}
```

---

## Refactoring Providers

### Example 1: AuthProvider

#### BEFORE:
```dart
class AuthProvider with ChangeNotifier {
  final Authentication _auth = Authentication();
  final UserFirestore _userFirestore = UserFirestore();
  
  User? _user;
  bool _isLoading = false;

  AuthProvider() {
    _initializeCurrentUser();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      _user = await _auth.signIn(email, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
    }
  }
}
```

#### AFTER:
```dart
class AuthProvider with ChangeNotifier {
  final Authentication _auth;
  final UserFirestore _userFirestore;
  
  User? _user;
  bool _isLoading = false;

  AuthProvider({
    Authentication? auth,
    UserFirestore? userFirestore,
  }) : _auth = auth ?? Authentication(),
       _userFirestore = userFirestore ?? UserFirestore() {
    _initializeCurrentUser();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      _user = await _auth.signIn(email, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _setErrorFieldsByErrorType(e);
      notifyListeners();
    }
  }
}
```

**Changes Made:**
1. Changed service fields from `final X = Y()` to `final X`
2. Added optional parameters to constructor
3. Initialize in initializer list with `??` operator
4. Keep constructor body (initialization logic remains)

### Example 2: DishProvider

#### BEFORE:
```dart
class DishProvider with ChangeNotifier {
  final DishFirestore _dishFirestore = DishFirestore();
  final FirebaseStorage _firebaseStorage = FirebaseStorage();

  List<Dish> _dishes = [];
  bool _isLoading = false;

  Future<void> fetchDishes(String restaurantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _dishes = await _dishFirestore.getRestaurantDishes(restaurantId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }
}
```

#### AFTER:
```dart
class DishProvider with ChangeNotifier {
  final DishFirestore _dishFirestore;
  final FirebaseStorage _firebaseStorage;

  DishProvider({
    DishFirestore? dishFirestore,
    FirebaseStorage? firebaseStorage,
  }) : _dishFirestore = dishFirestore ?? DishFirestore(),
       _firebaseStorage = firebaseStorage ?? FirebaseStorage();

  List<Dish> _dishes = [];
  bool _isLoading = false;

  Future<void> fetchDishes(String restaurantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _dishes = await _dishFirestore.getRestaurantDishes(restaurantId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }
}
```

---

## Testing After Refactoring

### Service Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sous_chef/services/database/dish_firestore.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}

void main() {
  group('DishFirestore', () {
    late DishFirestore dishFirestore;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      dishFirestore = DishFirestore(firestore: mockFirestore);
    });

    test('should fetch dishes successfully', () async {
      // Setup mock behavior
      // ... implement test
    });
  });
}
```

### Provider Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/providers/dish_provider.dart';
import 'package:sous_chef/services/database/dish_firestore.dart';

class MockDishFirestore extends Mock implements DishFirestore {}

void main() {
  group('DishProvider', () {
    late DishProvider dishProvider;
    late MockDishFirestore mockDishFirestore;

    setUp(() {
      mockDishFirestore = MockDishFirestore();
      dishProvider = DishProvider(dishFirestore: mockDishFirestore);
    });

    test('should set loading state correctly', () async {
      // Arrange
      when(() => mockDishFirestore.getRestaurantDishes(any()))
          .thenAnswer((_) async => []);

      // Act
      final future = dishProvider.fetchDishes('restaurant123');
      
      // Assert: During
      expect(dishProvider.isLoading, true);
      
      await future;
      
      // Assert: After
      expect(dishProvider.isLoading, false);
      verify(() => mockDishFirestore.getRestaurantDishes('restaurant123'))
          .called(1);
    });
  });
}
```

---

## Checklist

### For Each Service File
- [ ] Add constructor with optional dependencies
- [ ] Change `final X = Y()` to `final X`
- [ ] Initialize in initializer list using `??` operator
- [ ] If using collections, change to `late final` and init in body
- [ ] No changes to method logic needed

### For Each Provider File
- [ ] Add constructor with optional dependencies
- [ ] Change service fields from `= Service()` to just declaration
- [ ] Initialize in initializer list using `??` operator
- [ ] Keep any initialization logic in constructor body
- [ ] No changes to method logic needed

### Files to Refactor

#### Providers (Priority Order)
1. [ ] `lib/providers/auth_provider.dart`
2. [ ] `lib/providers/dish_provider.dart`
3. [ ] `lib/providers/order_provider.dart`
4. [ ] `lib/providers/chat_provider.dart`
5. [ ] `lib/providers/stripe_provider.dart`

#### Services (Priority Order)
1. [ ] `lib/services/authentication.dart`
2. [ ] `lib/services/database/dish_firestore.dart`
3. [ ] `lib/services/database/order_firestore.dart`
4. [ ] `lib/services/database/user_firestore.dart`
5. [ ] `lib/services/database/messages_firestore.dart`
6. [ ] `lib/services/database/restaurant_firestore.dart`
7. [ ] `lib/services/firebase_storage.dart`
8. [ ] `lib/services/stripe.dart`

### After Refactoring
- [ ] Run app to ensure no regressions
- [ ] Implement one complete test group
- [ ] Run tests with `flutter test`
- [ ] Gradually add more test cases
- [ ] Aim for 70%+ coverage

---

## Common Pitfalls

### ❌ Don't Do This
```dart
// Forgetting the ?? operator
class MyProvider {
  final MyService _service;
  
  MyProvider({MyService? service}) 
    : _service = service;  // Will be null in production!
}
```

### ✅ Do This
```dart
class MyProvider {
  final MyService _service;
  
  MyProvider({MyService? service}) 
    : _service = service ?? MyService();  // ✅ Works in production
}
```

### ❌ Don't Do This
```dart
// Initializing collections inline with late
class MyService {
  late final CollectionReference _table = 
      FirebaseFirestore.instance.collection('x');  // Can't be mocked
}
```

### ✅ Do This
```dart
class MyService {
  final FirebaseFirestore _firestore;
  late final CollectionReference _table;
  
  MyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _table = _firestore.collection('x');  // ✅ Can be mocked
  }
}
```

---

## Quick Reference

### Refactoring Pattern for Services

```dart
// BEFORE
class MyService {
  final Firebase _firebase = Firebase.instance;
  final Collection _collection = Firebase.instance.collection('x');
}

// AFTER
class MyService {
  final Firebase _firebase;
  late final Collection _collection;
  
  MyService({Firebase? firebase})
      : _firebase = firebase ?? Firebase.instance {
    _collection = _firebase.collection('x');
  }
}
```

### Refactoring Pattern for Providers

```dart
// BEFORE
class MyProvider with ChangeNotifier {
  final MyService _service = MyService();
  
  MyProvider() {
    _init();
  }
}

// AFTER
class MyProvider with ChangeNotifier {
  final MyService _service;
  
  MyProvider({MyService? service})
      : _service = service ?? MyService() {
    _init();
  }
}
```

---

**Remember:** Start with one file, test it, then move to the next. Don't try to refactor everything at once!

Good luck! 🚀
