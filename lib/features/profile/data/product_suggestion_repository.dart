import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';

class ProductSuggestionRepository {
  final ApiClient _apiClient = locator<ApiClient>();

  Future<Result<bool, Failure>> suggestProduct({
    required String suggestions,
    required String suggestedBy,
  }) async {
    final result = await _apiClient.post(
      ApiUrl.productSuggestions,
      data: {
        'suggestions': suggestions,
        'suggestedBy': suggestedBy,
      },
    );

    return result.when(
      success: (data) {
        if (data is Map && data['status'] == 'SUCCESS') {
          return const Success(true);
        } else {
          return const Error(ServerFailure('Failed to submit suggestion'));
        }
      },
      failure: (failure) => Error(failure),
    );
  }
}
