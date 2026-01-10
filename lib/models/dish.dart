import 'package:cloud_firestore/cloud_firestore.dart';

class Dish {
  final String id;
  final String name;
  final String? description;
  final double price;
  final bool isSpecial;
  final Course course;
  final Cuisine cuisine;
  final int minForewarningDays;
  final String? imageUrl;
  final DateTime? creationTime;

  // Regular dish attributes
  final bool? isAvailable;

  // Special dish attributes
  final String? userUsername;

  Dish({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.isSpecial,
    this.isAvailable,
    required this.course,
    required this.cuisine,
    this.minForewarningDays = 0,
    this.imageUrl = '',
    this.userUsername,
    this.creationTime,
  });

  factory Dish.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isSpecial = data['is_special'] ?? false;

    // Convert course from string to enum
    Course? dishCourse = Course.other;
    if (data['course'] != null) {
      final String courseStr = data['course'] as String;
      try {
        dishCourse = Course.values.firstWhere(
                (e) => e.toString() == 'Course.$courseStr'
        );
      } catch (_) {
        dishCourse = Course.other; // Default value
      }
    }

    // Convert cuisine from string to enum
    Cuisine? dishCuisine = Cuisine.other;
    if (data['cuisine'] != null) {
      final String cuisineStr = data['cuisine'] as String;
      try {
        dishCuisine = Cuisine.values.firstWhere(
                (e) => e.toString() == 'Cuisine.$cuisineStr'
        );
      } catch (_) {
        dishCuisine = Cuisine.other; // Default value
      }
    }

    return Dish(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      isSpecial: isSpecial,

      // Regular dish attributes
      isAvailable: data['is_available'],
      course: dishCourse,
      cuisine: dishCuisine,
      minForewarningDays: data['min_forewarning_days'] ?? 0,
      imageUrl: data['image'],

      // Special dish attributes
      userUsername: isSpecial ? data['user_username'] : null,
      creationTime: isSpecial && data['creation_time'] != null
          ? (data['creation_time'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'price': price,
      'course': course.toString().split('.').last,
      'cuisine': cuisine.toString().split('.').last,
      'min_forewarning_days': minForewarningDays,
      'image': imageUrl,
      'is_special': isSpecial,
      'is_available': isAvailable,
    };

    // Add special dish attributes
    if (isSpecial) {
      data.addAll({
        'user_username': userUsername,
        if (creationTime != null) 'creation_time': Timestamp.fromDate(creationTime!),
      });
    }

    return data;
  }

  /// Creates a copy of this Dish with the given fields replaced with the new values
  Dish copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    bool? isSpecial,
    bool? isAvailable,
    Course? course,
    Cuisine? cuisine,
    int? minForewarningDays,
    String? imageUrl,
    String? userUsername,
    DateTime? creationTime,
    int? duration,
    DateTime? pickupDateTime,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isSpecial: isSpecial ?? this.isSpecial,
      isAvailable: isAvailable ?? this.isAvailable,
      course: course ?? this.course,
      cuisine: cuisine ?? this.cuisine,
      minForewarningDays: minForewarningDays ?? this.minForewarningDays,
      imageUrl: imageUrl ?? this.imageUrl,
      userUsername: userUsername ?? this.userUsername,
      creationTime: creationTime ?? this.creationTime,
    );
  }
}

enum Course {
  appetizer,
  pastaDish, // pasta dishes
  mainDish, // meat or fish dishes
  side,
  dessert,
  drink,
  other,
}

enum Cuisine {
  italian,
  chinese,
  japanese,
  indian,
  french,
  mexican,
  american,
  other,
}