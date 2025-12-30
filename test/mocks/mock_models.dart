import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/models/order.dart' as order_model;
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/models/chat.dart';
import 'package:sous_chef/models/message.dart';

/// Helper class to create mock model instances for testing
class MockModels {
  /// Creates a mock User instance
  static User createMockUser({
    String id = 'user123',
    String email = 'test@example.com',
    String username = 'testuser',
    String name = 'Test',
    String surname = 'User',
    String phone = '1234567890',
    String? restaurantId,
    List<String> favourites = const [],
    List<String> chats = const [],
  }) {
    return User(
      id: id,
      email: email,
      username: username,
      name: name,
      surname: surname,
      phone: phone,
      restaurantId: restaurantId,
      favourites: favourites,
      chats: chats,
    );
  }

  /// Creates a mock Dish instance
  static Dish createMockDish({
    String id = 'dish123',
    String name = 'Test Dish',
    String description = 'A test dish',
    double price = 10.0,
    Course course = Course.mainDish,
    Cuisine cuisine = Cuisine.italian,
    bool? isAvailable = true,
    bool isSpecial = false,
    String? imageUrl,
    String? userUsername,
    int minForewarningDays = 0,
  }) {
    return Dish(
      id: id,
      name: name,
      description: description,
      price: price,
      course: course,
      cuisine: cuisine,
      isAvailable: isAvailable,
      isSpecial: isSpecial,
      imageUrl: imageUrl,
      userUsername: userUsername,
      minForewarningDays: minForewarningDays,
    );
  }

  /// Creates a mock Restaurant instance
  static Restaurant createMockRestaurant({
    String id = 'restaurant123',
    String name = 'Test Restaurant',
    String ownerId = 'owner123',
    bool isOpen = true,
    String address = '123 Test St',
    GeoPoint location = const GeoPoint(0, 0),
    List<RestaurantType> restaurantTypes = const [],
    String? imageUrl,
  }) {
    return Restaurant(
      id: id,
      name: name,
      ownerId: ownerId,
      isOpen: isOpen,
      address: address,
      location: location,
      restaurantTypes: restaurantTypes,
      imageUrl: imageUrl,
    );
  }

  /// Creates a mock Order instance
  static order_model.Order createMockOrder({
    String id = 'order123',
    String userId = 'user123',
    String username = 'testuser',
    String restaurantId = 'restaurant123',
    String restaurantName = 'Test Restaurant',
    String restaurantAddress = '123 Test St',
    GeoPoint restaurantLocation = const GeoPoint(0, 0),
    DateTime? pickupDateTime,
    String verificationCode = '1234',
    String status = 'pending',
    double total = 20.0,
    List<order_model.OrderItem>? dishes,
  }) {
    return order_model.Order(
      id: id,
      userId: userId,
      username: username,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantAddress: restaurantAddress,
      restaurantLocation: restaurantLocation,
      pickupDateTime: pickupDateTime ?? DateTime.now().add(const Duration(days: 1)),
      verificationCode: verificationCode,
      status: status,
      total: total,
      dishes: dishes ?? [
        order_model.OrderItem(
          dishId: 'dish123',
          name: 'Test Dish',
          quantity: 2,
          price: 10.0,
        ),
      ],
    );
  }

  /// Creates a mock Chat instance
  static Chat createMockChat({
    String id = 'chat123',
    String user1Id = 'user1',
    String user2Id = 'user2',
    String? lastMessage,
    DateTime? lastMessageTime,
    int unreadCount = 0,
  }) {
    return Chat(
      id: id,
      user1Id: user1Id,
      user2Id: user2Id,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
    );
  }

  /// Creates a mock Message instance
  static Message createMockMessage({
    String id = 'message123',
    String senderId = 'user1',
    String receiverId = 'user2',
    String message = 'Test message',
    DateTime? timestamp,
    bool isRead = false,
  }) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp ?? DateTime.now(),
      isRead: isRead,
    );
  }
}
