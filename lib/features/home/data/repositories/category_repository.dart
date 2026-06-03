import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';
import 'package:lets_vhandar/features/home/domain/models/sub_category_modal.dart';

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

  Future<Result<CategoryModal, Failure>> getCategories() async {
    final result = await _apiClient.get(
      ApiUrl.categories,
      queryParameters: {
        'status': 'active',
        'page': 1,
        'limit': 100,
      },
    );

    switch (result) {
      case Success(value: final data):
        return Success(CategoryModal.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }

  Future<Result<SubCategoryModal, Failure>> getSubCategories(
      String categorySlug) async {
    final result = await _apiClient.get(
      ApiUrl.subCategories,
      queryParameters: {
        'status': 'active',
        'categoryName': categorySlug,
        'page': 1,
        'limit': 1000,
      },
    );

    switch (result) {
      case Success(value: final data):
        return Success(SubCategoryModal.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }

  Future<Result<SubCategoryData?, Failure>> getSubCategoryBySlug(String slug) async {
    final result = await _apiClient.get(ApiUrl.subCategoryByName(slug));

    switch (result) {
      case Success(value: final data):
        if (data["data"] != null) {
          return Success(SubCategoryData.fromMap(data["data"]));
        }
        return const Success(null);
      case Error(failure: final failure):
        return Error(failure);
    }
  }

  Future<Result<CategoryData, Failure>> getCategoryBySlug(String slug) async {
    final result = await _apiClient.get(ApiUrl.categoryByName(slug));

    switch (result) {
      case Success(value: final data):
        // The API returns { "data": { ...categoryData... }, "status": "SUCCESS" }
        if (data["data"] != null) {
          return Success(CategoryData.fromMap(data["data"]));
        }
        return const Error(NetworkFailure("Category data not found"));
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
