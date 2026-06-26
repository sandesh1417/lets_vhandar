import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/local/json_cache.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/category_repository.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/domain/models/sub_category_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_variants_provider.dart';

// Stale-while-revalidate caching for the category-detail header and the
// subcategory chips — these are keyed per category slug, paint instantly from an
// in-memory/disk cache on revisit, then refresh from the network in the
// background. See category_provider.dart for the same pattern on the lists.

/// Category meta (title/banner) for the detail header, keyed by slug.
class CategoryBySlugNotifier extends FamilyAsyncNotifier<CategoryData, String> {
  static final Map<String, CategoryData> _memory = {};
  bool _disposed = false;

  String get _cacheKey => 'cache_category_$arg';

  @override
  Future<CategoryData> build(String arg) async {
    ref.onDispose(() => _disposed = true);

    final mem = _memory[arg];
    if (mem != null) {
      _revalidate();
      return mem;
    }
    final cached = await _readCache();
    if (cached != null) {
      _memory[arg] = cached;
      _revalidate();
      return cached;
    }
    return _fetch();
  }

  Future<CategoryData> _fetch() async {
    final repository = locator<CategoryRepository>();
    final result = await repository.getCategoryBySlug(arg);
    switch (result) {
      case Success(value: final category):
        _memory[arg] = category;
        JsonCache.write(_cacheKey, json.encode(category.toMap()));
        return category;
      case Error(failure: final failure):
        throw failure;
    }
  }

  void _revalidate() {
    _fetch().then((fresh) {
      if (!_disposed) state = AsyncData(fresh);
    }).catchError((_) {});
  }

  Future<CategoryData?> _readCache() async {
    final str = await JsonCache.read(_cacheKey);
    if (str == null) return null;
    try {
      return CategoryData.fromMap(json.decode(str));
    } catch (_) {
      return null;
    }
  }
}

final categoryBySlugProvider = AsyncNotifierProvider.family<
    CategoryBySlugNotifier, CategoryData, String>(CategoryBySlugNotifier.new);

/// Subcategory chips for a category, keyed by slug.
class SubCategoriesNotifier
    extends FamilyAsyncNotifier<List<SubCategoryData>, String> {
  static final Map<String, List<SubCategoryData>> _memory = {};
  bool _disposed = false;

  String get _cacheKey => 'cache_subcategories_$arg';

  @override
  Future<List<SubCategoryData>> build(String arg) async {
    ref.onDispose(() => _disposed = true);

    final mem = _memory[arg];
    if (mem != null) {
      _revalidate();
      return mem;
    }
    final cached = await _readCache();
    if (cached != null) {
      _memory[arg] = cached;
      _revalidate();
      return cached;
    }
    return _fetch();
  }

  Future<List<SubCategoryData>> _fetch() async {
    final repository = locator<CategoryRepository>();
    final result = await repository.getSubCategories(arg);
    switch (result) {
      case Success(value: final subCategoryModal):
        final data = subCategoryModal.data?.data ?? [];
        _memory[arg] = data;
        JsonCache.write(_cacheKey, subCategoryModal.toJson());
        return data;
      case Error(failure: final failure):
        throw failure;
    }
  }

  void _revalidate() {
    _fetch().then((fresh) {
      if (!_disposed) state = AsyncData(fresh);
    }).catchError((_) {});
  }

  Future<List<SubCategoryData>?> _readCache() async {
    final str = await JsonCache.read(_cacheKey);
    if (str == null) return null;
    try {
      final data = SubCategoryModal.fromJson(str).data?.data ?? [];
      return data.isEmpty ? null : data;
    } catch (_) {
      return null;
    }
  }
}

final subCategoriesProvider = AsyncNotifierProvider.family<
    SubCategoriesNotifier,
    List<SubCategoryData>,
    String>(SubCategoriesNotifier.new);

