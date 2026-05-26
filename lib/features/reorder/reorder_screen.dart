import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

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

  List<ProductData> _uniqueProducts(List<OrderData> orders) {
    final map = <String, ProductData>{};
    for (final order in orders) {
      for (final p in order.products ?? []) {
        if (p.id != null && !map.containsKey(p.id)) {
          map[p.id!] = _toProductData(p);
        }
      }
    }
    final all = map.values.toList();
    if (_query.isEmpty) return all;
    return all
        .where((p) => p.name?.toLowerCase().contains(_query) ?? false)
        .toList();
  }

  ProductData _toProductData(OrderProduct p) {
    final price = p.pricePerUnit?.toDouble() ?? 0;
    final net = p.netPrice?.toDouble() ?? price;
    final hasDiff = net < price && price > 0;

    // Split "500g" → unitValue=500, unit="g"
    final numMatch = RegExp(r'^(\d+\.?\d*)\s*(.*)$').firstMatch(p.unit ?? '');
    final unitValue = numMatch != null
        ? double.tryParse(numMatch.group(1) ?? '')
        : null;
    final unitLabel = numMatch != null
        ? (numMatch.group(2)?.trim().isNotEmpty == true
            ? numMatch.group(2)!.trim()
            : p.unit)
        : p.unit;

    return ProductData(
      id: p.id,
      name: p.name,
      unit: unitLabel,
      unitValue: unitValue,
      pricePerUnit: price,
      discount: hasDiff
          ? ProductDiscount(type: 'flat', value: price - net)
          : null,
      images: _parseImages(p.images),
    );
  }

  List<ProductImage>? _parseImages(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return null;
    return raw.map((e) {
      String? url;
      if (e is String) {
        url = e.startsWith('http')
            ? e
            : 'https://vhandar.sgp1.digitaloceanspaces.com/$e';
      } else if (e is Map) {
        final v = e['url'];
        if (v is String) {
          url = v.startsWith('http')
              ? v
              : 'https://vhandar.sgp1.digitaloceanspaces.com/$v';
        }
      }
      return ProductImage(url: url);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final orderState = ref.watch(orderProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    if (loginState.isGuest || !loginState.isLoggedIn) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: context.vColors.scaffoldBg,
          body: Column(
            children: [
              Container(
                color: AppColor.primary,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
                    child: Text(
                      'Reorder',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/reorder.svg',
                          width: 180.w,
                          height: 180.w,
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
                            onPressed: () =>
                                context.go(LVRoute.loginScreen.route),
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
              ),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.vColors.scaffoldBg,
        body: Column(
          children: [
            // ── Green header ─────────────────────────────────────────
            Container(
              color: AppColor.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reorder',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        height: 44.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                color: context.isDark
                                    ? Colors.white60
                                    : context.vColors.onSurfaceMuted,
                                size: 20.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: context.isDark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search previous orders...',
                                  hintStyle: TextStyle(
                                    fontSize: 13.sp,
                                    color: context.isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  isCollapsed: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: orderState.isLoading
                  ? _buildShimmer()
                  : _buildContent(orderState, bottomPad),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(OrderState orderState, double bottomPad) {
    final products = _uniqueProducts(orderState.orders);

    if (products.isEmpty) return _buildEmptyState();

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
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/reorder.svg',
              width: 180.w,
              height: 180.w,
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
              'Items you already order will be displayed here',
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
