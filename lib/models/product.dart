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

  factory Product.fromJson(Map<String, dynamic> json) {

    final random = Random();

    const availableNames = ['Spaghetti Carbonara', 'Tacos al Pastor', 'Sushi Platter', 'Vegan Buddha Bowl', 'Grilled Ribeye Steak'];
    const availableCategories = ['Italian', 'Mexican', 'Japanese', 'Vegan', 'Steakhouse'];

    return Product(
      id: json['id'],
      name: availableNames[random.nextInt(availableNames.length)],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble().clamp(3.0, 200.0),
      category: availableCategories[random.nextInt(availableCategories.length)],
      isAvailable: Random().nextBool(),
    );
    
  }
}