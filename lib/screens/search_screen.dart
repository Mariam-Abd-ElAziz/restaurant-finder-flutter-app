import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/restaurant_card.dart';
import '../cubits/search_cubit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    // Load the product names for the dropdown
    final cubit = context.read<SearchCubit>();
    if (cubit.state is SearchInitial) {
      cubit.loadProductNames();
    }
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
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          final productNames = _getNames(state);
          final selectedProduct = _getSelected(state);
          final isLoading =
              state is SearchNamesLoading || state is SearchLoading;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dropdown header ────────────────────────────────────────
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select a product to find where it's served",
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
                      child: state is SearchNamesLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Loading products…',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 14)),
                                ],
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedProduct,
                                isExpanded: true,
                                hint: const Text(
                                  'Choose a product…',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14),
                                ),
                                icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.textMuted),
                                items: productNames
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p,
                                            style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    context.read<SearchCubit>().search(v);
                                  }
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // ── Results header ─────────────────────────────────────────
              if (selectedProduct != null)
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: isLoading
                            ? const Text('Searching…',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted))
                            : state is SearchLoaded
                                ? Text(
                                    '${state.allResults.length} restaurant'
                                    '${state.allResults.length == 1 ? '' : 's'}'
                                    ' serve "$selectedProduct"',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                      // List / Map toggle
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFE0D9CF)),
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

              // ── Main content ───────────────────────────────────────────
              Expanded(child: _buildBody(context, state, selectedProduct)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, SearchState state, String? selectedProduct) {
    if (state is SearchNamesLoading || state is SearchInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (selectedProduct == null) return _buildPrompt();

    if (state is SearchLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is SearchError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 56, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    context.read<SearchCubit>().search(selectedProduct),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is SearchLoaded) {
      if (state.allResults.isEmpty) return _buildNoResults(selectedProduct);
      return Column(
        children: [
          Expanded(
            child: _isMapView
                ? _buildMapView(state)
                : _buildListView(context, state),
          ),
          if (state.totalPages > 1) _buildPagination(context, state),
        ],
      );
    }

    return _buildPrompt();
  }

  Widget _buildListView(BuildContext context, SearchLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = state.visible[index];
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

  Widget _buildMapView(SearchLoaded state) {
    return Stack(
      children: [
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
                const Text('Map View',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted)),
                const SizedBox(height: 6),
                const Text('Integrate google_maps_flutter here',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
        ...state.visible.asMap().entries.map((entry) {
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

  Widget _buildPagination(BuildContext context, SearchLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: Color(0xFFE8E2D9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: state.hasPrevPage
                ? () => context.read<SearchCubit>().prevPage()
                : null,
            child: Row(
              children: [
                Icon(Icons.chevron_left_rounded,
                    size: 20,
                    color: state.hasPrevPage
                        ? AppColors.primary
                        : AppColors.textMuted),
                Text('Prev',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: state.hasPrevPage
                            ? AppColors.primary
                            : AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            'Page ${state.currentPage} of ${state.totalPages}',
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: state.hasNextPage
                ? () => context.read<SearchCubit>().nextPage()
                : null,
            child: Row(
              children: [
                Text('Next',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: state.hasNextPage
                            ? AppColors.primary
                            : AppColors.textMuted)),
                Icon(Icons.chevron_right_rounded,
                    size: 20,
                    color: state.hasNextPage
                        ? AppColors.primary
                        : AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRestaurantBottomSheet(dynamic r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
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
              size: 72, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Pick a product above',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted)),
          const SizedBox(height: 6),
          const Text("We'll show you all restaurants that serve it",
              style:
                  TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildNoResults(String product) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food_rounded,
              size: 72, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('No results for "$product"',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted)),
          const SizedBox(height: 6),
          const Text('Try a different product',
              style:
                  TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<String> _getNames(SearchState state) {
    if (state is SearchNamesLoaded) return state.productNames;
    if (state is SearchLoading) return state.productNames;
    if (state is SearchLoaded) return state.productNames;
    if (state is SearchError) return state.productNames;
    return [];
  }

  String? _getSelected(SearchState state) {
    if (state is SearchLoaded) return state.query;
    if (state is SearchLoading) return null;
    return null;
  }
}

// ── View Toggle Button ────────────────────────────────────────────────────────

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
