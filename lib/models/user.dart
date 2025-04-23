import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String username;
  final String name;
  final String surname;
  final String phone;
  final String? restaurantId;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.surname,
    required this.phone,
    this.restaurantId,
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
      restaurantId: data['restaurantId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'name': name,
      'surname': surname,
      'phone': phone,
      if (restaurantId != null) 'restaurantId': restaurantId,
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
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
    );
  }
}