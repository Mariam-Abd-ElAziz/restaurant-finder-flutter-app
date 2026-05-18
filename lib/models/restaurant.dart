import 'dart:math';

class Restaurant {
    final int id;
  final String name;
  final String category;
  final String address;
  final double rating; // always 1.0 → 5.0
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
  /// -----------------------------
  /// JSON FACTORY (SAFE PARSING)
  /// -----------------------------
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      category: json['Category'] ?? '',
      address: json['address'] ?? '',
      rating: _clampRating(
        double.tryParse(json['rating']?.toString() ?? '') ?? 1.0,
      ),
      reviewCount:
          int.tryParse(json['reviewCount']?.toString() ?? '') ?? 0,
      isOpen: json['isOpen'] ?? false,
      tags: (json['tags'] is List)
          ? List<String>.from(json['tags'])
          : <String>[],
      latitude:
          double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude:
          double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
    );
  }
  /// -----------------------------
  /// RATING SAFETY (1.0 → 5.0)
  /// -----------------------------
  static double _clampRating(double value) {
    if (value.isNaN || value.isInfinite) return 1.0;
    return value.clamp(1.0, 5.0);
  }
  /// -----------------------------
  /// VALIDATION HELPERS
  /// -----------------------------
  bool get hasValidLocation =>
      latitude != 0.0 && longitude != 0.0;
  bool get isValid =>
      id > 0 && name.isNotEmpty;
  double get safeRating => rating.clamp(1.0, 5.0);
  /// Optional: pretty distance helper (if needed later)
  String formatRating() => safeRating.toStringAsFixed(1);
}