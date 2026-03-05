import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/home/domain/models/banner_modal.dart';

class BannerRepository {
  final ApiClient _apiClient;

  BannerRepository(this._apiClient);

  Future<Result<BannerModal, Failure>> getBanners() async {
    final result = await _apiClient.get(ApiUrl.banners);

    switch (result) {
      case Success(value: final data):
        return Success(BannerModal.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
