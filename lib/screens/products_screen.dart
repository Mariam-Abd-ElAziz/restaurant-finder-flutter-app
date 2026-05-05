import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/product_card.dart';
import '../models/restaurant.dart';
import '../models/product.dart';



class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'All';

  // Sample data — replace with API call:
  // GET ${AppConstants.baseUrl}${AppConstants.productsEndpoint}?restaurant_id={id}
  final List<Product> _products = const [
    Product(id: 1, name: 'Grilled Chicken', description: 'Tender grilled chicken with herbs and spices', price: 89.00, category: 'Mains', isAvailable: true),
    Product(id: 2, name: 'Beef Burger', description: 'Juicy beef patty with cheddar and pickles', price: 75.00, category: 'Mains', isAvailable: true),
    Product(id: 3, name: 'Caesar Salad', description: 'Fresh romaine, croutons, parmesan, caesar dressing', price: 55.00, category: 'Starters', isAvailable: true),
    Product(id: 4, name: 'Onion Soup', description: 'Classic French onion soup with melted gruyère', price: 45.00, category: 'Starters', isAvailable: false),
    Product(id: 5, name: 'Mango Cheesecake', description: 'Creamy cheesecake with fresh mango topping', price: 40.00, category: 'Desserts', isAvailable: true),
    Product(id: 6, name: 'Chocolate Lava Cake', description: 'Warm chocolate cake with molten center', price: 45.00, category: 'Desserts', isAvailable: true),
    Product(id: 7, name: 'Fresh Orange Juice', description: 'Freshly squeezed orange juice', price: 25.00, category: 'Drinks', isAvailable: true),
    Product(id: 8, name: 'Iced Latte', description: 'Espresso with cold milk over ice', price: 35.00, category: 'Drinks', isAvailable: true),
  ];

  List<String> get _categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<Product> get _filtered => _selectedCategory == 'All'
      ? _products
      : _products.where((p) => p.category == _selectedCategory).toList();

  // Group filtered products by category
  Map<String, List<Product>> get _grouped {
    final map = <String, List<Product>>{};
    for (final p in _filtered) {
      map.putIfAbsent(p.category, () => []).add(p);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant?;
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                restaurant?.name ?? 'Menu',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              background: Container(
                color: AppColors.surface,
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 72,
                    color: AppColors.primary.withOpacity(0.25),
                  ),
                ),
              ),
            ),
          ),

          if (restaurant != null)
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.card,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textMuted, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurant.address,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFBBC04), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? const Color(0xFF22C55E)
                            : AppColors.textMuted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        restaurant.isOpen ? 'Open' : 'Closed',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat),
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
                        cat,
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
          ),

          ...grouped.entries.map((entry) => SliverToBoxAdapter(
                child: _buildCategorySection(entry.key, entry.value),
              )),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${products.length})',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Product cards
          ...products.map((p) => ProductCard(product: p)),
        ],
      ),
    );
  }
}


