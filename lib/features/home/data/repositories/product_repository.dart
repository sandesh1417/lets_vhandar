import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<Result<List<ProductData>, Failure>> getFeaturedProducts() async {
    try {
      final response = await _apiClient.get(
        ApiUrl.products,
        queryParameters: {
          'status': 'active',
          'isFeatured': 'true',
          'page': 1,
          'limit': 20,
        },
      );

      return switch (response) {
        Success(value: final data) =>
          Success(ProductModal.fromMap(data).data?.data ?? []),
        Error(failure: final failure) => Error(failure),
      };
    } catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  Future<Result<List<ProductData>, Failure>> getProductsByCategory(
      String categoryId) async {
    try {
      final response = await _apiClient.get(
        ApiUrl.products,
        queryParameters: {
          'status': 'active',
          'categoryIds': categoryId,
          'page': 1,
          'limit': 20,
        },
      );

      return switch (response) {
        Success(value: final data) =>
          Success(ProductModal.fromMap(data).data?.data ?? []),
        Error(failure: final failure) => Error(failure),
      };
    } catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  Future<Result<List<ProductData>, Failure>> getProductVariants(
      String parentId) async {
    try {
      final response = await _apiClient.get(
        ApiUrl.products,
        queryParameters: {
          'parentId': parentId,
        },
      );

      // Assuming response is a Success type from ApiClient.get
      // and its value is directly accessible as `response.data`
      // If ApiClient.get also returns a Result type, this needs adjustment.
      // Based on the existing methods, ApiClient.get returns a Result.
      // Let's assume the provided snippet implies `response` here is the `value` from a `Success` result.
      // If `_apiClient.get` returns `Result<dynamic, Failure>`, then `response` would be `Result<dynamic, Failure>`.
      // The snippet `ProductModal.fromMap(response.data)` suggests `response` is already the data, not the `Result` wrapper.
      // This is inconsistent with `getFeaturedProducts` and `getProductsByCategory` where `response` is a `Result`.
      // Let's align with the existing pattern of handling `Result` from `_apiClient.get`.

      return switch (response) {
        Success(value: final data) =>
          Success(ProductModal.fromMap(data).data?.data ?? []),
        Error(failure: final failure) => Error(failure),
      };
    } catch (e) {
      if (e is Failure) return Error(e);
      return Error(NetworkFailure(e.toString()));
    }
  }
}
