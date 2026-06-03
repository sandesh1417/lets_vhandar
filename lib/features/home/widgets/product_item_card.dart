import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_fly_animator.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_variants_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

class ProductItemCard extends ConsumerStatefulWidget {
  final ProductData product;
  final VoidCallback? onTap;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final bool hideVariantPicker;

  const ProductItemCard({
    super.key,
    required this.product,
    this.onTap,
    this.width,
    this.margin,
    this.hideVariantPicker = false,
  });

  static double get preferredHeight => 226.h;

  @override
  ConsumerState<ProductItemCard> createState() => _ProductItemCardState();

  static void showVariantBottomSheet(
      BuildContext context, WidgetRef ref, ProductData product,
      {required Function(ProductData) onVariantSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final vc = context.vColors;
            final isBusiness = ref.watch(isBusinessUserProvider);
            ref.watch(cartProvider);
            return Container(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 16.h + MediaQuery.of(context).padding.bottom,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: vc.scaffoldBg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // drag handle
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: vc.divider,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name ?? 'Select Variant',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: vc.onSurface,
                              ),
                            ),
                            Text(
                              'Choose your preferred size/pack',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: vc.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ref.watch(productVariantsProvider(product)).when(
                        data: (variants) {
                          if (variants.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: Center(
                                child: Text(
                                  'No variants available',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: vc.onSurfaceMuted,
                                  ),
                                ),
                              ),
                            );
                          }
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.52,
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: variants.length,
                              separatorBuilder: (_, __) => SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final v = variants[index];
                                final isOutOfStock = v.isOutOfStock;
                                final displayPrice = isBusiness
                                    ? (v.businessPricePerUnit ?? v.actualPrice)
                                    : v.actualPrice;
                                final hasDiscount = v.discount != null &&
                                    (v.discount?.value ?? 0) > 0;
                                final savings = hasDiscount
                                    ? v.pricePerUnit!.toInt() - v.actualPrice.toInt()
                                    : 0;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.pushNamed(
                                      LVRoute.productDetailScreen.route,
                                      extra: v,
                                    );
                                  },
                                  child: Opacity(
                                    opacity: isOutOfStock ? 0.5 : 1.0,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: context.isDark
                                                ? vc.surfaceVariant
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(16.r),
                                            border: Border.all(
                                              color: context.isDark
                                                  ? vc.divider
                                                  : Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              if (v.images?.isNotEmpty == true) ...[
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(12.r),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: vc.divider),
                                                      borderRadius: BorderRadius.circular(12.r),
                                                    ),
                                                    child: CustomImageViewer(
                                                      path: v.images!.first.url,
                                                      width: 58.w,
                                                      height: 58.h,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16.w),
                                              ],
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${v.unitValue?.toInt()} ${v.unit}',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: vc.onSurface,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    if (isOutOfStock)
                                                      Text('Out of Stock',
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.red.shade500,
                                                          ))
                                                    else
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                                        textBaseline: TextBaseline.alphabetic,
                                                        children: [
                                                          Text(
                                                            'Rs ${displayPrice.toInt()}',
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight: FontWeight.w900,
                                                              color: vc.onSurface,
                                                            ),
                                                          ),
                                                          if (hasDiscount) ...[
                                                            SizedBox(width: 8.w),
                                                            Text(
                                                              'MRP ${v.pricePerUnit?.toInt()}',
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: vc.onSurfaceMuted,
                                                                decoration: TextDecoration.lineThrough,
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              if (!isOutOfStock)
                                                _VariantCartButton(product: v),
                                            ],
                                          ),
                                        ),
                                        if (hasDiscount && !isOutOfStock)
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16.r),
                                                  bottomRight: Radius.circular(12.r),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('SAVE', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.w900)),
                                                  SizedBox(width: 4.w),
                                                  Text('Rs $savings', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900)),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                          loading: () => const _VariantListShimmer(),
                          error: (e, s) => Center(
                            child: Text('Failed to load variants',
                                style: TextStyle(fontSize: 14.sp, color: Colors.red)),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductItemCardState extends ConsumerState<ProductItemCard> {
  late ProductData _currentProduct;
  final GlobalKey _imageKey = GlobalKey();
  final PageController _imagePageController = PageController();
  int _imagePage = 0;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Offset _imageCenter() {
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    return box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
  }

  Widget _buildImageArea(ProductData product) {
    final images = product.images ?? [];
    if (images.length <= 1) {
      return CustomImageViewer(
        path: images.isNotEmpty ? images.first.url : null,
        borderRadius: 0.r,
        fit: BoxFit.contain,
      );
    }
    return PageView.builder(
      controller: _imagePageController,
      itemCount: images.length,
      onPageChanged: (i) => setState(() => _imagePage = i),
      itemBuilder: (_, i) => CustomImageViewer(
        path: images[i].url,
        borderRadius: 0.r,
        fit: BoxFit.contain,
      ),
    );
  }

  void _showVariantBottomSheet() {
    ProductItemCard.showVariantBottomSheet(context, ref, widget.product,
        onVariantSelected: (v) {
      setState(() {
        _currentProduct = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = _currentProduct;
    final isBusiness = ref.watch(isBusinessUserProvider);
    final isOutOfStock = product.isOutOfStock;

    // ── Price selection based on user type ──────────────────────────
    final hasB2BPrice = isBusiness &&
        (product.businessPricePerUnit ?? 0) > 0;

    // Selling price shown to the user
    final displayPrice = hasB2BPrice
        ? product.businessActualPrice   // B2B: MRP - B2B discount
        : product.actualPrice;          // Retail: pricePerUnit - discount

    // MRP to show strikethrough (B2B uses businessPricePerUnit as their MRP)
    final mrp = hasB2BPrice
        ? (product.businessPricePerUnit ?? 0)
        : (product.pricePerUnit ?? 0);

    final showMrp = !isOutOfStock &&
        mrp > 0 &&
        displayPrice < mrp;

    final vc = context.vColors;

    return GestureDetector(
      onTap: widget.onTap != null
          ? () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      child: Container(
        width: widget.width ?? 140.w,
        height: ProductItemCard.preferredHeight,
        margin: widget.margin ?? EdgeInsets.only(right: 6.w, bottom: 6.h),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  key: _imageKey,
                  height: 105.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6.r),
                      topRight: Radius.circular(6.r),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6.r),
                      topRight: Radius.circular(6.r),
                    ),
                    child: Opacity(
                      opacity: isOutOfStock ? 0.45 : 1.0,
                      child: _buildImageArea(product),
                    ),
                  ),
                ),
                // Dots for multiple images
                if ((product.images?.length ?? 0) > 1)
                  Positioned(
                    bottom: isOutOfStock ? 22.h : 5.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(product.images!.length, (i) {
                        final isActive = _imagePage == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 6.w,
                          height: 6.w,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? const Color(0xFF0A754E)
                                : Colors.black.withValues(alpha: 0.25),
                            border: Border.all(
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                // Out of stock banner
                if (isOutOfStock)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        'OUT OF STOCK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Discount badge — retail & business
                if (showMrp)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.r),
                            bottomRight: Radius.circular(8.r)),
                      ),
                      child: Column(
                        children: [
                          Text('SAVE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              'Rs ${(mrp - displayPrice).toInt()}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (product.isVegetarian != null && product.isVegetarian!)
                  Positioned(
                    bottom: 6.h,
                    right: 6.w,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: vc.surface,
                        border: Border.all(
                          color: product.isVegetarian!
                              ? const Color(0xFF008B58)
                              : const Color(0xFFE53935),
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          color: product.isVegetarian!
                              ? const Color(0xFF008B58)
                              : const Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name ?? 'Product Name',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: vc.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 6.h),
                      // Variant pill: only shown when NOT in slider mode
                      (widget.product.hasVariant == true ||
                                  widget.product.parentId != null) &&
                              !widget.hideVariantPicker
                          ? GestureDetector(
                              onTap: _showVariantBottomSheet,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  border: Border.all(color: vc.divider),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          product.unitValue != null
                                              ? '${product.unitValue!.toInt()} ${product.unit ?? ''}'
                                              : product.unit ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: vc.onSurface,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                    Icon(Icons.keyboard_arrow_down,
                                        size: 14.sp,
                                        color: vc.onSurfaceMuted),
                                  ],
                                ),
                              ),
                            )
                          : Text(
                              product.unitValue != null
                                  ? '${product.unitValue!.toInt()}${product.unit ?? ''}'
                                  : product.unit ?? '',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: vc.onSurfaceMuted,
                                fontWeight: FontWeight.w500,
                              )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rs. ${displayPrice.toInt()}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: vc.onSurface,
                              )),
                          if (showMrp)
                            Text('MRP ${mrp.toInt()}',
                                style: TextStyle(
                                    fontSize: 9.sp,
                                    color: vc.onSurfaceMuted,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: vc.onSurfaceMuted,
                                    decorationThickness: 2.0)),
                        ],
                      ),
                      if (isOutOfStock)
                        // Disabled out-of-stock button
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Out of\nStock',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Consumer(
                          builder: (context, ref, _) {
                            ref.watch(cartProvider);
                            final cartCount = ref
                                .read(cartProvider.notifier)
                                .getCartItemCount(product.id!);
                            if (cartCount == 0) {
                              return GestureDetector(
                                onTap: () {
                                  final loginState = ref.read(loginProvider);
                                  if (loginState.isGuest || !loginState.isLoggedIn) {
                                    context.go(LVRoute.loginScreen.route);
                                    return;
                                  }
                                  // Open variant popup for variant products
                                  if (widget.product.hasVariant == true ||
                                      widget.product.parentId != null) {
                                    HapticFeedback.lightImpact();
                                    _showVariantBottomSheet();
                                    return;
                                  }
                                  HapticFeedback.mediumImpact();
                                  CartFlyAnimator.fly(
                                    context,
                                    product.images?.isNotEmpty == true
                                        ? product.images!.first.url
                                        : null,
                                    _imageCenter(),
                                  );
                                  ref
                                      .read(cartProvider.notifier)
                                      .addToCart(product);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColor.primary),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'ADD',
                                    style: TextStyle(
                                      color: AppColor.primary,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                height: 30.h,
                                decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        CartFlyAnimator.blast(
                                          context,
                                          product.images?.isNotEmpty == true
                                              ? product.images!.first.url
                                              : null,
                                        );
                                        ref
                                            .read(cartProvider.notifier)
                                            .updateQuantity(
                                                product.id!, cartCount - 1);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6.w, vertical: 4.h),
                                        color: Colors.transparent,
                                        child: Icon(Icons.remove,
                                            color: Colors.white, size: 16.sp),
                                      ),
                                    ),
                                    Text(
                                      '$cartCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        ref
                                            .read(cartProvider.notifier)
                                            .updateQuantity(
                                                product.id!, cartCount + 1);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6.w, vertical: 4.h),
                                        color: Colors.transparent,
                                        child: Icon(Icons.add,
                                            color: Colors.white, size: 16.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            )),
            SizedBox(height: 4.h)
          ],
        ),
      ),
    );
  }
}

