import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/banner_repository_impl.dart';
import 'package:lets_vhandar/features/home/domain/models/banner_modal.dart';

final bannerProvider = FutureProvider<List<BannerData>>((ref) async {
  final bannerRepository = locator<BannerRepositoryImpl>();
  final result = await bannerRepository.getBanners();

  switch (result) {
    case Success(value: final bannerModal):
      return bannerModal.data
              ?.where((banner) => banner.type == 'slider')
              .toList() ??
          [];
    case Error(failure: final failure):
      throw failure;
  }
});
