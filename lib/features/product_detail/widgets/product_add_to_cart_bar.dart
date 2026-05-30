import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class ProductAddToCartBar extends ConsumerWidget {
  final ProductData product;

  const ProductAddToCartBar({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems
        .where((i) => i.product.id == product.id)
        .fold(0, (sum, i) => sum + i.quantity);
    final isBusiness = ref.watch(isBusinessUserProvider);
    final isOutOfStock = product.isOutOfStock;
    final maxQty = () {
      final raw = product.maximumQuantityOrder;
      if (raw == null) return 99;
      final v = (raw as num?)?.toInt() ?? 99;
      return v > 0 ? v : 99;
    }();
    final hasB2BPrice = isBusiness && (product.businessPricePerUnit ?? 0) > 0;
    final displayPrice = hasB2BPrice ? product.businessActualPrice : product.actualPrice;
    final mrp = hasB2BPrice ? (product.businessPricePerUnit ?? 0) : (product.pricePerUnit ?? 0);
    final showMrp = !isOutOfStock && mrp > 0 && displayPrice < mrp;
    final savedAmount = showMrp ? (mrp - displayPrice).toInt() : 0;

    final vc = context.vColors;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
          decoration: BoxDecoration(
            color: vc.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border(
              top: BorderSide(color: vc.divider.withValues(alpha: 0.6), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Price info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rs. ${displayPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: vc.onSurface,
                        ),
                      ),
                      if (isOutOfStock) ...[
                        SizedBox(height: 2.h),
                        Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade500,
                          ),
                        ),
                      ] else if (showMrp) ...[
                        SizedBox(height: 2.h),
                        Text(
                          'MRP Rs.${mrp.toInt()}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: vc.onSurfaceMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'You save Rs.$savedAmount',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Add / Stepper / Out of stock
                SizedBox(
                  width: 140.w,
                  height: 44.h,
                  child: isOutOfStock
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : cartCount == 0
                          ? GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                ref.read(cartProvider.notifier).addToCart(product);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.primary,
                                      AppColor.primary.withValues(alpha: 0.85),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.primary.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: context.vColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColor.primary.withValues(alpha: 0.25),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _StepButton(
                                    icon: Icons.remove,
                                    onTap: () => ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(product.id!, cartCount - 1),
                                  ),
                                  Text(
                                    '$cartCount',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColor.primary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  _StepButton(
                                    icon: Icons.add,
                                    disabled: cartCount >= maxQty,
                                    onTap: () => ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(product.id!, cartCount + 1),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  const _StepButton({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap();
            },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Icon(
          icon,
          color: disabled ? Colors.grey.shade400 : AppColor.primary,
          size: 16.sp,
        ),
      ),
    );
  }
}
