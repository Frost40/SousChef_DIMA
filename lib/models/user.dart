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

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.surname,
    required this.phone,
    this.restaurantId,
    this.favourites = const [],
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
      restaurantId: (data['restaurant_id']!= null)? data['restaurant_id'] : '',
      favourites: (data['favourites'] != null)
        ? List<String>.from(data['favourites']) // Assicurati che sia una List<String>
        : <String>[],
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
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      favourites: favourites ?? this.favourites
    );
  }
}
