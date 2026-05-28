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
                        'Select Pack Size',
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
                        final displayPrice = isBusiness
                            ? (v.businessPricePerUnit ?? v.actualPrice)
                            : v.actualPrice;
                        final hasDiscount = !isBusiness &&
                            v.discount != null &&
                            (v.discount?.value ?? 0) > 0;
                        return GestureDetector(
                          onTap: isOutOfStock ? null : () => onVariantChanged(v),
                          child: Opacity(
                            opacity: isOutOfStock ? 0.45 : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: 12.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isOutOfStock
                                    ? context.vColors.surfaceVariant
                                    : isSelected
                                        ? AppColor.primary.withValues(alpha: 0.06)
                                        : context.vColors.surface,
                                border: Border.all(
                                  color: isOutOfStock
                                      ? context.vColors.divider
                                      : isSelected
                                          ? AppColor.primary
                                          : context.vColors.divider,
                                  width: isSelected && !isOutOfStock ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: isSelected && !isOutOfStock
                                    ? [
                                        BoxShadow(
                                          color: AppColor.primary.withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (hasDiscount && !isOutOfStock)
                                    Container(
                                      margin: EdgeInsets.only(bottom: 4.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE53935),
                                            Color(0xFFFF7043)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        'Save Rs.${v.discount?.value?.toInt()}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    '${v.unitValue?.toInt()} ${v.unit}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected && !isOutOfStock
                                          ? AppColor.primary
                                          : context.vColors.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  if (isOutOfStock)
                                    Text(
                                      'Out of Stock',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade400,
                                      ),
                                    )
                                  else
                                    Row(
                                      children: [
                                        Text(
                                          'Rs.${displayPrice.toInt()}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: context.vColors.onSurface,
                                          ),
                                        ),
                                        if (hasDiscount) ...[
                                          SizedBox(width: 4.w),
                                          Text(
                                            'MRP ${v.pricePerUnit?.toInt()}',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: context.vColors.onSurfaceMuted,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
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
          loading: () => Center(child: CircularProgressIndicator(color: AppColor.primary)),
          error: (e, s) => const SizedBox.shrink(),
        );
  }
}
