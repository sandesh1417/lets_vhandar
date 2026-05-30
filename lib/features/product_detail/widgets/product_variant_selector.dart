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
    return ref.watch(productVariantsProvider(baseProduct)).when(
          data: (variants) {
            if (variants.length <= 1) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Select Unit',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: context.vColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: variants.map((v) {
                        final isSelected = v.id == selected.id;
                        final isOutOfStock = v.isOutOfStock;

                        final hasB2B = isBusiness &&
                            (v.businessPricePerUnit ?? 0) > 0;
                        final sellingPrice =
                            hasB2B ? v.businessActualPrice : v.actualPrice;
                        final mrp = hasB2B
                            ? (v.businessPricePerUnit ?? 0)
                            : (v.pricePerUnit ?? 0);
                        final hasMrp = mrp > 0 && sellingPrice < mrp;
                        final discountPct = hasMrp
                            ? ((mrp - sellingPrice) / mrp * 100).round()
                            : 0;

                        return GestureDetector(
                          onTap: isOutOfStock ? null : () => onVariantChanged(v),
                          child: Opacity(
                            opacity: isOutOfStock ? 0.45 : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 100.w,
                              margin: EdgeInsets.only(right: 10.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 10.h),
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
                                          color: AppColor.primary
                                              .withValues(alpha: 0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${v.unitValue?.toInt() ?? ''} ${v.unit ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected && !isOutOfStock
                                          ? AppColor.primary
                                          : context.vColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  if (isOutOfStock)
                                    Text(
                                      'Out of\nStock',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red.shade400,
                                        height: 1.3,
                                      ),
                                    )
                                  else ...[
                                    Text(
                                      'Rs.${sellingPrice.toInt()}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: context.vColors.onSurface,
                                        height: 1.1,
                                      ),
                                    ),
                                    if (hasMrp) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        'MRP Rs.${mrp.toInt()}',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: context.vColors.onSurfaceMuted,
                                          decoration: TextDecoration.lineThrough,
                                          decorationColor:
                                              context.vColors.onSurfaceMuted,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '$discountPct% OFF on MRP',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () =>
              Center(child: CircularProgressIndicator(color: AppColor.primary)),
          error: (e, s) => const SizedBox.shrink(),
        );
  }
}
