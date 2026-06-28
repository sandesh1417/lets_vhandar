import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

import 'product_card_style.dart';
import 'product_store_row.dart';
import 'product_variant_selector.dart';

/// The "ticket" card: product name, unit, price (with discount / out-of-stock
/// state), the variant selector, and the brand/store row. Pure layout — all
/// pricing decisions are made by the caller and passed in as plain values.
class ProductInfoSection extends StatelessWidget {
  const ProductInfoSection({
    super.key,
    required this.product,
    required this.baseProduct,
    required this.price,
    required this.mrp,
    required this.hasDiscount,
    required this.isOOS,
    required this.onVariantChanged,
  });

  /// Currently selected product (variant) — drives the displayed copy.
  final ProductData product;

  /// The product the page was opened with — the variant selector's base.
  final ProductData baseProduct;

  final num price;
  final num mrp;
  final bool hasDiscount;
  final bool isOOS;
  final ValueChanged<ProductData> onVariantChanged;

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return SliverToBoxAdapter(
      child: Container(
        margin: productCardMargin(),
        decoration: productCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name & Price ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Product Name',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: vc.onSurface,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${product.unitValue?.toInt()} ${product.unit}',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: vc.onSurfaceMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${price.toInt()}',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.bold,
                          color: vc.onSurface,
                        ),
                      ),
                      if (hasDiscount) ...[
                        SizedBox(width: 8.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Text(
                            'MRP Rs.${mrp.toInt()}',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: vc.strikethrough,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Save Rs.${(mrp - price).toInt()}',
                            style: TextStyle(
                              color: AppColor.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  if (isOOS)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade600,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Inclusive of all taxes',
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: vc.onSurfaceMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // ── Variant Selector ───────────────────────────────────────────
            ProductVariantSelector(
              baseProduct: baseProduct,
              selected: product,
              onVariantChanged: onVariantChanged,
            ),

            // ── Brand + Ticket Cutout ──────────────────────────────────────
            if (product.brandId != null) ProductStoreRow(brandId: product.brandId!),

            // Just enough clearance so content never touches the rounded bottom
            // corners of the card.
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
