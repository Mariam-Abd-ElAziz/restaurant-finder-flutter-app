import 'dart:math';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final bool isAvailable;
  final int? restaurantId;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    this.restaurantId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0, // ✅ FIX

      name: json['name'] ?? '',

      description: json['description'] ?? '',

      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? false,

      restaurantId: json['restaurantId'] != null
          ? int.tryParse(json['restaurantId'].toString())
          : null,
    );
  }
}