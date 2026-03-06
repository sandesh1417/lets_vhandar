import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/category_repository.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/domain/models/sub_category_modal.dart';

final categoryBySlugProvider =
    FutureProvider.family<CategoryData, String>((ref, slug) async {
  final repository = locator<CategoryRepository>();
  final result = await repository.getCategoryBySlug(slug);

  switch (result) {
    case Success(value: final category):
      return category;
    case Error(failure: final failure):
      throw failure;
  }
});

final subCategoriesProvider =
    FutureProvider.family<List<SubCategoryData>, String>((ref, slug) async {
  final repository = locator<CategoryRepository>();
  final result = await repository.getSubCategories(slug);

  switch (result) {
    case Success(value: final subCategoryModal):
      return subCategoryModal.data?.data ?? [];
    case Error(failure: final failure):
      throw failure;
  }
});

final selectedSubCategorySlugProvider =
    StateProvider.autoDispose.family<String?, String>((ref, slug) => null);

final categoryProductsProvider =
    FutureProvider.family<List<ProductData>, String>((ref, slug) async {
  final subCategorySlug = ref.watch(selectedSubCategorySlugProvider(slug));
  final categoryAsync = ref.watch(categoryBySlugProvider(slug));
  final subCategoriesAsync = ref.watch(subCategoriesProvider(slug));

  final repository = locator<ProductRepository>();

  String? subCategoryId;
  if (subCategorySlug != null) {
    // Try to find the subCategoryId from the fetched sub-categories list
    final subs = subCategoriesAsync.value ?? [];
    try {
      subCategoryId = subs.firstWhere((s) => s.slug == subCategorySlug).id;
    } catch (_) {
      // Fallback or leave as null
    }
  }

  final result = await repository.getProducts(
    categoryId: categoryAsync.value?.id,
    subCategoryId: subCategoryId,
    categorySlug: slug,
    subCategorySlug: subCategorySlug,
    limit: 100,
  );

  switch (result) {
    case Success(value: final products):
      return products;
    case Error(failure: final failure):
      throw failure;
  }
});
