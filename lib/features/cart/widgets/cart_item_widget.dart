import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/features/cart/domain/models/cart_item_model.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = context.vColors;
    final product = item.product;
    final isBusiness = ref.watch(isBusinessUserProvider);
    final displayPrice = isBusiness
        ? (product.businessPricePerUnit ?? product.actualPrice)
        : product.actualPrice;
    final hasDiscount = !isBusiness &&
        product.discount != null &&
        (product.discount?.value ?? 0) > 0;

    return GestureDetector(
      onTap: () => context.pushNamed(
        LVRoute.productDetailScreen.route,
        extra: product,
      ),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                    color: context.isDark ? vc.surfaceVariant : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: vc.divider),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CustomImageViewer(
                      path: product.images?.isNotEmpty == true
                          ? product.images!.first.url
                          : null,
                      fit: BoxFit.contain,
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: vc.onSurface,
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
                      color: vc.onSurfaceMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        'Rs. ${displayPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: vc.onSurface,
                        ),
                      ),
                      if (hasDiscount) ...[
                        SizedBox(width: 6.w),
                        Text(
                          'Rs. ${product.pricePerUnit?.toInt()}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: vc.strikethrough,
                            decorationColor: vc.strikethrough,
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
                gradient: const LinearGradient(
                  colors: AppColor.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepBtn(
                    icon: item.quantity == 1
                        ? Icons.delete_outline
                        : Icons.remove,
                    onTap: () => ref
                        .read(cartProvider.notifier)
                        .updateQuantity(product.id!, item.quantity - 1),
                  ),
                  SizedBox(
                    width: 28.w,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: Text(
                        '${item.quantity}',
                        key: ValueKey(item.quantity),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
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
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        color: Colors.transparent,
        child: Icon(icon, color: Colors.white, size: 15.sp),
      ),
    );
  }
}
