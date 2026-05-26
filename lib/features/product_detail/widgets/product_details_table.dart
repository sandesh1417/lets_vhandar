import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class ProductDetailsTable extends StatelessWidget {
  final ProductData product;
  final bool hideHeader;

  const ProductDetailsTable({
    super.key,
    required this.product,
    this.hideHeader = false,
  });

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
    final vc = context.vColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideHeader)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(
              'Product Details',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: vc.onSurface,
              ),
            ),
          ),
        ...rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          return Column(
            children: [
              if (i != 0)
                Divider(height: 1, thickness: 1, color: vc.divider),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 11.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110.w,
                      child: Text(
                        row['label']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: vc.onSurfaceMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row['value']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: vc.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
