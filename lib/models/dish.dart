import 'package:cloud_firestore/cloud_firestore.dart';

class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isSpecial;

  // Regular dish attributes
  final bool? isAvailable;
  final Course? course;
  final Cuisine? cuisine;
  final int? minForewarningDays;
  final String? image;

  // Special dish attributes
  final String? userId;
  final DateTime? creationTime;
  final int? duration;
  final DateTime? pickupDateTime;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isSpecial,
    this.isAvailable,
    this.course,
    this.cuisine,
    this.minForewarningDays,
    this.image,
    this.userId,
    this.creationTime,
    this.duration,
    this.pickupDateTime,
  });

  factory Dish.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isSpecial = data['is_special'] ?? false;

    // Convert course from string to enum
    Course? dishCourse;
    if (!isSpecial && data['course'] != null) {
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
    Cuisine? dishCuisine;
    if (!isSpecial && data['cuisine'] != null) {
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
      isAvailable: isSpecial ? null : data['is_available'],
      course: dishCourse,
      cuisine: dishCuisine,
      minForewarningDays: isSpecial ? null : data['min_forewarning_days'],
      image: isSpecial ? null : data['image'],

      // Special dish attributes
      userId: isSpecial ? data['userId'] : null,
      creationTime: isSpecial && data['creation_time'] != null
          ? (data['creation_time'] as Timestamp).toDate()
          : null,
      duration: isSpecial ? data['duration'] : null,
      pickupDateTime: isSpecial && data['pickup_dateTime'] != null
          ? (data['pickup_dateTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'price': price,
      'is_special': isSpecial,
    };

    // Add regular dish attributes
    if (!isSpecial) {
      data.addAll({
        'is_available': isAvailable,
        'course': course,
        'cuisine': cuisine,
        'min_forewarning_days': minForewarningDays,
        'image': image,
      });
    }

    // Add special dish attributes
    if (isSpecial) {
      data.addAll({
        'userId': userId,
        if (creationTime != null) 'creation_time': Timestamp.fromDate(creationTime!),
        'duration': duration,
        if (pickupDateTime != null) 'pickup_dateTime': Timestamp.fromDate(pickupDateTime!),
      });
    }

    return data;
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