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
    final total = product.totalPrice?.toInt() ?? 0;
    final perUnit = product.pricePerUnit?.toInt();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ───────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 72.w,
              height: 72.w,
              color: vc.surfaceVariant,
              child: product.firstImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.firstImageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                          Icons.broken_image_outlined,
                          color: vc.onSurfaceMuted),
                    )
                  : Icon(Icons.shopping_bag_outlined,
                      color: vc.onSurfaceMuted, size: 28.sp),
            ),
          ),

          SizedBox(width: 12.w),

          // ── Details ─────────────────────────────────────────────────
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
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.h),

                // Unit + qty pill
                Row(
                  children: [
                    if (product.unit?.isNotEmpty == true ||
                        product.unitValue != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: vc.surfaceVariant,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          '${product.unitValue?.toInt() ?? ''} ${product.unit ?? ''}'.trim(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: vc.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        'Qty: $qty',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Rs. $total',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: vc.onSurface,
                      ),
                    ),
                    if (perUnit != null && qty > 1) ...[
                      SizedBox(width: 6.w),
                      Text(
                        '(Rs.$perUnit × $qty)',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: vc.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ],
                ),

                // Saved badge
                if (hasDiscount) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.local_offer_outlined,
                          size: 11.sp, color: const Color(0xFF2E7D32)),
                      SizedBox(width: 3.w),
                      Text(
                        'Saved Rs.${_discountAmount.toInt()}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
