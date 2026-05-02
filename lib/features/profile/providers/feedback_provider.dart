import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/profile/data/feedback_repository.dart';

final feedbackRepositoryProvider = Provider((ref) => FeedbackRepository());

class FeedbackState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  FeedbackState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  final FeedbackRepository _repository;

  FeedbackNotifier(this._repository) : super(FeedbackState());

  Future<void> submitFeedback({
    required String description,
    required String ratings,
    required String createdBy,
    required String category,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    final result = await _repository.submitFeedback(
      description: description,
      ratings: ratings,
      createdBy: createdBy,
      category: category,
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
    state = FeedbackState();
  }
}

final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
  return FeedbackNotifier(ref.watch(feedbackRepositoryProvider));
});
