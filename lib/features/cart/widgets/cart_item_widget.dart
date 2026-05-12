import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vhandar/core/constants/color_constant.dart';
import 'package:vhandar/features/cart/domain/models/cart_item_model.dart';
import 'package:vhandar/features/cart/providers/cart_provider.dart';
import 'package:vhandar/widgets/custom_image_viewer.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;
    final hasDiscount =
        product.discount != null && (product.discount?.value ?? 0) > 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Product Image ──────────────────────────────
          Stack(
            children: [
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: CustomImageViewer(
                      path: product.images?.isNotEmpty == true
                          ? product.images!.first.url
                          : null,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              if (hasDiscount)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 14.w),

          // ── Details ───────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textBlack,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${product.unitValue?.toInt() ?? 1} ${product.unit ?? ''}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      'Rs. ${product.actualPrice.toInt()}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack,
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(width: 6.w),
                      Text(
                        'Rs. ${product.pricePerUnit?.toInt()}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade700,
                          decorationColor: Colors.grey.shade700,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // ── Quantity Stepper ──────────────────────────
          Container(
            height: 34.h,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepBtn(
                  icon:
                      item.quantity == 1 ? Icons.delete_outline : Icons.remove,
                  onTap: () => ref
                      .read(cartProvider.notifier)
                      .updateQuantity(product.id!, item.quantity - 1),
                ),
                SizedBox(
                  width: 28.w,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                _StepBtn(
                  icon: Icons.add,
                  onTap: () => ref
                      .read(cartProvider.notifier)
                      .updateQuantity(product.id!, item.quantity + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        color: Colors.transparent,
        child: Icon(icon, color: Colors.white, size: 15.sp),
      ),
    );
  }
}
