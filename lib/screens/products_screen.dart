// products_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/product_cubit.dart';
import '../models/restaurant.dart';
import '../theme/app_colors.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends State<ProductsScreen> {
  Restaurant? _restaurant;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      _restaurant =
          ModalRoute.of(context)
              ?.settings
              .arguments as Restaurant?;

      context
          .read<ProductCubit>()
          .fetchProducts(
            restaurantId: _restaurant?.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // APP BAR
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor:
                    AppColors.primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _restaurant?.name ??
                        'Menu',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
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
                        color: AppColors
                            .primary
                            .withOpacity(0.25),
                      ),
                    ),
                  ),
                ),
              ),

              // RESTAURANT INFO
              if (_restaurant != null)
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.card,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .location_on_outlined,
                          color:
                              AppColors.textMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            _restaurant!.address,
                            style:
                                const TextStyle(
                              fontSize: 12,
                              color: AppColors
                                  .textMuted,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Icon(
                          Icons.star_rounded,
                          color:
                              Color(0xFFFBBC04),
                          size: 14,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          _restaurant!.rating
                              .toStringAsFixed(
                                  1),
                          style:
                              const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration:
                              BoxDecoration(
                            color: _restaurant!
                                    .isOpen
                                ? const Color(
                                    0xFF22C55E)
                                : AppColors
                                    .textMuted,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        20),
                          ),
                          child: Text(
                            _restaurant!
                                    .isOpen
                                ? 'Open'
                                : 'Closed',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // LOADING
              if (state is ProductLoading ||
                  state is ProductInitial)
                const SliverFillRemaining(
                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          AppColors.primary,
                    ),
                  ),
                )

              // ERROR
              else if (state is ProductError)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                              24),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Icon(
                            Icons
                                .wifi_off_rounded,
                            size: 56,
                            color: AppColors
                                .textMuted,
                          ),

                          const SizedBox(
                              height: 16),

                          Text(
                            state.message,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color: AppColors
                                  .textMuted,
                            ),
                          ),

                          const SizedBox(
                              height: 20),

                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<
                                      ProductCubit>()
                                  .fetchProducts(
                                    restaurantId:
                                        _restaurant
                                            ?.id,
                                  );
                            },
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  AppColors
                                      .primary,
                              foregroundColor:
                                  Colors.white,
                            ),
                            child:
                                const Text(
                              'Retry',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              // LOADED
              else if (state is ProductLoaded) ...[
                // PRODUCTS LIST
                if (state.visible.isNotEmpty)
                  SliverPadding(
                    padding:
                        const EdgeInsets.all(
                            16),
                    sliver: SliverList(
                      delegate:
                          SliverChildBuilderDelegate(
                        (context, index) {
                          final product =
                              state.visible[
                                  index];

                          return Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              bottom: 14,
                            ),
                            child: ProductCard(
                              product: product,
                            ),
                          );
                        },
                        childCount:
                            state.visible
                                .length,
                      ),
                    ),
                  ),

                // EMPTY STATE
                if (state.visible.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors
                              .textMuted,
                        ),
                      ),
                    ),
                  ),

                // PAGINATION
                if (state.totalPages > 1)
                  SliverToBoxAdapter(
                    child: _buildPagination(
                      context,
                      state,
                    ),
                  ),

                const SliverToBoxAdapter(
                  child:
                      SizedBox(height: 32),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPagination(
    BuildContext context,
    ProductLoaded state,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8E2D9),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: state.hasPrevPage
                ? () {
                    context
                        .read<ProductCubit>()
                        .prevPage();
                  }
                : null,
            child: Row(
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: state.hasPrevPage
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                Text(
                  'Prev',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        state.hasPrevPage
                            ? AppColors
                                .primary
                            : AppColors
                                .textMuted,
                  ),
                ),
              ],
            ),
          ),

          Text(
            'Page ${state.currentPage} of ${state.totalPages}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),

          GestureDetector(
            onTap: state.hasNextPage
                ? () {
                    context
                        .read<ProductCubit>()
                        .nextPage();
                  }
                : null,
            child: Row(
              children: [
                Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        state.hasNextPage
                            ? AppColors
                                .primary
                            : AppColors
                                .textMuted,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: state.hasNextPage
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}