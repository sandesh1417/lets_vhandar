import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/category_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';

final homeCategoryProvider = FutureProvider<List<CategoryData>>((ref) async {
  final categoryRepository = locator<CategoryRepository>();
  final result = await categoryRepository.getHomeCategories();

  switch (result) {
    case Success(value: final categoryModal):
      return categoryModal.data ?? [];
    case Error(failure: final failure):
      throw failure;
  }
});
