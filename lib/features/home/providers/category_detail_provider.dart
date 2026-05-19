import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/category_repository.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/domain/models/sub_category_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_variants_provider.dart';

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

final selectedSortProvider = StateProvider.autoDispose
    .family<String?, String>((ref, slug) => 'relevance');

final searchQueryProvider =
    StateProvider.autoDispose.family<String, String>((ref, slug) => '');


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

  // Fetch products with only category/sub-category filters
  final result = await repository.getProducts(
    categoryId: categoryAsync.value?.id,
    subCategoryId: subCategoryId,
    categorySlug: slug,
    subCategorySlug: subCategorySlug,
    limit: 1000, // Fetch a larger batch for local filtering
  );

  switch (result) {
    case Success(value: final products):
      return expandProductsWithVariants(products);
    case Error(failure: final failure):
      throw failure;
  }
});

/// Local filtering and sorting provider
final filteredProductsProvider =
    Provider.family<AsyncValue<List<ProductData>>, String>((ref, slug) {
  final productsAsync = ref.watch(categoryProductsProvider(slug));
  final searchQuery = ref.watch(searchQueryProvider(slug)).toLowerCase();
  final sortOption = ref.watch(selectedSortProvider(slug));

  return productsAsync.whenData((products) {
    // 1. Filtering
    List<ProductData> filteredList = List.from(products);
    if (searchQuery.isNotEmpty) {
      filteredList = filteredList.where((product) {
        final name = product.name?.toLowerCase() ?? '';
        return name.contains(searchQuery);
      }).toList();
    }

    // 2. Sorting
    switch (sortOption) {
      case 'price_low_high':
        filteredList.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
        break;
      case 'price_high_low':
        filteredList.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
        break;
      case 'discount_high_low':
        filteredList.sort((a, b) {
          final discountA =
              a.pricePerUnit != null ? (a.pricePerUnit! - a.actualPrice) : 0;
          final discountB =
              b.pricePerUnit != null ? (b.pricePerUnit! - b.actualPrice) : 0;
          return discountB.compareTo(discountA);
        });
        break;
      case 'discount_low_high':
        filteredList.sort((a, b) {
          final discountA =
              a.pricePerUnit != null ? (a.pricePerUnit! - a.actualPrice) : 0;
          final discountB =
              b.pricePerUnit != null ? (b.pricePerUnit! - b.actualPrice) : 0;
          return discountA.compareTo(discountB);
        });
        break;
      case 'name_a_z':
        filteredList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case 'relevance':
      default:
        // Keep original API order if "relevance"
        break;
    }

    // print('--- Sorting Grid: $sortOption, filtered count: ${filteredList.length}');
    return filteredList;
  });
});
