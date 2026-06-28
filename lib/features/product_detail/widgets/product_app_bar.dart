import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

/// Scroll-fade AppBar for the product page: transparent over the full-bleed hero
/// image at the top, fading into the primary colour with the product's
/// thumbnail/name/price as you scroll down. The fade is purely visual and driven
/// off [scrollOffset], so it lives with the AppBar UI.
class ProductDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProductDetailAppBar({
    super.key,
    required this.scrollOffset,
    required this.product,
    required this.price,
    required this.onShare,
  });

  /// Live scroll offset of the page, drives the fade.
  final ValueListenable<double> scrollOffset;

  /// Product shown in the collapsed title (thumbnail + name).
  final ProductData product;

  /// Business-aware price shown in the collapsed title.
  final num price;

  final VoidCallback onShare;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: scrollOffset,
      builder: (context, offset, _) {
        final ratio = ((offset - 50.h) / (150.h - 50.h)).clamp(0.0, 1.0);
        final curved = Curves.easeInOut.transform(ratio);
        return AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: AppColor.primary.withValues(alpha: curved),
          elevation: curved * 2,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          automaticallyImplyLeading: false,
          // Nudged toward the bottom of the toolbar (not dead-center) so it sits
          // lower, clear of the status bar — with the hero image full-bleed
          // behind it, a button glued to the very top edge made the Hero flight
          // read as a boxy resize instead of a photo sliding into place.
          leading: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: _GlassButton(
                icon: Icons.keyboard_arrow_down_rounded,
                isGlass: ratio < 0.5,
                size: 42,
                iconSize: 26,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
              ),
            ),
          ),
          titleSpacing: 0,
          title: Opacity(
            opacity: curved,
            child: Transform.translate(
              offset: Offset(0, (1 - curved) * 12.h),
              child: Row(
                children: [
                  if (product.images?.isNotEmpty == true)
                    Container(
                      width: 32.w,
                      height: 32.w,
                      margin: EdgeInsets.only(right: 8.w),
                      child: CustomImageViewer(
                        path: product.images!.first.url,
                        borderRadius: 6.r,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name ?? '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Rs. ${price.toInt()}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(right: 12.w, bottom: 6.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GlassButton(
                      svgAsset: 'assets/icons/search-active.svg',
                      isGlass: ratio < 0.5,
                      onTap: () => context.push(LVRoute.searchScreen.route),
                    ),
                    SizedBox(width: 8.w),
                    _GlassButton(
                      icon: Icons.ios_share_rounded,
                      isGlass: ratio < 0.5,
                      onTap: onShare,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Circular translucent ("glass") AppBar button that turns solid-white-on-image
/// while the bar is still transparent over the hero.
class _GlassButton extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final VoidCallback onTap;
  final bool isGlass;
  // Defaults are the original (smaller) action-button size; the leading button
  // opts into a larger size.
  final double size;
  final double iconSize;

  const _GlassButton({
    this.icon,
    this.svgAsset,
    required this.onTap,
    this.isGlass = true,
    this.size = 38,
    this.iconSize = 20,
  }) : assert(icon != null || svgAsset != null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isGlass ? (isDark ? Colors.white : AppColor.primary) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: isGlass
              ? (isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : const Color(0xFFF0FAF5).withValues(alpha: 0.9))
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: svgAsset != null
              ? SvgPicture.asset(
                  svgAsset!,
                  width: iconSize.sp,
                  height: iconSize.sp,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                )
              : Icon(icon, color: iconColor, size: iconSize.sp),
        ),
      ),
    );
  }
}
