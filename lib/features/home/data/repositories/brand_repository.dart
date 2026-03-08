import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/home/domain/models/brand_modal.dart';

class BrandRepository {
  final ApiClient _apiClient;

  BrandRepository(this._apiClient);

  Future<Result<BrandModal, Failure>> getBrands({
    String status = 'active',
    int page = 1,
    int limit = 1000,
  }) async {
    final result = await _apiClient.get(
      ApiUrl.brands,
      queryParameters: {
        'status': status,
        'page': page,
        'limit': limit,
      },
    );

    switch (result) {
      case Success(value: final data):
        return Success(BrandModal.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }

  Future<Result<BrandData, Failure>> getBrandBySlug(String slug) async {
    // There isn't a direct "brand by slug" endpoint documented yet,
    // but usually it's brands/name/:slug or similar.
    // Given the previous pattern for categories: categories/name/$name
    // Let's assume brands/name/$slug if it exists, otherwise we filter from all brands.

    // For now, let's fetch all brands and filter locally if a specific endpoint isn't known,
    // OR we can try the assumed endpoint.
    // The user's provided link was api.vhandar.com/brands?status=active...

    final result = await getBrands();

    switch (result) {
      case Success(value: final modal):
        final brand = modal.data?.firstWhere(
          (element) => element.slug == slug,
          orElse: () => throw const NetworkFailure("Brand not found"),
        );
        if (brand != null) {
          return Success(brand);
        }
        return const Error(NetworkFailure("Brand not found"));
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
