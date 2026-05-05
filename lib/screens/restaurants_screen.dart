import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/restaurant_card.dart';
import '../models/restaurant.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Sample data — replace with API call to AppConstants.restaurantsEndpoint
  final List<Restaurant> _allRestaurants = const [
    Restaurant(
      id: 1,
      name: 'The Golden Spoon',
      category: 'Restaurant',
      address: '12 Tahrir Square, Cairo',
      rating: 4.8,
      reviewCount: 320,
      deliveryTime: '25–35 min',
      isOpen: true,
      tags: ['Egyptian', 'Grills', 'Family'],
      latitude: 30.0444,
      longitude: 31.2357,
    ),
    Restaurant(
      id: 2,
      name: 'Café Arabica',
      category: 'Café',
      address: '4 Zamalek St, Cairo',
      rating: 4.5,
      reviewCount: 185,
      deliveryTime: '15–20 min',
      isOpen: true,
      tags: ['Coffee', 'Pastries', 'Breakfast'],
      latitude: 30.0626,
      longitude: 31.2197,
    ),
    Restaurant(
      id: 3,
      name: 'Burger Lab',
      category: 'Fast Food',
      address: '7 Mohandiseen, Giza',
      rating: 4.3,
      reviewCount: 412,
      deliveryTime: '20–30 min',
      isOpen: false,
      tags: ['Burgers', 'Fries', 'Shakes'],
      latitude: 30.0576,
      longitude: 31.2022,
    ),
    Restaurant(
      id: 4,
      name: 'Lotus Garden',
      category: 'Restaurant',
      address: '19 Maadi Corniche, Cairo',
      rating: 4.6,
      reviewCount: 230,
      deliveryTime: '30–45 min',
      isOpen: true,
      tags: ['Asian', 'Sushi', 'Noodles'],
      latitude: 29.9602,
      longitude: 31.2569,
    ),
    Restaurant(
      id: 5,
      name: 'Sweet Nest',
      category: 'Dessert',
      address: '3 Heliopolis Ave, Cairo',
      rating: 4.9,
      reviewCount: 540,
      deliveryTime: '10–20 min',
      isOpen: true,
      tags: ['Ice Cream', 'Waffles', 'Crepes'],
      latitude: 30.0920,
      longitude: 31.3360,
    ),
    Restaurant(
      id: 6,
      name: 'Brew & Bean',
      category: 'Café',
      address: '88 New Cairo Blvd',
      rating: 4.4,
      reviewCount: 97,
      deliveryTime: '15–25 min',
      isOpen: false,
      tags: ['Specialty Coffee', 'Sandwiches'],
      latitude: 30.0071,
      longitude: 31.4796,
    ),
  ];

  List<Restaurant> get _filtered {
    return _allRestaurants.where((r) {
      final matchesQuery = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.tags.any(
              (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesFilter =
          _selectedFilter == 'All' || r.category == _selectedFilter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Restaurants & Cafés',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search_rounded),
            tooltip: 'Search by product',
            onPressed: () =>
                Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search restaurants, cafés…',
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textMuted, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              itemCount: AppConstants.restaurantCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = AppConstants.restaurantCategories[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFE0D9CF),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            child: Text(
              '${restaurants.length} place${restaurants.length == 1 ? '' : 's'} found',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: restaurants.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: restaurants.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) => RestaurantCard(
                      restaurant: restaurants[index],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64,
              color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}