import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhandar/di/service_locator.dart';
import 'package:vhandar/features/home/data/repositories/product_repository.dart';
import 'package:vhandar/features/home/domain/models/product_modal.dart';

class SearchState {
  final bool isLoading;
  final List<ProductData> results;
  final List<ProductData> sortedResults;
  final String? error;
  final String selectedSort;

  SearchState({
    this.isLoading = false,
    this.results = const [],
    this.sortedResults = const [],
    this.error,
    this.selectedSort = 'relevance',
  });

  SearchState copyWith({
    bool? isLoading,
    List<ProductData>? results,
    List<ProductData>? sortedResults,
    String? error,
    String? selectedSort,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      sortedResults: sortedResults ?? this.sortedResults,
      error: error,
      selectedSort: selectedSort ?? this.selectedSort,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  Timer? _debounce;
  final _repository = locator<ProductRepository>();

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      state = SearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final result = await _repository.searchProducts(query);

      if (!mounted) return;

      result.when(
        success: (products) {
          state = state.copyWith(
            isLoading: false,
            results: products,
            sortedResults: _sortList(products, state.selectedSort),
          );
        },
        failure: (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
      );
    });
  }

  void setSort(String sort) {
    state = state.copyWith(
      selectedSort: sort,
      sortedResults: _sortList(state.results, sort),
    );
  }

  List<ProductData> _sortList(List<ProductData> products, String sortOption) {
    List<ProductData> sortedList = List.from(products);
    switch (sortOption) {
      case 'price_low_high':
        sortedList.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
        break;
      case 'price_high_low':
        sortedList.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
        break;
      case 'discount_high_low':
        sortedList.sort((a, b) {
          final discountA =
              a.pricePerUnit != null ? (a.pricePerUnit! - a.actualPrice) : 0;
          final discountB =
              b.pricePerUnit != null ? (b.pricePerUnit! - b.actualPrice) : 0;
          return discountB.compareTo(discountA);
        });
        break;
      // case 'discount_low_high':
      //   sortedList.sort((a, b) {
      //     final discountA =
      //         a.pricePerUnit != null ? (a.pricePerUnit! - a.actualPrice) : 0;
      //     final discountB =
      //         b.pricePerUnit != null ? (b.pricePerUnit! - b.actualPrice) : 0;
      //     return discountA.compareTo(discountB);
      //   });
      //   break;
      // case 'name_a_z':
      //   sortedList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      //   break;
      // case 'relevance':
      // default:
      //   // Keep original order
      //   break;
    }
    return sortedList;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
