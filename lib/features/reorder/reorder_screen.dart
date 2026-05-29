import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/premium_search_bar.dart';

// Fetches live product data for all past order products and returns only in-stock ones
final reorderLiveProductsProvider = FutureProvider<List<ProductData>>((ref) async {
  final orders = ref.watch(orderProvider).orders;
  final repository = locator<ProductRepository>();

  final uniqueIds = <String>{};
  for (final order in orders) {
    for (final p in order.products ?? []) {
      if (p.id != null) uniqueIds.add(p.id!);
    }
  }

  if (uniqueIds.isEmpty) return [];

  // Per-request 8-second timeout so one slow endpoint can't hang the whole page
  final futures = uniqueIds.map((id) => repository
      .getProductById(id)
      .timeout(const Duration(seconds: 8), onTimeout: () => const Error(NetworkFailure('timeout'))));
  final results = await Future.wait(futures, eagerError: false);

  final inStock = <ProductData>[];
  for (final result in results) {
    if (result case Success(value: final p)) {
      if (!p.isOutOfStock) inStock.add(p);
    }
  }
  return inStock;
});

class ReorderScreen extends ConsumerStatefulWidget {
  const ReorderScreen({super.key});

  @override
  ConsumerState<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends ConsumerState<ReorderScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(loginProvider).user?.id;
      if (userId != null && ref.read(orderProvider).orders.isEmpty) {
        ref.read(orderProvider.notifier).loadOrders(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductData> _filterProducts(List<ProductData> products) {
    if (_query.isEmpty) return products;
    return products
        .where((p) => p.name?.toLowerCase().contains(_query) ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final orderState = ref.watch(orderProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // ── Not logged in ─────────────────────────────────────────────────────────
    if (loginState.isGuest || !loginState.isLoggedIn) {
      return Scaffold(
        backgroundColor: context.vColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          automaticallyImplyLeading: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          title: Text(
            'Reorder',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              fontFamily: 'Inter',
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/reorder.svg',
                  width: 160.w,
                  height: 160.w,
                ),
                SizedBox(height: 28.h),
                Text(
                  'Reordering will be easy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: context.vColors.onSurface,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Login or create an account to reorder your favourite items instantly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: context.vColors.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(LVRoute.loginScreen.route),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.secondary,
                      foregroundColor: const Color(0xFF1A1A1A),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Login / Sign Up',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Logged in ─────────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: context.vColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          'Reorder',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            fontFamily: 'Inter',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
            child: PremiumSearchBar(
              controller: _searchController,
              hintText: 'Search previous orders...',
              showScanIcon: false,
            ),
          ),
        ),
      ),
      body: orderState.isLoading
          ? _buildShimmer()
          : ref.watch(reorderLiveProductsProvider).when(
                data: (products) {
                  final filtered = _filterProducts(products);
                  if (filtered.isEmpty) return _buildEmptyState();
                  return _buildGrid(filtered, bottomPad);
                },
                loading: () => _buildShimmer(),
                error: (_, __) => _buildEmptyState(),
              ),
    );
  }

  Widget _buildGrid(List<ProductData> products, double bottomPad) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, bottomPad + 150.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        mainAxisExtent: ProductItemCard.preferredHeight,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final product = products[i];
        return ProductItemCard(
          key: ValueKey(product.id),
          product: product,
          width: double.infinity,
          margin: EdgeInsets.zero,
          onTap: () => context.push(
            LVRoute.productDetailScreen.route,
            extra: product,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/reorder.svg',
                      width: 160.w,
                      height: 160.w,
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      'No items to reorder',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: context.vColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Items from your previous orders that are currently in stock will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: context.vColors.onSurfaceMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 16.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        mainAxisExtent: ProductItemCard.preferredHeight,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => CustomShimmer.rectangular(
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
