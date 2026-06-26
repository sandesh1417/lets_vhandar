import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class ProductImageSlider extends StatefulWidget {
  final ProductData product;
  final String? heroTag;

  // Only the centred page of an outer product-to-product pager should own a
  // Hero. The pager pre-builds the peeking neighbour pages too, and each
  // neighbour's image carries its own product-id Hero tag — the very same tags
  // still live on the screen we came from (the other cards in the list). With
  // every neighbour wrapped in a Hero, a single tap flew the tapped image AND
  // each visible neighbour at once. Gating the Hero on "is this the focused
  // page" means exactly one image flies in and back out.
  final bool enableHero;

  // Auto-advances through the product's photos on a timer when there's more
  // than one. Pass false for slider instances that shouldn't be quietly
  // animating in the background (e.g. a peeking, not-yet-focused page in an
  // outer product-to-product slider).
  final bool autoPlay;

  // True once the parent has scrolled the header into "fullscreen" (no
  // margins/radius). Gates the two-stage swipe below: see _galleryDragArmed.
  final bool isFullscreen;

  // Collapses the header back to card view (parent scrolls to top). Called
  // on the first horizontal swipe while fullscreen, instead of letting that
  // swipe move the gallery.
  final VoidCallback? onRequestCollapse;

  // Set true for the whole duration a finger touches this image, false on
  // lift/cancel. An outer product-to-product pager (if any) watches this to
  // go inert while the image owns the gesture — otherwise that pager, this
  // widget's own gallery PageView, and the fullscreen-collapse interceptor
  // below are three nested horizontal draggables racing for the same drag,
  // which resolves unpredictably instead of doing what's intended.
  final ValueNotifier<bool>? imageGestureActive;

  const ProductImageSlider({
    super.key,
    required this.product,
    this.heroTag,
    this.enableHero = true,
    this.autoPlay = true,
    this.isFullscreen = false,
    this.onRequestCollapse,
    this.imageGestureActive,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;

  // Two-stage fullscreen swipe: the first horizontal drag while fullscreen
  // collapses back to card view instead of moving the gallery; only once
  // that's happened (armed) does a swipe reach the PageView normally. Resets
  // every time fullscreen is (re-)entered, via didUpdateWidget below.
  bool _galleryDragArmed = false;

  static const _autoPlayInterval = Duration(seconds: 4);
  static const _autoPlayResumeDelay = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _scheduleAutoPlay();
  }

  @override
  void didUpdateWidget(ProductImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoPlay != oldWidget.autoPlay) {
      widget.autoPlay ? _scheduleAutoPlay() : _cancelAutoPlay();
    }
    if (widget.isFullscreen && !oldWidget.isFullscreen) {
      _galleryDragArmed = false;
    }
  }

  void _cancelAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _scheduleAutoPlay() {
    _cancelAutoPlay();
    final images = widget.product.images ?? [];
    if (!widget.autoPlay || images.length <= 1) return;
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final count = widget.product.images?.length ?? 0;
      if (count <= 1) return;
      _pageController.animateToPage(
        (_currentPage + 1) % count,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    });
  }

  // A manual swipe shouldn't fight the auto-play — pause it, then resume
  // (as a fresh periodic cycle, not mid-interval) after a breather.
  void _pauseAutoPlayThenResume() {
    if (!widget.autoPlay) return;
    _cancelAutoPlay();
    _autoPlayTimer = Timer(_autoPlayResumeDelay, _scheduleAutoPlay);
  }

  @override
  void dispose() {
    _cancelAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  // Two-stage fullscreen swipe: while fullscreen and not yet armed, a
  // horizontal drag is swallowed by AbsorbPointer before it ever reaches the
  // gallery PageView below, and this outer GestureDetector collapses back to
  // card view instead. Once armed (i.e. after that first collapse swipe), this
  // wrapper is skipped entirely and the drag reaches the PageView normally —
  // the "second swipe" then behaves like an ordinary gallery/product swipe.
  //
  // This must fire regardless of image count: even a single-image product's
  // gallery PageView owns its own horizontal drag recognizer, and being deeper
  // in the tree it would win the gesture arena (and just bounce) instead of
  // letting the page-level swipe-to-minimize through. So the first fullscreen
  // swipe over the image always collapses to card view, one image or many.
  Widget _interceptFullscreenSwipe({
    required List<ProductImage> images,
    required Widget child,
  }) {
    final shouldIntercept = widget.isFullscreen && !_galleryDragArmed;
    if (!shouldIntercept) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) {
        widget.onRequestCollapse?.call();
        setState(() => _galleryDragArmed = true);
      },
      child: AbsorbPointer(child: child),
    );
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

  // Wraps the landed image content in a Hero — but ONLY for the focused page
  // (widget.enableHero). A peeking neighbour page returns its content as-is so
  // its product-id Hero tag can't get matched and flown alongside the tapped
  // one. The flight itself renders a single plain image (not this PageView), so
  // exactly one photo glides in, smoothly, with no neighbours tagging along.
  Widget _wrapHero({
    required BuildContext context,
    required List<ProductImage> images,
    required Widget child,
  }) {
    if (!widget.enableHero) return child;
    return Hero(
      tag: widget.heroTag ?? 'product-img-${widget.product.id}',
      transitionOnUserGestures: true,
      // Flies a plain image instead of this slider's real content
      // (PageView + padding). Reusing CustomImageViewer (not a fresh
      // CachedNetworkImage) is the important bit — it's the exact same widget +
      // cache manager + cache key the card and this slider already used to
      // display this URL, so Flutter's image cache resolves it synchronously
      // from what's already decoded in memory. A different cache key here would
      // force a fresh decode right as the flight starts, which is exactly the
      // stutter we're trying to avoid.
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final url = images.isNotEmpty ? images.first.url : null;
        return RepaintBoundary(
          // Same surface-colored backdrop as the landed state — without it,
          // BoxFit.contain's letterbox gaps show whatever is behind the flight
          // (the fading page underneath) and then snap to a solid color the
          // instant it lands.
          child: Container(
            color: context.vColors.surface,
            child: CustomImageViewer(path: url, fit: BoxFit.contain),
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images ?? [];

    // Raw pointer events, not a GestureDetector — this needs to fire
    // unconditionally for the full duration of contact, independent of
    // whatever gesture (tap/drag/etc.) the arena ends up resolving to.
    return Listener(
      onPointerDown: (_) => widget.imageGestureActive?.value = true,
      onPointerUp: (_) => widget.imageGestureActive?.value = false,
      onPointerCancel: (_) => widget.imageGestureActive?.value = false,
      child: Stack(
        children: [
          // White background + tappable image slider
          GestureDetector(
            onTap: _openFullScreen,
            child: _wrapHero(
              context: context,
              images: images,
              // No padding here — the card's image also fills its box
              // edge-to-edge with the same BoxFit.contain. Hero only
              // animates the outer rect smoothly; the instant the flight
              // ends, whatever's actually laid out inside snaps into view.
              // If that inner layout doesn't match the flight shuttle
              // (which is a bare full-bleed image), you get a visible
              // "jump" right as it lands — padding here was exactly that
              // mismatch.
              child: RepaintBoundary(
                child: Container(
                  color: context.vColors.surface,
                  child: _interceptFullscreenSwipe(
                    images: images,
                    child: NotificationListener<ScrollNotification>(
                      // Only a real finger-drag should pause auto-play —
                      // dragDetails is null for the programmatic
                      // animateToPage calls auto-play itself makes, so it
                      // can't self-pause.
                      onNotification: (n) {
                        if (n is ScrollStartNotification &&
                            n.dragDetails != null) {
                          _pauseAutoPlayThenResume();
                        }
                        return false;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.isEmpty ? 1 : images.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (context, index) {
                          return CustomImageViewer(
                            path: images.isNotEmpty ? images[index].url : null,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    ),
                  ),
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
      ),
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

    return CustomScaffoldWrapper(
      isScrollable: false,
      bottomSafeArea: false,
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
