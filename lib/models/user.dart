import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String username;
  final String name;
  final String surname;
  final String phone;
  final String? restaurantId;
  final List<String> favourites;
  final List<String> chats;

  // Address fields
  final String? savedAddress;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.surname,
    required this.phone,
    this.restaurantId,
    this.favourites = const [],
    this.chats = const [],
    this.savedAddress,
    this.latitude,
    this.longitude,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      phone: data['phone'] ?? '',
      restaurantId:
          (data['restaurant_id'] != null) ? data['restaurant_id'] : '',
      favourites:
          (data['favourites'] != null)
              ? List<String>.from(
                data['favourites'],
              ) // Assicurati che sia una List<String>
              : <String>[],
      chats:
          (data['chats'] != null)
              ? List<String>.from(data['chats'])
              : <String>[],
      savedAddress: data['saved_address'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'name': name,
      'surname': surname,
      'phone': phone,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      'favourites': favourites,
      'chats': chats,
      if (savedAddress != null) 'saved_address': savedAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  /// Creates a copy of this User with the given fields replaced with the new values
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    String? surname,
    String? phone,
    List<String>? favourites,
    String? savedAddress,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      favourites: favourites ?? this.favourites,
      chats: chats ?? this.chats,
      savedAddress: savedAddress ?? this.savedAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
