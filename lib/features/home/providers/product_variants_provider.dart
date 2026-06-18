import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

final productVariantsProvider =
    FutureProvider.family<List<ProductData>, ProductData>(
        (ref, baseProduct) async {
  final repository = locator<ProductRepository>();

  // If the product is a child variant, we resolve the family using parentId
  if (baseProduct.parentId != null) {
    final parentId = baseProduct.parentId!;
    final variantsResult = await repository.getProductVariants(parentId);
    List<ProductData> variantsList = [];
    variantsResult.when(
      success: (variants) => variantsList = variants,
      failure: (_) {},
    );

    // Fetch the parent product
    ProductData? parentProduct;
    final parentResult = await repository.getProductById(parentId);
    parentResult.when(
      success: (parent) => parentProduct = parent,
      failure: (_) {},
    );

    final List<ProductData> combined = [];
    if (parentProduct != null) {
      combined.add(parentProduct!);
    }
    for (final v in variantsList) {
      if (v.id != parentProduct?.id) {
        combined.add(v);
      }
    }
    if (!combined.any((p) => p.id == baseProduct.id)) {
      combined.add(baseProduct);
    }
    combined.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
    return combined;
  }

  // If it's a parent product (parentId == null), we fetch its child variants dynamically
  final variantsResult = await repository.getProductVariants(baseProduct.id!);
  List<ProductData> variantsList = [];
  variantsResult.when(
    success: (variants) => variantsList = variants,
    failure: (_) {},
  );

  if (variantsList.isEmpty) {
    // No variants found, standalone product
    return [baseProduct];
  }

  // Variants exist! Combine the parent (baseProduct) and all child variants.
  final List<ProductData> combined = [baseProduct];
  for (final v in variantsList) {
    if (v.id != baseProduct.id) {
      combined.add(v);
    }
  }
  combined.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
  return combined;
});

/// Expands products with variants as separate grid cards.
/// Variant fetches are fully parallelised — all families are in-flight at once.
Future<List<ProductData>> expandProductsWithVariants(
    List<ProductData> products) async {
  final repository = locator<ProductRepository>();

  // Split: simple products (no variants) vs variant families keyed by parentId.
  final List<ProductData> simple = [];
  final Map<String, List<ProductData>> families = {};

  for (final product in products) {
    if (product.id == null) continue;
    if (product.hasVariant == true || product.parentId != null) {
      final parentId = product.parentId ?? product.id!;
      families.putIfAbsent(parentId, () => []).add(product);
    } else {
      simple.add(product);
    }
  }

  // Resolve all variant families in parallel.
  final resolved = await Future.wait(
    families.entries.map((e) => _resolveFamily(repository, e.key, e.value)),
  );

  // Merge: simple products first (preserve API order), then families.
  final Set<String> addedIds = {};
  final List<ProductData> result = [];

  for (final p in simple) {
    if (addedIds.add(p.id!)) result.add(p);
  }
  for (final family in resolved) {
    for (final p in family) {
      if (p.id != null && addedIds.add(p.id!)) result.add(p);
    }
  }

  return result;
}

/// Fetches variant + parent data for a single family.
/// Both network calls are fired concurrently before either is awaited.
Future<List<ProductData>> _resolveFamily(
    ProductRepository repo, String parentId, List<ProductData> group) async {
  final isChildGroup = group.any((p) => p.parentId != null);

  // Kick off both requests before awaiting either.
  final variantsFut = repo.getProductVariants(parentId);
  final parentFut = isChildGroup ? repo.getProductById(parentId) : null;

  final variantsResult = await variantsFut;

  ProductData? parentProduct;
  if (parentFut != null) {
    (await parentFut).when(success: (p) => parentProduct = p, failure: (_) {});
  } else {
    try {
      parentProduct = group.firstWhere((p) => p.parentId == null);
    } catch (_) {
      parentProduct = group.first;
    }
  }

  final List<ProductData> family = [];

  variantsResult.when(
    success: (variants) {
      if (parentProduct != null) family.add(parentProduct!);
      for (final v in variants) {
        if (v.id != parentProduct?.id) {
          family.add(v.parentId == null ? v.copyWith(parentId: parentId) : v);
        }
      }
      // Ensure every product from the original group is represented.
      for (final p in group) {
        if (!family.any((f) => f.id == p.id)) {
          family.add((p.parentId == null && p.id != parentId)
              ? p.copyWith(parentId: parentId)
              : p);
        }
      }
    },
    failure: (_) => family.addAll(group),
  );

  return family;
}
