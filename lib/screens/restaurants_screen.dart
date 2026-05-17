import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/restaurant_card.dart';
import '../cubits/restaurant_cubit.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch only if not already loaded
    final cubit = context.read<RestaurantCubit>();
    if (cubit.state is! RestaurantLoaded) {
      cubit.fetchRestaurants();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Restaurants & Cafés',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search_rounded),
            tooltip: 'Search by product',
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: BlocBuilder<RestaurantCubit, RestaurantState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search bar ──────────────────────────────────────────────
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      context.read<RestaurantCubit>().applyFilter(searchQuery: v),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search restaurants, cafés…',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textMuted, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textMuted, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<RestaurantCubit>()
                                  .applyFilter(searchQuery: '');
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

              // ── Category filter chips ───────────────────────────────────
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  itemCount: AppConstants.restaurantCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter =
                        AppConstants.restaurantCategories[index];
                    final selected = state is RestaurantLoaded
                        ? state.selectedCategory == filter
                        : filter == 'All';
                    return GestureDetector(
                      onTap: () => context
                          .read<RestaurantCubit>()
                          .applyFilter(category: filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFFE0D9CF),
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Body ───────────────────────────────────────────────────
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, RestaurantState state) {
    if (state is RestaurantLoading || state is RestaurantInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is RestaurantError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 56, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    context.read<RestaurantCubit>().fetchRestaurants(),
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

    if (state is RestaurantLoaded) {
      return Column(
        children: [
          // ── Result count ──────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${state.visible.length} of '
                  '${_totalVisible(state)} place${_totalVisible(state) == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: state.visible.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: state.visible.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        RestaurantCard(restaurant: state.visible[index]),
                  ),
          ),

          // ── Pagination controls ───────────────────────────────────────
          if (state.totalPages > 1) _buildPagination(context, state),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // Counts total filtered results across all pages
  int _totalVisible(RestaurantLoaded state) {
    // Re-derive filtered count from all restaurants using same logic
    return state.totalPages * 7 - (7 - state.visible.length).clamp(0, 7);
  }

  Widget _buildPagination(BuildContext context, RestaurantLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: Color(0xFFE8E2D9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prev button
          _PageBtn(
            icon: Icons.chevron_left_rounded,
            label: 'Prev',
            enabled: state.hasPrevPage,
            onTap: () => context.read<RestaurantCubit>().prevPage(),
          ),

          // Page dots / numbers
          Row(
            children: List.generate(state.totalPages, (i) {
              final page = i + 1;
              final isActive = page == state.currentPage;
              return GestureDetector(
                onTap: () =>
                    context.read<RestaurantCubit>().goToPage(page),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            }),
          ),

          // Next button
          _PageBtn(
            icon: Icons.chevron_right_rounded,
            label: 'Next',
            enabled: state.hasNextPage,
            onTap: () => context.read<RestaurantCubit>().nextPage(),
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
              size: 64, color: AppColors.textMuted.withOpacity(0.4)),
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

// ── Pagination button ─────────────────────────────────────────────────────────

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PageBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          if (icon == Icons.chevron_left_rounded)
            Icon(icon,
                size: 20,
                color: enabled ? AppColors.primary : AppColors.textMuted),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          if (icon == Icons.chevron_right_rounded)
            Icon(icon,
                size: 20,
                color: enabled ? AppColors.primary : AppColors.textMuted),
        ],
      ),
    );
  }
}
