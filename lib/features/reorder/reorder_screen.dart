import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/connectivity_provider.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/widgets/app_refresh_indicator.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/premium_search_bar.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

// Fetches live product data for all past order products and returns only in-stock ones
final reorderLiveProductsProvider =
    FutureProvider<List<ProductData>>((ref) async {
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
  final futures = uniqueIds.map((id) => repository.getProductById(id).timeout(
      const Duration(seconds: 8),
      onTimeout: () => const Error(NetworkFailure('timeout'))));
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
  final _query = ValueNotifier<String>('');
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(loginProvider).user?.id;
      if (userId != null && ref.read(orderProvider).orders.isEmpty) {
        ref.read(orderProvider.notifier).loadOrders(userId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listenManual(tabReactivateProvider(3), (prev, next) {
      if (_scrollController.hasClients && _scrollController.offset > 0) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      } else {
        _onRefresh();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _query.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<ProductData> _filterProducts(List<ProductData> products, String q) {
    if (q.isEmpty) return products;
    return products
        .where((p) => p.name?.toLowerCase().contains(q) ?? false)
        .toList();
  }

  Future<void> _onRefresh() async {
    final userId = ref.read(loginProvider).user?.id;
    if (userId != null) {
      ref.read(orderProvider.notifier).loadOrders(userId);
      while (ref.read(orderProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
      }
    }
    if (!mounted) return;
    ref.invalidate(reorderLiveProductsProvider);
    await ref.read(reorderLiveProductsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(connectivityProvider).maybeWhen(
          data: (online) => !online,
          orElse: () => false,
        );

    if (isOffline) {
      return CustomScaffoldWrapper(
        isScrollable: false,
        bottomSafeArea: false,
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
        body: const _OfflineBody(),
      );
    }

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
                  child: CustomElevatedButton(
                    onPressed: () => context.go(LVRoute.loginScreen.route),
                    backgroundColor: AppColor.secondary,
                    foregroundColor: const Color(0xFF1A1A1A),
                    text: 'Login',
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
              onChanged: (v) => _query.value = v.trim().toLowerCase(),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: _query,
        builder: (context, query, _) {
          if (orderState.isLoading) return _buildShimmer();
          return ref.watch(reorderLiveProductsProvider).when(
                data: (products) {
                  final filtered = _filterProducts(products, query);
                  return AppRefreshIndicator(
                    onRefresh: _onRefresh,
                    child: filtered.isEmpty
                        ? _buildEmptyState()
                        : _buildGrid(filtered, bottomPad),
                  );
                },
                loading: () => _buildShimmer(),
                error: (_, __) => AppRefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _buildEmptyState(),
                ),
              );
        },
      ),
    );
  }

  Widget _buildGrid(List<ProductData> products, double bottomPad) {
    return GridView.builder(
      controller: _scrollController,
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
        return RepaintBoundary(
          child: ProductItemCard(
            key: ValueKey(product.id),
            product: product,
            width: double.infinity,
            margin: EdgeInsets.zero,
            onTap: () => context.push(
              LVRoute.productDetailScreen.route,
              extra: product,
            ),
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

class _OfflineBody extends StatelessWidget {
  const _OfflineBody();

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/offline.svg',
              width: 100.w,
              height: 100.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                color: AppColor.primary,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: vc.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your Wi-Fi or mobile data\nand try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: vc.onSurfaceMuted,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
