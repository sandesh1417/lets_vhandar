import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

class OrderProductItem extends StatelessWidget {
  final OrderProduct product;

  const OrderProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: vc.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Container
          Container(
            width: 70.w,
            height: 70.h,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: vc.surfaceVariant,
              border: Border.all(color: vc.divider),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: product.firstImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: product.firstImageUrl!,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey),
                  )
                : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),
          SizedBox(width: 16.w),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: vc.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      '${product.unit}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: vc.onSurfaceMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: vc.surfaceVariant,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Qty: ${product.count}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: vc.onSurfaceMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs.${product.totalPrice}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: vc.onSurface,
                ),
              ),
              _buildDiscountLabel(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountLabel() {
    final d = product.discount;
    num amount = 0;

    if (d is num) {
      amount = d;
    } else if (d is Map) {
      // Safely extract from common keys like 'amount' or 'rate'
      amount = (d['amount'] as num?) ?? (d['discountAmount'] as num?) ?? 0;
    }

    if (amount <= 0) return const SizedBox.shrink();

    return Text(
      'Saved Rs.$amount',
      style: TextStyle(
        fontSize: 10.sp,
        color: const Color(0xFF0A754E),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
