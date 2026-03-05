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
}
