import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlot {
  final String from;
  final String to;

  TimeSlot({required this.from, required this.to});

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      from: map['from'] ?? '',
      to: map['to'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
    };
  }
}

class Holiday {
  final DateTime from;
  final DateTime to;

  Holiday({required this.from, required this.to});

  factory Holiday.fromMap(Map<String, dynamic> map) {
    return Holiday(
      from: (map['from'] as Timestamp).toDate(),
      to: (map['to'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': Timestamp.fromDate(from),
      'to': Timestamp.fromDate(to),
    };
  }
}

class Restaurant {
  final String id;
  final String name;
  final String address;
  final List<TimeSlot> timeSlots;
  final Holiday? holidays;
  final RestaurantType restaurantType;
  final double rating;
  final int numRatings;
  final String ownerId;
  final GeoPoint location;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.timeSlots,
    this.holidays,
    required this.restaurantType,
    required this.rating,
    required this.numRatings,
    required this.ownerId,
    required this.location,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<TimeSlot> timeSlots = [];
    if (data['time_slots'] != null) {
      timeSlots = List<Map<String, dynamic>>.from(data['time_slots'])
          .map((slot) => TimeSlot.fromMap(slot))
          .toList();
    }

    Holiday? holidays;
    if (data['holidays'] != null) {
      holidays = Holiday.fromMap(data['holidays']);
    }

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      timeSlots: timeSlots,
      holidays: holidays,
      restaurantType: data['restaurant_type'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      numRatings: data['numRatings'] ?? 0,
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'time_slots': timeSlots.map((slot) => slot.toMap()).toList(),
      if (holidays != null) 'holidays': holidays!.toMap(),
      'restaurant_type': restaurantType,
      'rating': rating,
      'numRatings': numRatings,
      'ownerId': ownerId,
      'location': location,
    };
  }
}

enum RestaurantType { menuOnly, personalizedOnly, menuAndPersonalized }