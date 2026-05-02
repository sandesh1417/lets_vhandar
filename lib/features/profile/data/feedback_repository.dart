import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';

class FeedbackRepository {
  final ApiClient _apiClient = locator<ApiClient>();

  Future<Result<bool, Failure>> submitFeedback({
    required String description,
    required String ratings,
    required String createdBy,
    required String category,
  }) async {
    final result = await _apiClient.post(
      ApiUrl.feedbacks,
      data: {
        'description': description,
        'ratings': ratings,
        'createdBy': createdBy,
        'category': category,
      },
    );

    return result.when(
      success: (data) {
        if (data is Map && data['status'] == 'SUCCESS') {
          return const Success(true);
        } else {
          return const Error(ServerFailure('Failed to submit feedback'));
        }
      },
      failure: (failure) => Error(failure),
    );
  }
}
