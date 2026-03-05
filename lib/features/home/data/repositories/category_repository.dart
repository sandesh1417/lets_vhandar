import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';

class CategoryRepository {
  final ApiClient _apiClient;

  CategoryRepository(this._apiClient);

  Future<Result<CategoryModal, Failure>> getHomeCategories() async {
    final result = await _apiClient.get(
      ApiUrl.categories,
      queryParameters: {
        'showAtHomepage': true,
        'status': 'active',
        'page': 1,
        'limit': 32,
      },
    );

    switch (result) {
      case Success(value: final data):
        return Success(CategoryModal.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
