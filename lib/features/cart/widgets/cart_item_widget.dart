import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/domain/models/cart_item_model.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDiscount = item.product.discount != null &&
        (item.product.discount?.value ?? 0) > 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: item.product.images?.isNotEmpty == true
                  ? Image.network(
                      item.product.images!.first.url ?? '',
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.image, color: Colors.grey.shade300),
            ),
          ),
          SizedBox(width: 12.w),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${item.product.unitValue?.toInt() ?? 1} ${item.product.unit ?? ''}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textMuted,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Rs ${item.product.actualPrice.toInt()}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack,
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(width: 6.w),
                      Text(
                        'Rs ${item.product.pricePerUnit?.toInt()}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColor.textStrikeThrough,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Quantity Selector
          Container(
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(cartProvider.notifier)
                      .updateQuantity(item.product.id!, item.quantity - 1),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    color: Colors.transparent,
                    child: Icon(Icons.remove, color: Colors.white, size: 16.sp),
                  ),
                ),
                Text(
                  '${item.quantity}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(cartProvider.notifier)
                      .updateQuantity(item.product.id!, item.quantity + 1),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    color: Colors.transparent,
                    child: Icon(Icons.add, color: Colors.white, size: 16.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
