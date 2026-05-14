import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
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
    return ref.watch(productVariantsProvider(baseProduct)).when(
          data: (variants) {
            if (variants.isEmpty) return const SizedBox.shrink();
            return Column(
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
                        color: AppColor.textBlack,
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
                      final hasDiscount =
                          v.discount != null && (v.discount?.value ?? 0) > 0;
                      return GestureDetector(
                        onTap: () => onVariantChanged(v),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 12.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColor.primary.withOpacity(0.06)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.primary
                                  : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColor.primary.withOpacity(0.12),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDiscount)
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
                                  color: isSelected
                                      ? AppColor.primary
                                      : AppColor.textBlack,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Text(
                                    'Rs.${v.actualPrice.toInt()}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textBlack,
                                    ),
                                  ),
                                  if (hasDiscount) ...[
                                    SizedBox(width: 4.w),
                                    Text(
                                      'MRP ${v.pricePerUnit?.toInt()}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColor.textMuted,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const SizedBox.shrink(),
        );
  }
}
