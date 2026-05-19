import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_variants_provider.dart';

final brandSelectedSortProvider = StateProvider.autoDispose
    .family<String?, String>((ref, slug) => 'relevance');

final brandSearchQueryProvider =
    StateProvider.autoDispose.family<String, String>((ref, slug) => '');

final brandProductsProvider =
    FutureProvider.family<List<ProductData>, String>((ref, slug) async {
  final brandAsync = ref.watch(brandBySlugProvider(slug));
  final repository = locator<ProductRepository>();

  final result = await repository.getProducts(
    brandId: brandAsync.value?.id,
    brandSlug: slug,
    limit: 1000, // Fetch a larger batch for local filtering
  );

  switch (result) {
    case Success(value: final products):
      return expandProductsWithVariants(products);
    case Error(failure: final failure):
      throw failure;
  }
});

/// Local filtering and sorting provider for Brands
final filteredBrandProductsProvider =
    Provider.family<AsyncValue<List<ProductData>>, String>((ref, slug) {
  final productsAsync = ref.watch(brandProductsProvider(slug));
  final searchQuery = ref.watch(brandSearchQueryProvider(slug)).toLowerCase();
  final sortOption = ref.watch(brandSelectedSortProvider(slug));

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
          final discountB = b.pricePerUnit != null
              ? (b.pricePerUnit! - a.actualPrice)
              : 0; // Fixed a potential typo from category provider (b.actualPrice)
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
        // Keep original API order
        break;
    }

    return filteredList;
  });
});
