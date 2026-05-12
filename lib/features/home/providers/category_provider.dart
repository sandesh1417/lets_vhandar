import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhandar/core/utils/result.dart';
import 'package:vhandar/di/service_locator.dart';
import 'package:vhandar/features/home/data/repositories/category_repository.dart';
import 'package:vhandar/features/home/domain/models/category_modal.dart';

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

final allCategoryProvider = FutureProvider<List<CategoryData>>((ref) async {
  final categoryRepository = locator<CategoryRepository>();
  final result = await categoryRepository.getCategories();

  switch (result) {
    case Success(value: final categoryModal):
      return categoryModal.data ?? [];
    case Error(failure: final failure):
      throw failure;
  }
});
