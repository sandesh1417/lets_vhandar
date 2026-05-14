import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/brand_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/brand_modal.dart';

final brandProvider = FutureProvider<List<BrandData>>((ref) async {
  final brandRepository = locator<BrandRepository>();
  final result = await brandRepository.getBrands();

  switch (result) {
    case Success(value: final brandModal):
      return brandModal.data ?? [];
    case Error(failure: final failure):
      throw failure;
  }
});

final brandBySlugProvider =
    FutureProvider.family<BrandData, String>((ref, slug) async {
  final brandRepository = locator<BrandRepository>();
  final result = await brandRepository.getBrandBySlug(slug);

  switch (result) {
    case Success(value: final brand):
      return brand;
    case Error(failure: final failure):
      throw failure;
  }
});
final brandByIdProvider = FutureProvider.family<BrandData?, String>((ref, id) async {
  if (id.isEmpty) return null;
  final brands = await ref.watch(brandProvider.future);
  try {
    return brands.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
});
