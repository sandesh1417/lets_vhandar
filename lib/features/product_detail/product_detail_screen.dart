import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

import 'animation/card_maximize_controller.dart';
import 'animation/swipe_dismiss_wrapper.dart';
import 'product_detail_page.dart';

// Product pager viewport: just under 1.0 so a thin sliver of the neighbouring
// product cards peeks in at the sides — a hint that the list is swipeable. The
// active card is widened back out by CardMaximizeChrome so this peek does NOT
// shrink the selected card.
const double _kPeekFraction = 0.93;

/// Horizontal slider across a list of products, e.g. opened from a grid or
/// "Similar Products" row — swipe left/right to browse sequentially through the
/// same list without going back. Each page is a full, independent
/// [ProductDetailPage] (own scroll position, AppBar fade, add-to-cart bar).
/// [PageView.builder] only builds the current page + its neighbours, so this
/// stays cheap even for long lists on low-end devices.
///
/// This is a thin orchestrator: it owns the pager + scrim and wires two shared
/// animation units to the pages — [SwipeDismissWrapper] (drag-to-dismiss) and
/// [CardMaximizeController] / [CardMaximizeChrome] (card↔fullscreen morph). It
/// holds no gesture math itself.
class ProductDetailScreen extends StatefulWidget {
  final List<ProductData> products;
  final int initialIndex;

  const ProductDetailScreen({
    super.key,
    required this.products,
    this.initialIndex = 0,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  // True for the whole duration a finger is touching a product's image (set by
  // ProductImageSlider, deep below). While true the outer pager goes inert, so
  // it can never win the gesture arena against the image's own horizontal
  // handling (gallery swipe / fullscreen-collapse swipe).
  final ValueNotifier<bool> _imageGestureActive = ValueNotifier(false);

  // Shared card↔fullscreen morph: the active page feeds its scroll offset in,
  // the scrim + per-item chrome read the progress out.
  final CardMaximizeController _maximize = CardMaximizeController();

  // Live scroll offset of the active page, mirrored up by that page so the
  // SwipeDismissWrapper knows when it's at the top — only then does a downward
  // pull dismiss instead of scrolling the content.
  final ValueNotifier<double> _activeScroll = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.products.length - 1);
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: _kPeekFraction,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _imageGestureActive.dispose();
    _maximize.dispose();
    _activeScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    return Stack(
      children: [
        // ── Scrim ──────────────────────────────────────────────────────────
        // The route is opaque: false, so whatever screen this was opened from is
        // still painted underneath. This translucent scrim dims it behind the
        // floating card and fades out as the card maximizes to fullscreen (by
        // then the page covers it anyway). Its own builder so only this thin
        // layer repaints per scroll frame.
        Positioned.fill(
          child: ValueListenableBuilder<double>(
            valueListenable: _maximize.progress,
            builder: (_, m, __) => ColoredBox(
              color: Colors.black.withValues(alpha: lerpDouble(0.55, 0.0, m)!),
            ),
          ),
        ),

        // ── Product pager + drag-to-dismiss ────────────────────────────────
        // The dismiss wrapper sits above the per-page rebuilds and the pages'
        // AppBars, so a downward swipe from anywhere on the card is always seen;
        // on release it pops and the page's Hero flies the image back. The pager
        // goes inert during an image touch (so the gallery/collapse swipe wins)
        // and while fullscreen (so a horizontal swipe minimizes instead of
        // paging) — both flip rarely, not per scroll frame.
        SwipeDismissWrapper(
          isAtTop: () => _activeScroll.value <= 0.0,
          onDismiss: () {
            AppHaptics.light();
            context.pop(); // Hero flies the image back to its product card.
          },
          child: ListenableBuilder(
            listenable:
                Listenable.merge([_imageGestureActive, _maximize.fullscreen]),
            builder: (context, _) => PageView.builder(
              controller: _pageController,
              itemCount: widget.products.length,
              physics: (_imageGestureActive.value || _maximize.fullscreen.value)
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) => CardMaximizeChrome(
                progress: _maximize.progress,
                isCurrent: index == _currentIndex,
                // The page is built ONCE here; only the chrome re-runs per frame.
                // Strip the bottom safe-area inset so the add-to-cart bar's own
                // SafeArea adds no padding — the bottom gap is owned by the card
                // margin in the chrome instead.
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: RepaintBoundary(
                    child: ProductDetailPage(
                      product: widget.products[index],
                      isActive: index == _currentIndex,
                      imageGestureActive: _imageGestureActive,
                      maximize: _maximize,
                      activeScroll: _activeScroll,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
//
