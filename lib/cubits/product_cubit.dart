import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../services/repository.dart';


abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  /// All products for this restaurant (unfiltered)
  final List<Product> all;

  /// Currently visible page items (after category filter + pagination)
  final List<Product> visible;

  final int currentPage;
  final int totalPages;
  final String selectedCategory;

  ProductLoaded({
    required this.all,
    required this.visible,
    required this.currentPage,
    required this.totalPages,
    required this.selectedCategory,
  });

  /// Unique sorted categories derived from the full list
  List<String> get categories {
    final cats = all.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPrevPage => currentPage > 1;

  /// Grouped map used by the UI to render section headers
  Map<String, List<Product>> get grouped {
    final map = <String, List<Product>>{};
    for (final p in visible) {
      map.putIfAbsent(p.category, () => []).add(p);
    }
    return map;
  }
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}


class ProductCubit extends Cubit<ProductState> {
  final Repository repository;
  static const int _pageSize = 7;

  ProductCubit(this.repository) : super(ProductInitial());


  Future<void> fetchProducts({int? restaurantId}) async {
    emit(ProductLoading());
    try {
      final all = await repository.fetchProducts(restaurantId: restaurantId);
      _emitFiltered(all: all, category: 'All', page: 1);
    } catch (e) {
      emit(ProductError('Could not load products. Please try again.\n$e'));
    }
  }


  void filterByCategory(String category) {
    final current = state;
    if (current is! ProductLoaded) return;
    _emitFiltered(all: current.all, category: category, page: 1);
  }


  void nextPage() {
    final current = state;
    if (current is! ProductLoaded || !current.hasNextPage) return;
    _emitFiltered(
      all: current.all,
      category: current.selectedCategory,
      page: current.currentPage + 1,
    );
  }

  void prevPage() {
    final current = state;
    if (current is! ProductLoaded || !current.hasPrevPage) return;
    _emitFiltered(
      all: current.all,
      category: current.selectedCategory,
      page: current.currentPage - 1,
    );
  }


  void _emitFiltered({
    required List<Product> all,
    required String category,
    required int page,
  }) {
    final filtered = category == 'All'
        ? all
        : all.where((p) => p.category == category).toList();

    final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 99999);
    final safePage = page.clamp(1, totalPages);
    final start = (safePage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final visible = filtered.sublist(start, end);

    emit(ProductLoaded(
      all: all,
      visible: visible,
      currentPage: safePage,
      totalPages: totalPages,
      selectedCategory: category,
    ));
  }
}
