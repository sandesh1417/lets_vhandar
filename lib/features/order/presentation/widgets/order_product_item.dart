import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

class OrderProductItem extends StatelessWidget {
  final OrderProduct product;

  const OrderProductItem({super.key, required this.product});

  num get _discountAmount {
    final d = product.discount;
    if (d is num) return d;
    if (d is Map) {
      return (d['amount'] as num?) ?? (d['discountAmount'] as num?) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final hasDiscount = _discountAmount > 0;
    final qty = product.count ?? 1;
    final total = (product.totalPrice ?? product.netPrice ?? 0).toInt();
    final perUnit = product.pricePerUnit?.toInt();
    final unitLabel =
        '${product.unitValue?.toInt() ?? ''} ${product.unit ?? ''}'.trim();

    return Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ─────────────────────────────────────────────────
          Container(
            width: 76.w,
            height: 76.w,
            decoration: BoxDecoration(
              color: vc.surfaceVariant,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: vc.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: product.firstImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.firstImageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.shopping_bag_outlined,
                        color: vc.onSurfaceMuted,
                        size: 26.sp,
                      ),
                    )
                  : Icon(Icons.shopping_bag_outlined,
                      color: vc.onSurfaceMuted, size: 26.sp),
            ),
          ),

          SizedBox(width: 12.w),

          // ── Details ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  product.name ?? '',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),

                // Unit + qty chips
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    if (unitLabel.isNotEmpty)
                      _Chip(
                        label: unitLabel,
                        bgColor: vc.surfaceVariant,
                        textColor: vc.onSurfaceMuted,
                      ),
                    _Chip(
                      label: 'Qty: $qty',
                      bgColor: AppColor.primary.withValues(alpha: 0.08),
                      textColor: AppColor.primary,
                      bold: true,
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Price row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs. $total',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: vc.onSurface,
                          ),
                        ),
                        if (perUnit != null && qty > 1)
                          Text(
                            'Rs.$perUnit × $qty',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: vc.onSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                    if (hasDiscount)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2E7D32).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_offer_rounded,
                                size: 10.sp, color: const Color(0xFF2E7D32)),
                            SizedBox(width: 3.w),
                            Text(
                              'Saved Rs.${_discountAmount.toInt()}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final bool bold;

  const _Chip({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: textColor,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
