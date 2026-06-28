import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

import 'product_image_slider.dart';

/// Sliver image header for the product page. A PLAIN scrolling sliver (not
/// pinned): the photo scrolls up and off with the rest of the page. The card →
/// fullscreen look is applied by the outer card chrome, so this just fills the
/// page width. RepaintBoundary keeps the carousel's repaints off the rest of the
/// list. The carousel internals (gallery swipe, two-stage collapse) live in
/// [ProductImageSlider].
class ProductImageHeader extends StatelessWidget {
  const ProductImageHeader({
    super.key,
    required this.product,
    required this.heroTag,
    required this.isActive,
    required this.fullscreen,
    required this.imageGestureActive,
    required this.onRequestCollapse,
  });

  final ProductData product;
  final String heroTag;

  /// Only the centred page owns the Hero and auto-plays, so a single image flies
  /// in/out and peeking neighbours stay still.
  final bool isActive;

  final ValueListenable<bool> fullscreen;
  final ValueNotifier<bool>? imageGestureActive;
  final VoidCallback onRequestCollapse;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: SizedBox(
          height: 320.h,
          child: ValueListenableBuilder<bool>(
            valueListenable: fullscreen,
            builder: (context, fs, _) => ProductImageSlider(
              product: product,
              heroTag: heroTag,
              enableHero: isActive,
              autoPlay: isActive,
              isFullscreen: fs,
              imageGestureActive: imageGestureActive,
              onRequestCollapse: onRequestCollapse,
            ),
          ),
        ),
      ),
    );
  }
}
