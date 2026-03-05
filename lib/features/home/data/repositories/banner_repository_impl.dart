import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/home/domain/models/banner_modal.dart';

abstract class BannerRepository {
  Future<Result<BannerModal, Failure>> getBanners();
}

class BannerRepositoryImpl implements BannerRepository {
  final ApiClient _apiClient;

  BannerRepositoryImpl(this._apiClient);

  @override
  Future<Result<BannerModal, Failure>> getBanners() async {
    final result = await _apiClient.get('/banners');

    switch (result) {
      case Success(value: final data):
        return Success(BannerModal.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
