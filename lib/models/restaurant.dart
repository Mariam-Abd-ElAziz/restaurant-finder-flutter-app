class Restaurant {
  final int id;
  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final bool isOpen;
  final List<String> tags;
  final double? latitude;
  final double? longitude;

  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.isOpen,
    required this.tags,
    this.latitude,
    this.longitude,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'],
        name: json['name'],
        category: json['category'] ?? 'Restaurant',
        address: json['address'] ?? '',
        rating: (json['rating'] ?? 0.0).toDouble(),
        reviewCount: json['review_count'] ?? 0,
        deliveryTime: json['delivery_time'] ?? '—',
        isOpen: json['is_open'] ?? true,
        tags: List<String>.from(json['tags'] ?? []),
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
      );
}