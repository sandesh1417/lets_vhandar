import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhandar/core/utils/result.dart';
import 'package:vhandar/features/profile/data/product_suggestion_repository.dart';

final productSuggestionRepositoryProvider = Provider((ref) => ProductSuggestionRepository());

class ProductSuggestionState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ProductSuggestionState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ProductSuggestionState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ProductSuggestionState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProductSuggestionNotifier extends StateNotifier<ProductSuggestionState> {
  final ProductSuggestionRepository _repository;

  ProductSuggestionNotifier(this._repository) : super(ProductSuggestionState());

  Future<void> suggestProduct({
    required String suggestions,
    required String suggestedBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    final result = await _repository.suggestProduct(
      suggestions: suggestions,
      suggestedBy: suggestedBy,
    );

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  void reset() {
    state = ProductSuggestionState();
  }
}

final productSuggestionProvider = StateNotifierProvider<ProductSuggestionNotifier, ProductSuggestionState>((ref) {
  return ProductSuggestionNotifier(ref.watch(productSuggestionRepositoryProvider));
});
