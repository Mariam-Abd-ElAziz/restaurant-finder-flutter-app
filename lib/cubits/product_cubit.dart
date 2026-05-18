import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../services/repository.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> all;
  final List<Product> visible;

  final int currentPage;
  final int totalPages;

  ProductLoaded({
    required this.all,
    required this.visible,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPrevPage => currentPage > 1;
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
      final all =
          await repository.fetchProducts(restaurantId: restaurantId);

      _emitFiltered(all: all, page: 1);
    } catch (e) {
      emit(ProductError('Could not load products.\n$e'));
    }
  }

  void nextPage() {
    final current = state;
    if (current is! ProductLoaded || !current.hasNextPage) return;

    _emitFiltered(
      all: current.all,
      page: current.currentPage + 1,
    );
  }

  void prevPage() {
    final current = state;
    if (current is! ProductLoaded || !current.hasPrevPage) return;

    _emitFiltered(
      all: current.all,
      page: current.currentPage - 1,
    );
  }

  void _emitFiltered({
    required List<Product> all,
    required int page,
  }) {
    final totalPages = (all.length / _pageSize).ceil();
    final safePage = page.clamp(1, totalPages == 0 ? 1 : totalPages);

    final start = (safePage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);

    final visible = all.sublist(start, end);

    emit(ProductLoaded(
      all: all,
      visible: visible,
      currentPage: safePage,
      totalPages: totalPages == 0 ? 1 : totalPages,
    ));
  }
}