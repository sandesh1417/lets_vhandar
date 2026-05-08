import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class ProductAddToCartBar extends ConsumerWidget {
  final ProductData product;

  const ProductAddToCartBar({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cartProvider);
    final cartCount =
        ref.read(cartProvider.notifier).getCartItemCount(product.id!);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rs. ${product.actualPrice.toInt()}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
                if (product.discount != null &&
                    (product.discount?.value ?? 0) > 0)
                  Text(
                    'MRP Rs.${product.pricePerUnit?.toInt()}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColor.textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),

          // Add / Stepper
          if (cartCount == 0)
            GestureDetector(
              onTap: () =>
                  ref.read(cartProvider.notifier).addToCart(product),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primary,
                      AppColor.primary.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepButton(
                    icon: Icons.remove,
                    onTap: () => ref
                        .read(cartProvider.notifier)
                        .updateQuantity(product.id!, cartCount - 1),
                  ),
                  SizedBox(
                    width: 36.w,
                    child: Text(
                      '$cartCount',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add,
                    onTap: () => ref
                        .read(cartProvider.notifier)
                        .updateQuantity(product.id!, cartCount + 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        color: Colors.transparent,
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}
