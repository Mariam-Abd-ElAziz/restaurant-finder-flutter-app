import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/restaurant.dart';
import '../services/repository.dart';


abstract class RestaurantState {}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantLoaded extends RestaurantState {
  /// All restaurants fetched from API (unfiltered)
  final List<Restaurant> all;

  /// Currently visible page items (after filter + search + pagination)
  final List<Restaurant> visible;

  final int currentPage;
  final int totalPages;
  final String searchQuery;
  final String selectedCategory;

  RestaurantLoaded({
    required this.all,
    required this.visible,
    required this.currentPage,
    required this.totalPages,
    required this.searchQuery,
    required this.selectedCategory,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPrevPage => currentPage > 1;
}

class RestaurantError extends RestaurantState {
  final String message;
  RestaurantError(this.message);
}



class RestaurantCubit extends Cubit<RestaurantState> {
  final Repository repository;
  static const int _pageSize = 7;

  RestaurantCubit(this.repository) : super(RestaurantInitial());


  Future<void> fetchRestaurants() async {
    emit(RestaurantLoading());
    try {
      final all = await repository.fetchRestaurants();
      _emitFiltered(
        all: all,
        searchQuery: '',
        selectedCategory: 'All',
        page: 1,
      );
    } catch (e) {
      emit(RestaurantError('Could not load restaurants. Please try again.\n$e'));
    }
  }


  void applyFilter({String? category, String? searchQuery}) {
    final current = state;
    if (current is! RestaurantLoaded) return;

    _emitFiltered(
      all: current.all,
      searchQuery: searchQuery ?? current.searchQuery,
      selectedCategory: category ?? current.selectedCategory,
      page: 1, // always reset to page 1 on filter change
    );
  }


  void nextPage() {
    final current = state;
    if (current is! RestaurantLoaded || !current.hasNextPage) return;
    _emitFiltered(
      all: current.all,
      searchQuery: current.searchQuery,
      selectedCategory: current.selectedCategory,
      page: current.currentPage + 1,
    );
  }

  void prevPage() {
    final current = state;
    if (current is! RestaurantLoaded || !current.hasPrevPage) return;
    _emitFiltered(
      all: current.all,
      searchQuery: current.searchQuery,
      selectedCategory: current.selectedCategory,
      page: current.currentPage - 1,
    );
  }

  void goToPage(int page) {
    final current = state;
    if (current is! RestaurantLoaded) return;
    _emitFiltered(
      all: current.all,
      searchQuery: current.searchQuery,
      selectedCategory: current.selectedCategory,
      page: page,
    );
  }


  void _emitFiltered({
    required List<Restaurant> all,
    required String searchQuery,
    required String selectedCategory,
    required int page,
  }) {
    final q = searchQuery.toLowerCase();

    final filtered = all.where((r) {
      final matchesSearch = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.address.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q));

      final matchesCategory =
          selectedCategory == 'All' || r.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 99999);
    final safePage = page.clamp(1, totalPages);
    final start = (safePage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final visible = filtered.sublist(start, end);

    emit(RestaurantLoaded(
      all: all,
      visible: visible,
      currentPage: safePage,
      totalPages: totalPages,
      searchQuery: searchQuery,
      selectedCategory: selectedCategory,
    ));
  }
}
