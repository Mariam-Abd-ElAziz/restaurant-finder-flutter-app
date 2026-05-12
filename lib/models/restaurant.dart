class Restaurant {
  final int id;
  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final DateTime deliveryTime;
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

  factory Restaurant.fromJson(Map<String, dynamic> json) {

    final random = Random();

    // 1. Define hardcoded lists
    const availableNames = ['The Golden Fork', 'Bistro 24', 'Urban Eats', 'Spice Route', 'Pasta Palace'];
    const availableCategories = ['Italian', 'Mexican', 'Asian Fusion', 'Vegan', 'Steakhouse'];
    const availableAddresses = [
      '123 Main St, Springfield',
      '456 Elm St, Shelbyville',
      '789 Oak St, Capital City',
      '321 Maple Ave, Ogdenville',
      '654 Pine St, North Haverbrook'
    ];
    const availableTags = ['Fast Delivery', 'High Rated', 'Organic', 'Family Friendly', 'Late Night', 'Discounted'];

    // 2. Logic for random subset of tags
    // We shuffle the list and take a random number of elements (e.g., 1 to 3 tags)
    final shuffledTags = List<String>.from(availableTags)..shuffle(random);
    final randomSubset = shuffledTags.take(random.nextInt(3) + 1).toList();

    return Restaurant(
      id: json['id'],
      name: availableNames[random.nextInt(availableNames.length)],
      category: availableCategories[random.nextInt(availableCategories.length)],
      address: availableAddresses[random.nextInt(availableAddresses.length)],
      rating: (json['rating'] as num).toDouble().clamp(0.0, 5.0),
      reviewCount: json['review_count'] ?? 0,
      deliveryTime: DateTime.parse(json['deliveryTime']),
      isOpen: Random().nextBool(),
      tags: randomSubset,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );

  }
}