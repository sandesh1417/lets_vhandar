import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class SearchState {
  final bool isLoading;
  final List<ProductData> results;
  final String? error;

  SearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  SearchState copyWith({
    bool? isLoading,
    List<ProductData>? results,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
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
          state = state.copyWith(isLoading: false, results: products);
        },
        failure: (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