final subCategoryBySlugProvider =
    FutureProvider.family<SubCategoryData?, String>((ref, subSlug) async {
  final repository = locator<CategoryRepository>();
  final result = await repository.getSubCategoryBySlug(subSlug);
  return result.when(success: (v) => v, failure: (_) => null);
});

final selectedSubCategorySlugProvider =
    StateProvider.autoDispose.family<String?, String>((ref, slug) => null);

final selectedSortProvider = StateProvider.autoDispose
    .family<String?, String>((ref, slug) => 'relevance');

final searchQueryProvider =
    StateProvider.autoDispose.family<String, String>((ref, slug) => '');

/// Products for a category, filtered by the currently selected subcategory.
///
/// Stale-while-revalidate like the providers above, with two nuances:
///   • The cache is keyed by category **and** subcategory, so switching chips
///     re-uses any list already loaded this session instead of re-fetching.
///   • Only the default "All" grid (no subcategory) is persisted to disk — that
///     is the view shown the instant a category opens, so it benefits most from
///     a cold-start cache. Subcategory-filtered grids stay in memory only, which
///     keeps SharedPreferences small.
class CategoryProductsNotifier
    extends FamilyAsyncNotifier<List<ProductData>, String> {
  static final Map<String, List<ProductData>> _memory = {};
  bool _disposed = false;
  String? _currentSub;

  String get _diskKey => 'cache_products_$arg';
  String _memKey(String? sub) => '$arg|${sub ?? ''}';

  @override
  Future<List<ProductData>> build(String arg) async {
    ref.onDispose(() => _disposed = true);

    // Re-runs whenever the selected subcategory changes.
    final subSlug = ref.watch(selectedSubCategorySlugProvider(arg));
    _currentSub = subSlug;

    final mem = _memory[_memKey(subSlug)];
    if (mem != null) {
      _revalidate(subSlug);
      return mem;
    }
    // Disk cache only seeds the default (no subcategory) grid.
    if (subSlug == null) {
      final cached = await _readCache();
      if (cached != null) {
        _memory[_memKey(subSlug)] = cached;
        _revalidate(subSlug);
        return cached;
      }
    }
    return _fetch(subSlug);
  }

  Future<List<ProductData>> _fetch(String? subSlug) async {
    final repository = locator<ProductRepository>();

    // Use slugs directly — no need to wait for categoryBySlugProvider or
    // subCategoriesProvider to resolve IDs; the API accepts names/slugs too.
    final result = await repository.getProducts(
      categorySlug: arg,
      subCategorySlug: subSlug,
      limit: 80,
    );

    switch (result) {
      case Success(value: final products):
        final expanded = await expandProductsWithVariants(products);
        _memory[_memKey(subSlug)] = expanded;
        if (subSlug == null) {
          // Persist the raw (un-expanded) list; expansion is cheap & applied on
          // read so cached and fresh data go through the same path.
          JsonCache.write(
            _diskKey,
            json.encode(products.map((e) => e.toMap()).toList()),
          );
        }
        return expanded;
      case Error(failure: final failure):
        throw failure;
    }
  }

  void _revalidate(String? subSlug) {
    _fetch(subSlug).then((fresh) {
      // Drop the result if the user switched subcategory mid-flight.
      if (!_disposed && subSlug == _currentSub) state = AsyncData(fresh);
    }).catchError((_) {});
  }

  Future<List<ProductData>?> _readCache() async {
    final str = await JsonCache.read(_diskKey);
    if (str == null) return null;
    try {
      final raw = (json.decode(str) as List)
          .map((e) => ProductData.fromMap(e as Map<String, dynamic>))
          .toList();
      if (raw.isEmpty) return null;
      return expandProductsWithVariants(raw);
    } catch (_) {
      return null;
    }
  }
}

final categoryProductsProvider = AsyncNotifierProvider.family<
    CategoryProductsNotifier,
    List<ProductData>,
    String>(CategoryProductsNotifier.new);

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
