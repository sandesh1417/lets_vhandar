import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

final productVariantsProvider =
    FutureProvider.family<List<ProductData>, ProductData>(
        (ref, parentProduct) async {
  if (parentProduct.hasVariant != true) return [parentProduct];

  final repository = locator<ProductRepository>();
  // Fetch variants using the current product's ID as parentId
  final parentId = parentProduct.parentId ?? parentProduct.id;
  final result = await repository.getProductVariants(parentId!);

  return result.when(
    success: (variants) {
      // Create a combined list starting with the parent product
      final combined = [parentProduct, ...variants];
      // Optional: Sort them logically if needed, e.g., by price
      combined.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
      return combined;
    },
    failure: (failure) => throw failure.message,
  );
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

    if (product.hasVariant == true) {
      final parentId = product.parentId ?? product.id;
      if (parentId != null && !fetchedParentIds.contains(parentId)) {
        fetchedParentIds.add(parentId);

        final result = await repository.getProductVariants(parentId);
        result.when(
          success: (variants) {
            // Add current product
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

