import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class ProductDetailsTable extends StatelessWidget {
  final ProductData product;

  const ProductDetailsTable({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final rows = <Map<String, String>>[
      {'label': 'Unit', 'value': '${product.unitValue?.toInt()} ${product.unit}'},
      if (product.status?.isNotEmpty == true)
        {'label': 'Type', 'value': product.status!},
      if (product.keyFeatures?.isNotEmpty == true)
        {'label': 'Key Features', 'value': product.keyFeatures!},
      if (product.shelfLife?.isNotEmpty == true)
        {'label': 'Shelf Life', 'value': product.shelfLife!},
      if (product.returnPolicy?.isNotEmpty == true)
        {'label': 'Return Policy', 'value': product.returnPolicy!},
      if (product.disclaimer?.isNotEmpty == true)
        {'label': 'Disclaimer', 'value': product.disclaimer!},
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

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
              'Product Details',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textBlack,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final i = entry.key;
              final row = entry.value;
              final isLast = i == rows.length - 1;
              return Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: i.isEven
                      ? Colors.white
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: i == 0 ? Radius.circular(14.r) : Radius.zero,
                    topRight: i == 0 ? Radius.circular(14.r) : Radius.zero,
                    bottomLeft:
                        isLast ? Radius.circular(14.r) : Radius.zero,
                    bottomRight:
                        isLast ? Radius.circular(14.r) : Radius.zero,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100.w,
                      child: Text(
                        row['label']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textBlack54,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        row['value']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textBlack87,
                          height: 1.4,
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
    );
  }
}
