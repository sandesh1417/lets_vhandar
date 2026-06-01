import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_variants_provider.dart';

class ProductVariantSelector extends ConsumerWidget {
  final ProductData baseProduct;
  final ProductData selected;
  final ValueChanged<ProductData> onVariantChanged;

  const ProductVariantSelector({
    super.key,
    required this.baseProduct,
    required this.selected,
    required this.onVariantChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusiness = ref.watch(isBusinessUserProvider);
    ref.watch(cartProvider);
    return ref.watch(productVariantsProvider(baseProduct)).when(
          data: (variants) {
            if (variants.length <= 1) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Select Unit',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: context.vColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: variants.map((v) {
                        final isSelected = v.id == selected.id;
                        final isOutOfStock = v.isOutOfStock;

                        final hasB2B = isBusiness && (v.businessPricePerUnit ?? 0) > 0;
                        final sellingPrice = hasB2B ? v.businessActualPrice : v.actualPrice;
                        final mrp = hasB2B
                            ? (v.businessPricePerUnit ?? 0)
                            : (v.pricePerUnit ?? 0);
                        final hasMrp = mrp > 0 && sellingPrice < mrp;
                        final savings = hasMrp ? (mrp - sellingPrice).toInt() : 0;
                        final cartCount = v.id != null
                            ? ref.read(cartProvider.notifier).getCartItemCount(v.id!)
                            : 0;

                        return Padding(
                          padding: EdgeInsets.only(top: 12.h, right: 8.w),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                        GestureDetector(
                          onTap: isOutOfStock ? null : () => onVariantChanged(v),
                          child: Opacity(
                            opacity: isOutOfStock ? 0.45 : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 100.w,
                              height: 92.h,
                              margin: EdgeInsets.only(right: 2.w),
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: isOutOfStock
                                    ? context.vColors.surfaceVariant
                                    : isSelected
                                        ? AppColor.primary.withValues(alpha: 0.07)
                                        : context.vColors.surface,
                                border: Border.all(
                                  color: isOutOfStock
                                      ? context.vColors.divider
                                      : isSelected
                                          ? AppColor.primary
                                          : context.vColors.divider,
                                  width: isSelected && !isOutOfStock ? 1.8 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: isSelected && !isOutOfStock
                                    ? [
                                        BoxShadow(
                                          color: AppColor.primary.withValues(alpha: 0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Unit label at top
                                  Text(
                                    '${v.unitValue?.toInt() ?? ''} ${v.unit ?? ''}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected && !isOutOfStock
                                          ? AppColor.primary
                                          : context.vColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Price section at bottom
                                  if (isOutOfStock)
                                    Text(
                                      'Out of Stock',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red.shade400,
                                      ),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Rs.${sellingPrice.toInt()}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            color: context.vColors.onSurface,
                                            height: 1.1,
                                          ),
                                        ),
                                        if (hasMrp) ...[
                                          SizedBox(height: 2.h),
                                          Text(
                                            'MRP ${mrp.toInt()}',
                                            style: TextStyle(
                                              fontSize: 9.sp,
                                              color: context.vColors.onSurfaceMuted,
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: context.vColors.onSurfaceMuted,
                                            ),
                                          ),
                                          SizedBox(height: 3.h),
                                          // SAVE badge inside the box
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFE53935),
                                                  Color(0xFFFF7043),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              'SAVE Rs $savings',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Yellow cart count badge
                        if (cartCount > 0)
                          Positioned(
                            top: -10.h,
                            right: -4.w,
                            child: Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                color: AppColor.secondary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$cartCount',
                                style: TextStyle(
                                  color: const Color(0xFF3D2000),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        );
  }
}
