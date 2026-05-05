import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/restaurant_card.dart';
import '../models/restaurant.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // All available products to pick from
  final List<String> _allProducts = const [
    'Grilled Chicken',
    'Beef Burger',
    'Caesar Salad',
    'Onion Soup',
    'Mango Cheesecake',
    'Chocolate Lava Cake',
    'Fresh Orange Juice',
    'Iced Latte',
    'Shawarma',
    'Falafel Wrap',
    'Margherita Pizza',
    'Pasta Carbonara',
    'Sushi Roll',
    'Pad Thai',
    'Waffles',
  ];

  String? _selectedProduct;
  bool _isMapView = false;
  bool _isSearching = false;

  // Sample results — replace with API call:
  // GET ${AppConstants.baseUrl}${AppConstants.searchEndpoint}?product={name}
  final List<Restaurant> _results = const [
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
  ];

  Future<void> _search() async {
    if (_selectedProduct == null) return;
    setState(() => _isSearching = true);

    // TODO: Replace with real API call
    // final response = await http.get(
    //   Uri.parse('${AppConstants.baseUrl}${AppConstants.searchEndpoint}?product=$_selectedProduct'),
    // );
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search by Product',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a product to find where it\'s served',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedProduct,
                      isExpanded: true,
                      hint: const Text(
                        'Choose a product…',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 14),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textMuted),
                      items: _allProducts
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedProduct = v);
                        _search();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_selectedProduct != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _isSearching
                        ? const Text(
                            'Searching…',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted),
                          )
                        : Text(
                            '${_results.length} restaurant${_results.length == 1 ? '' : 's'} serve "$_selectedProduct"',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                  // List / Map toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFFE0D9CF)),
                    ),
                    child: Row(
                      children: [
                        _ViewToggleBtn(
                          icon: Icons.list_rounded,
                          label: 'List',
                          isActive: !_isMapView,
                          onTap: () =>
                              setState(() => _isMapView = false),
                        ),
                        _ViewToggleBtn(
                          icon: Icons.map_outlined,
                          label: 'Map',
                          isActive: _isMapView,
                          onTap: () =>
                              setState(() => _isMapView = true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _selectedProduct == null
                ? _buildPrompt()
                : _isSearching
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _results.isEmpty
                        ? _buildNoResults()
                        : _isMapView
                            ? _buildMapView()
                            : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = _results[index];
        return RestaurantCard(
          restaurant: r,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.directions,
            arguments: r,
          ),
        );
      },
    );
  }

  // ── Map View (placeholder — wire up google_maps_flutter) ─────────────
  Widget _buildMapView() {
    return Stack(
      children: [
        // Map placeholder background
        Container(
          color: const Color(0xFFE8E4DC),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.25)),
                const SizedBox(height: 16),
                const Text(
                  'Map View',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Integrate google_maps_flutter here',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),

        // Floating pins for each result
        ..._results.asMap().entries.map((entry) {
          final index = entry.key;
          final r = entry.value;
          return Positioned(
            bottom: 100 + (index * 80.0),
            left: 40 + (index * 90.0),
            child: GestureDetector(
              onTap: () => _showRestaurantBottomSheet(r),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      r.name.split(' ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      color: AppColors.primary, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showRestaurantBottomSheet(Restaurant r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D9CF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(r.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(r.address,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.directions,
                      arguments: r);
                },
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded,
              size: 72,
              color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'Pick a product above',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'We\'ll show you all restaurants that serve it',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food_rounded,
              size: 72,
              color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No results for "$_selectedProduct"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different product',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── View Toggle Button ───────────────────────────────────────────────────────

class _ViewToggleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleBtn({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 14,
                color: isActive ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}