class _VariantCartButton extends ConsumerWidget {
  final ProductData product;
  const _VariantCartButton({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cartProvider);
    final cartCount = ref.read(cartProvider.notifier).getCartItemCount(product.id!);
    final btnHeight = 34.h;

    if (cartCount == 0) {
      return SizedBox(
        height: btnHeight,
        child: ElevatedButton(
          onPressed: () {
            final loginState = ref.read(loginProvider);
            if (loginState.isGuest || !loginState.isLoggedIn) {
              context.go(LVRoute.loginScreen.route);
              return;
            }
            HapticFeedback.mediumImpact();
            ref.read(cartProvider.notifier).addToCart(product);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.vColors.surface,
            elevation: 0,
            shadowColor: Colors.transparent,
            side: BorderSide(color: AppColor.primary),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Text('ADD', style: TextStyle(color: AppColor.primary, fontSize: 12.sp, fontWeight: FontWeight.w800)),
        ),
      );
    }

    return SizedBox(
      height: btnHeight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(cartProvider.notifier).updateQuantity(product.id!, cartCount - 1);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                color: Colors.transparent,
                child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
              ),
            ),
            Text('$cartCount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(cartProvider.notifier).updateQuantity(product.id!, cartCount + 1);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                color: Colors.transparent,
                child: Icon(Icons.add, color: Colors.white, size: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantListShimmer extends StatelessWidget {
  const _VariantListShimmer();

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.isDark ? vc.surfaceVariant : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: context.isDark ? vc.divider : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58.w,
                height: 58.h,
                decoration: BoxDecoration(
                  border: Border.all(color: vc.divider),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11.r),
                  child: const CustomShimmer.rectangular(),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmer.rectangular(height: 14.h, width: 80.w),
                    SizedBox(height: 8.h),
                    CustomShimmer.rectangular(height: 12.h, width: 120.w),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              CustomShimmer.rectangular(
                height: 32.h,
                width: 72.w,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
