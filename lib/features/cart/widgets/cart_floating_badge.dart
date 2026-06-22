import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/utils/scroll_activity.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_fly_animator.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class CartFloatingBadge extends ConsumerStatefulWidget {
  final VoidCallback onTap;

  const CartFloatingBadge({super.key, required this.onTap});

  @override
  ConsumerState<CartFloatingBadge> createState() => _CartFloatingBadgeState();
}

class _CartFloatingBadgeState extends ConsumerState<CartFloatingBadge>
    with SingleTickerProviderStateMixin {
  final _badgeKey = GlobalKey();

  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    CartFlyAnimator.registerBadgeKey(_badgeKey);

    // "Catch" bounce: a subtle, minimal nudge to ~1.07× then a smooth settle.
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.07)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_bounceCtrl);

    // Bounce exactly when a flying image lands in the cart.
    CartFlyAnimator.landedTick.addListener(_playBounce);
  }

  void _playBounce() {
    if (!mounted) return;
    _bounceCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    CartFlyAnimator.landedTick.removeListener(_playBounce);
    _bounceCtrl.dispose();
    CartFlyAnimator.unregisterBadgeKey(_badgeKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return ValueListenableBuilder<bool>(
      valueListenable: AppScrollActivity.isScrolling,
      builder: (context, scrolling, child) {
        // While scrolling: shrink AND drop the now-unwanted bottom gap so the
        // pill tucks down out of the way. Anchor the shrink to the bottom so it
        // collapses downward rather than floating in place.
        return AnimatedPadding(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: scrolling ? 0 : 6.h),
          child: AnimatedScale(
            scale: scrolling ? 0.72 : 1.0,
            duration: const Duration(milliseconds: 240),
            curve: scrolling ? Curves.easeOut : Curves.easeOutBack,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
      child: ScaleTransition(
        scale: _bounce,
        child: GestureDetector(
          key: _badgeKey,
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              // Solid translucent fill (no real-time BackdropFilter) — a
              // backdrop blur here re-rasterises the scrolling content every
              // frame and stutters on old devices. The 96% fill reads the
              // same at a glance.
              color: AppColor.secondary.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(50.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.secondary.withValues(alpha: 0.22),
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
