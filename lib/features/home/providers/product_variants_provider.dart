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
