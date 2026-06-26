import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/local/json_cache.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/category_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';

// Category lists almost never change between visits, yet the screens used to
// show a full-screen spinner and re-hit the network every time they were
// opened. These notifiers add stale-while-revalidate caching:
//
//   1. An in-memory snapshot is returned synchronously so re-opening the screen
//      within a session is instant (no spinner, even after `ref.invalidate`).
//   2. A disk copy (SharedPreferences) seeds the very first paint after a cold
//      start, again with no spinner.
//   3. After serving cached data we silently revalidate from the network in the
//      background and push the fresh list into state.
//
// They expose `AsyncValue<List<CategoryData>>` exactly like the old
// FutureProviders, so every existing `ref.watch(...)` / `.future` consumer keeps
// working unchanged.

const _kHomeCategoriesCacheKey = 'cache_home_categories';
const _kAllCategoriesCacheKey = 'cache_all_categories';

/// Home screen's curated category strip.
class HomeCategoryNotifier extends AsyncNotifier<List<CategoryData>> {
  static List<CategoryData>? _memory;
  bool _disposed = false;

  @override
  Future<List<CategoryData>> build() async {
    ref.onDispose(() => _disposed = true);

    if (_memory != null) {
      _revalidate();
      return _memory!;
    }
    final cached = await _readCache();
    if (cached != null) {
      _memory = cached;
      _revalidate();
      return cached;
    }
    return _fetch();
  }

  Future<List<CategoryData>> _fetch() async {
    final repository = locator<CategoryRepository>();
    final result = await repository.getHomeCategories();
    switch (result) {
      case Success(value: final categoryModal):
        final data = categoryModal.data ?? [];
        _memory = data;
        JsonCache.write(_kHomeCategoriesCacheKey, categoryModal.toJson());
        return data;
      case Error(failure: final failure):
        throw failure;
    }
  }

  void _revalidate() {
    _fetch().then((fresh) {
      if (!_disposed) state = AsyncData(fresh);
    }).catchError((_) {
      // Keep showing cached data when the background refresh fails.
    });
  }

  Future<List<CategoryData>?> _readCache() async {
    final str = await JsonCache.read(_kHomeCategoriesCacheKey);
    if (str == null) return null;
    try {
      final data = CategoryModal.fromJson(str).data ?? [];
      return data.isEmpty ? null : data;
    } catch (_) {
      return null;
    }
  }
}

final homeCategoryProvider =
    AsyncNotifierProvider<HomeCategoryNotifier, List<CategoryData>>(
        HomeCategoryNotifier.new);

/// Controls which tab is active in CategoryScreen (0=Category, 1=SubCategory, 2=Brand)
final categoryScreenTabProvider = StateProvider<int>((ref) => 0);

/// Full category list for the Category tab.
class AllCategoryNotifier extends AsyncNotifier<List<CategoryData>> {
  static List<CategoryData>? _memory;
  bool _disposed = false;

  @override
  Future<List<CategoryData>> build() async {
    ref.onDispose(() => _disposed = true);

    if (_memory != null) {
      _revalidate();
      return _memory!;
    }
    final cached = await _readCache();
    if (cached != null) {
      _memory = cached;
      _revalidate();
      return cached;
    }
    return _fetch();
  }

  Future<List<CategoryData>> _fetch() async {
    final repository = locator<CategoryRepository>();
    final result = await repository.getCategories();
    switch (result) {
      case Success(value: final categoryModal):
        final data = categoryModal.data ?? [];
        _memory = data;
        JsonCache.write(_kAllCategoriesCacheKey, categoryModal.toJson());
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

  Future<List<CategoryData>?> _readCache() async {
    final str = await JsonCache.read(_kAllCategoriesCacheKey);
    if (str == null) return null;
    try {
      final data = CategoryModal.fromJson(str).data ?? [];
      return data.isEmpty ? null : data;
    } catch (_) {
      return null;
    }
  }
}

final allCategoryProvider =
    AsyncNotifierProvider<AllCategoryNotifier, List<CategoryData>>(
        AllCategoryNotifier.new);
