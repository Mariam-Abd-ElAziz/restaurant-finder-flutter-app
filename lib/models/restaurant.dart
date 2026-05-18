import 'dart:math';

class Restaurant {
  final int id;
  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final List<String> tags;
  final double latitude;
  final double longitude;

  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.isOpen,
    required this.tags,
    required this.latitude,
    required this.longitude,
  });

factory Restaurant.fromJson(Map<String, dynamic> json) {
  return Restaurant(
    // 🔴 FIX 1: id is STRING in API
    id: int.parse(json['id'].toString()),

    name: json['name'] ?? '',

    // 🔴 FIX 2: API uses "Category" not "category"
    category: json['Category'] ?? '',

    address: json['address'] ?? '',

    // rating is int in API → convert to double safely
    rating: double.parse(json['rating'].toString()),

    reviewCount: int.parse(json['reviewCount'].toString()),

  

    isOpen: json['isOpen'] ?? false,

    // API gives empty list → safe
    tags: List<String>.from(json['tags'] ?? []),

    latitude: json['latitude'] == null
        ? 0.0
        : double.parse(json['latitude'].toString()),

    longitude: json['longitude'] == null
        ? 0.0
        : double.parse(json['longitude'].toString()),
  );
}
}