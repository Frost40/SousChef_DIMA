import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/services/authentication.dart';
import 'package:sous_chef/services/database/dish_firestore.dart';
import 'package:sous_chef/services/database/messages_firestore.dart';
import 'package:sous_chef/services/database/order_firestore.dart';
import 'package:sous_chef/services/database/restaurant_firestore.dart';
import 'package:sous_chef/services/database/user_firestore.dart';
import 'package:sous_chef/services/firebase_storage.dart';
import 'package:sous_chef/services/stripe.dart';

/// Mock class for Authentication service
class MockAuthentication extends Mock implements Authentication {}

/// Mock class for DishFirestore service
class MockDishFirestore extends Mock implements DishFirestore {}

/// Mock class for ChatFirestore service
class MockChatFirestore extends Mock implements ChatFirestore {}

/// Mock class for OrderFirestore service
class MockOrderFirestore extends Mock implements OrderFirestore {}

/// Mock class for RestaurantFirestore service
class MockRestaurantFirestore extends Mock implements RestaurantFirestore {}

/// Mock class for UserFirestore service
class MockUserFirestore extends Mock implements UserFirestore {}

/// Mock class for FirebaseStorage service
class MockFirebaseStorage extends Mock implements FirebaseStorage {}

/// Mock class for StripeService
class MockStripeService extends Mock implements StripeService {}
