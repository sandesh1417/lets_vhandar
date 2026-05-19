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

/// Dynamically expands a list of products by fetching and adding their variants
/// as separate items in the list. Properly deduplicates to prevent duplicate cards.
Future<List<ProductData>> expandProductsWithVariants(
    List<ProductData> products) async {
  final repository = locator<ProductRepository>();
  final Set<String> addedIds = {};
  final List<ProductData> expanded = [];
  final Set<String> fetchedParentIds = {};

  for (final product in products) {
    if (product.id == null) continue;

    if (addedIds.contains(product.id)) {
      continue;
    }

    if (product.hasVariant == true || product.parentId != null) {
      final parentId = product.parentId ?? product.id;
      if (parentId != null && !fetchedParentIds.contains(parentId)) {
        fetchedParentIds.add(parentId);

        final result = await repository.getProductVariants(parentId);
        
        // Fetch the parent product if current product is a child variant,
        // so that the parent product itself can also be shown as a card!
        ProductData? parentProd;
        if (product.parentId != null) {
          final parentRes = await repository.getProductById(parentId);
          parentRes.when(
            success: (parent) => parentProd = parent,
            failure: (_) {},
          );
        } else {
          parentProd = product;
        }

        await result.when(
          success: (variants) async {
            // Add the parent product first (if found/available)
            if (parentProd != null && !addedIds.contains(parentProd!.id)) {
              addedIds.add(parentProd!.id!);
              expanded.add(parentProd!);
            }
            // Add current product (which might be the child variant)
            if (!addedIds.contains(product.id)) {
              addedIds.add(product.id!);
              expanded.add(product);
            }
            // Add all other variants
            for (final v in variants) {
              if (v.id != null && !addedIds.contains(v.id)) {
                addedIds.add(v.id!);
                expanded.add(v);
              }
            }
          },
          failure: (_) {
            if (parentProd != null && !addedIds.contains(parentProd!.id)) {
              addedIds.add(parentProd!.id!);
              expanded.add(parentProd!);
            }
            if (!addedIds.contains(product.id)) {
              addedIds.add(product.id!);
              expanded.add(product);
            }
          },
        );
      } else {
        if (!addedIds.contains(product.id)) {
          addedIds.add(product.id!);
          expanded.add(product);
        }
      }
    } else {
      if (!addedIds.contains(product.id)) {
        addedIds.add(product.id!);
        expanded.add(product);
      }
    }
  }

  return expanded;
}


