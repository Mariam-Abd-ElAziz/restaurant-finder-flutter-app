class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        price: (json['price'] ?? 0.0).toDouble(),
        category: json['category'] ?? 'Other',
        isAvailable: json['is_available'] ?? true,
      );
}