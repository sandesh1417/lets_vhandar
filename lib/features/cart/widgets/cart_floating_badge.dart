import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_fly_animator.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class CartFloatingBadge extends ConsumerWidget {
  final VoidCallback onTap;

  const CartFloatingBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final itemCount = ref.watch(totalCartItemsProvider);

    if (itemCount == 0) return const SizedBox.shrink();

    final last3 = cartItems.length <= 3
        ? cartItems
        : cartItems.sublist(cartItems.length - 3);
    final previewImages = last3
        .map((e) => e.product.images?.isNotEmpty == true
            ? e.product.images!.first.url
            : null)
        .whereType<String>()
        .toList();

    return GestureDetector(
      key: CartFlyAnimator.cartBadgeKey,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5C842).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF5C842).withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StackedImages(imageUrls: previewImages),
                  SizedBox(width: 10.w),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View cart',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2E00),
                        ),
                      ),
                      Text(
                        '$itemCount ${itemCount == 1 ? 'Item' : 'Items'}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B4400),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF4A2E00),
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StackedImages extends StatelessWidget {
  final List<String> imageUrls;

  const _StackedImages({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    const double size = 38;
    const double overlap = 12;
    final count = imageUrls.length;
    if (count == 0) return const SizedBox.shrink();
    final totalWidth = size + (count - 1) * (size - overlap);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: List.generate(count, (i) {
          return Positioned(
            left: i * (size - overlap).toDouble(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: CustomImageViewer(
                  path: imageUrls[i],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
