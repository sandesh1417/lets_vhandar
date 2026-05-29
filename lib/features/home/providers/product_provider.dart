import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_variants_provider.dart';

final featuredProductsProvider = FutureProvider<List<ProductData>>((ref) async {
  final repository = locator<ProductRepository>();
  final result = await repository.getFeaturedProducts();

  return result.when(
    success: (products) => expandProductsWithVariants(products),
    failure: (failure) => throw failure.message,
  );
});

final similarProductsProvider =
    FutureProvider.family<List<ProductData>, String>((ref, categoryId) async {
  final repository = locator<ProductRepository>();
  final result = await repository.getProductsByCategory(categoryId, limit: 10);

  return result.when(
    success: (products) => products,
    failure: (failure) => throw failure.message,
  );
});
final productsByCategoryProvider =
    FutureProvider.family<List<ProductData>, String>((ref, categoryId) async {
  final repository = locator<ProductRepository>();
  final result = await repository.getProductsByCategory(categoryId);

  return result.when(
    success: (products) => expandProductsWithVariants(products),
    failure: (failure) => throw failure.message,
  );
});
