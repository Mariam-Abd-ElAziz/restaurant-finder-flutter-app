import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/restaurant.dart';
import '../services/repository.dart';


abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchNamesLoading extends SearchState {}

/// Product names loaded — ready to show the dropdown
class SearchNamesLoaded extends SearchState {
  final List<String> productNames;
  SearchNamesLoaded(this.productNames);
}

class SearchLoading extends SearchState {
  final List<String> productNames; // keep names so dropdown stays populated
  SearchLoading(this.productNames);
}

class SearchLoaded extends SearchState {
  final List<String> productNames;
  final String query;

  /// Current page items (after pagination)
  final List<Restaurant> visible;

  /// All matching results (used for count label)
  final List<Restaurant> allResults;

  final int currentPage;
  final int totalPages;

  SearchLoaded({
    required this.productNames,
    required this.query,
    required this.visible,
    required this.allResults,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPrevPage => currentPage > 1;
}

class SearchError extends SearchState {
  final List<String> productNames;
  final String message;
  SearchError(this.productNames, this.message);
}


class SearchCubit extends Cubit<SearchState> {
  final Repository repository;
  static const int _pageSize = 7;

  SearchCubit(this.repository) : super(SearchInitial());


  Future<void> loadProductNames() async {
    emit(SearchNamesLoading());
    try {
      final names = await repository.fetchProductNames();
      emit(SearchNamesLoaded(names));
    } catch (e) {
      emit(SearchError([], 'Could not load products list.'));
    }
  }


  Future<void> search(String productName) async {
    final names = _currentNames();
    emit(SearchLoading(names));
    try {
      final results = await repository.searchByProduct(productName);
      _emitPage(
        productNames: names,
        query: productName,
        allResults: results,
        page: 1,
      );
    } catch (e) {
      emit(SearchError(names, 'Search failed. Please try again.'));
    }
  }


  void nextPage() {
    final current = state;
    if (current is! SearchLoaded || !current.hasNextPage) return;
    _emitPage(
      productNames: current.productNames,
      query: current.query,
      allResults: current.allResults,
      page: current.currentPage + 1,
    );
  }

  void prevPage() {
    final current = state;
    if (current is! SearchLoaded || !current.hasPrevPage) return;
    _emitPage(
      productNames: current.productNames,
      query: current.query,
      allResults: current.allResults,
      page: current.currentPage - 1,
    );
  }


  List<String> _currentNames() {
    final s = state;
    if (s is SearchNamesLoaded) return s.productNames;
    if (s is SearchLoading) return s.productNames;
    if (s is SearchLoaded) return s.productNames;
    if (s is SearchError) return s.productNames;
    return [];
  }

  void _emitPage({
    required List<String> productNames,
    required String query,
    required List<Restaurant> allResults,
    required int page,
  }) {
    final totalPages = (allResults.length / _pageSize).ceil().clamp(1, 99999);
    final safePage = page.clamp(1, totalPages);
    final start = (safePage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, allResults.length);
    final visible = allResults.sublist(start, end);

    emit(SearchLoaded(
      productNames: productNames,
      query: query,
      visible: visible,
      allResults: allResults,
      currentPage: safePage,
      totalPages: totalPages,
    ));
  }
}
