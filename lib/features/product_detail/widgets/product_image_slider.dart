import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class ProductImageSlider extends StatefulWidget {
  final ProductData product;
  final String? heroTag;

  const ProductImageSlider({super.key, required this.product, this.heroTag});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreen() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(
          images: widget.product.images ?? [],
          initialIndex: _currentPage,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images ?? [];

    return Stack(
      children: [
        // White background + tappable image slider
        GestureDetector(
          onTap: _openFullScreen,
          child: Hero(
            tag: widget.heroTag ?? 'product-img-${widget.product.id}',
            child: Container(
              color: context.vColors.surface,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.isEmpty ? 1 : images.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, 16.h),
                    child: CustomImageViewer(
                      path: images.isNotEmpty ? images[index].url : null,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Dots
        if (images.length > 1)
          Positioned(
            bottom: 12.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _currentPage == i ? 18.w : 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    color: _currentPage == i
                        ? AppColor.primary
                        : context.vColors.divider,
                  ),
                );
              }),
            ),
          ),

        // Veg Tag
        if (widget.product.isVegetarian == true)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: const _VegNonVegTag(isVegetarian: true),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen image viewer
// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenImageViewer extends StatefulWidget {
  final List<ProductImage> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late int _current;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Swipeable image pages ──────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Center(
                  child: CustomImageViewer(
                    path: images.isNotEmpty ? images[index].url : null,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // ── Close button ───────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            right: 16.w,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
          ),

          // ── Image counter (e.g. 2 / 4) ────────────────────────────
          if (images.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 14.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${_current + 1} / ${images.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),

          // ── Thumbnail strip ────────────────────────────────────────
          if (images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16.h,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 58.w,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  shrinkWrap: true,
                  itemCount: images.length,
                  itemBuilder: (context, i) {
                    final isActive = _current == i;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52.w,
                        height: 52.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.25),
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7.r),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomImageViewer(
                                path: images[i].url,
                                fit: BoxFit.cover,
                              ),
                              if (!isActive)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VegNonVegTag extends StatelessWidget {
  final bool isVegetarian;
  const _VegNonVegTag({required this.isVegetarian});

  @override
  Widget build(BuildContext context) {
    final color =
        isVegetarian ? const Color(0xFF008B58) : const Color(0xFFE53935);
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: context.vColors.surface,
        border: Border.all(color: color, width: 1.5.w),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
