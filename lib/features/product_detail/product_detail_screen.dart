import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/product_detail/widgets/product_brand_section.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:share_plus/share_plus.dart';

import 'widgets/product_add_to_cart_bar.dart';
import 'widgets/product_details_table.dart';
import 'widgets/product_image_slider.dart';
import 'widgets/product_variant_selector.dart';

// ── consistent card style ────────────────────────────────────────────────────
// All three cards (ticket / product details / similar products) use the same
// horizontal margin, vertical gap, border-radius and shadow so the page feels
// like one coherent design.
const double _kCardHMargin = 12; // horizontal margin  (use .w in build)
const double _kCardVGap = 6; // gap between cards  (use .h in build)
const double _kCardRadius = 12; // BorderRadius value  (use .r in build)

// Product pager viewport: just under 1.0 so a thin sliver of the neighbouring
// product cards peeks in at the sides — a hint that the list is swipeable. The
// active card is widened back out with an OverflowBox in the item builder so
// this peek does NOT shrink the selected card. The side budget (screen minus
// card width) is split into a small gap between cards plus the peek; this
// fraction is tuned so the slot sits a few px wider than the card → that gap.
const double _kPeekFraction = 0.93;

/// Horizontal slider across a list of products, e.g. opened from a grid or
/// "Similar Products" row — swipe left/right to browse sequentially through
/// the same list without going back. Each page is a full, independent
/// [_ProductDetailPage] (own scroll position, own AppBar fade, own
/// add-to-cart bar), so nothing needs to be shared/synced across pages.
/// [PageView.builder] only ever builds the current page + its immediate
/// neighbours, so this stays cheap even for long lists on low-end devices.
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

  // True for the whole duration a finger is touching a product's image
  // (set by ProductImageSlider, deep below). While true, this outer
  // product-to-product pager goes inert, so it can never win the gesture
  // arena against the image's own horizontal handling (gallery swipe / the
  // two-stage fullscreen-collapse swipe) — without this, three nested
  // horizontal draggables (this pager, the gallery PageView, and the
  // collapse interceptor) would race unpredictably for the same drag.
  final ValueNotifier<bool> _imageGestureActive = ValueNotifier(false);

  // 0 = the active product is a rounded card floating over the home screen
  // (margins + scrim); 1 = it has maximized to fill the entire screen edge
  // to edge (image fully fullscreen). Driven by the *active* page's scroll
  // offset (see _ProductDetailPage), so scrolling down maximizes and
  // scrolling back to the top minimizes — never per-frame setState on this
  // whole widget, just this notifier feeding the card-chrome wrapper below.
  final ValueNotifier<double> _maximize = ValueNotifier(0.0);

  // Coarse "is the active page maximized to fullscreen" flag, derived from
  // _maximize crossing a threshold. Flips rarely (not per frame), so widgets
  // that only care about the on/off state — the outer pager's physics and the
  // horizontal-swipe-to-minimize gesture — can listen to this without
  // rebuilding every scroll frame.
  final ValueNotifier<bool> _fullscreen = ValueNotifier(false);

  void _syncFullscreen() {
    final fs = _maximize.value >= 0.9;
    if (fs != _fullscreen.value) _fullscreen.value = fs;
  }

  @override
  void initState() {
    super.initState();
    _maximize.addListener(_syncFullscreen);
    _currentIndex = widget.initialIndex.clamp(0, widget.products.length - 1);
    // viewportFraction < 1 reserves thin side strips so the neighbour cards
    // peek at rest (a swipe hint). On its own that would shrink every page, so
    // the active card is widened back out with an OverflowBox in the item
    // builder — to its normal card width at rest, and all the way to the full
    // screen width (edge-to-edge) as it maximizes, while the peeking
    // neighbours fade away.
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: _kPeekFraction,
    );
  }

  @override
  void dispose() {
    _maximize.removeListener(_syncFullscreen);
    _pageController.dispose();
    _imageGestureActive.dispose();
    _maximize.dispose();
    _fullscreen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.length <= 1) {
      return _ProductDetailPage(product: widget.products[0]);
    }
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        // ── Scrim ──────────────────────────────────────────────────────────
        // The route is opaque: false (see app_router.dart), so whatever
        // screen this was opened from is still painted underneath. At rest
        // this translucent scrim dims it behind the floating card; as the
        // card maximizes to fullscreen the scrim fades fully out (by then
        // the page covers it anyway). Its own ValueListenableBuilder so only
        // this thin layer repaints per scroll frame.
        Positioned.fill(
          child: ValueListenableBuilder<double>(
            valueListenable: _maximize,
            builder: (_, m, __) => ColoredBox(
              color: Colors.black.withValues(alpha: lerpDouble(0.55, 0.0, m)!),
            ),
          ),
        ),

        // ── Product pager ──────────────────────────────────────────────────
        // Rebuilt only when a finger lands on / leaves an image, or when the
        // active page crosses into/out of fullscreen — not per scroll frame —
        // so the PageController and its built pages are preserved. The pager
        // goes inert in BOTH cases: during an image touch (so the gallery /
        // collapse swipe owns the gesture) and while fullscreen (so a
        // horizontal swipe minimizes back to the card instead of paging to
        // another product).
        ListenableBuilder(
          listenable: Listenable.merge([_imageGestureActive, _fullscreen]),
          builder: (context, _) => PageView.builder(
            controller: _pageController,
            itemCount: widget.products.length,
            physics: (_imageGestureActive.value || _fullscreen.value)
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              // The page itself is built ONCE (passed as `child`); only the
              // card-chrome wrapper below re-runs per maximize frame.
              return ValueListenableBuilder<double>(
                valueListenable: _maximize,
                builder: (context, maximize, child) {
                  // Only the centred page maximizes; off-screen neighbours
                  // stay as cards and only peek in at the edges.
                  final isCurrent = index == _currentIndex;
                  final m = isCurrent ? maximize : 0.0;
                  // Top margin floats the card 6.h below the status bar; the
                  // bottom margin floats it the same 6.h ABOVE the system
                  // navigation (bottomInset = 3-button bar or gesture home
                  // indicator). Keying the bottom off bottomInset — not the
                  // unrelated top inset — keeps the gap visually even on both
                  // gesture-nav and 3-button-nav devices. The page's own bottom
                  // safe-area padding is stripped (removeBottom below) so the
                  // add-to-cart bar sits flush at the card's bottom edge; this
                  // margin is the real gap that shows the background behind. At
                  // fullscreen the bottom settles to just the inset so the bar
                  // still clears the navigation.
                  final tPad = lerpDouble(topInset + 6.h, 0.0, m)!;
                  final bPad = lerpDouble(bottomInset + 6.h, bottomInset, m)!;
                  final radius = lerpDouble(16.r, 0.0, m)!;
                  // The viewport is _kPeekFraction wide, which would otherwise
                  // shrink the card. Force the card to a fixed card-view width
                  // (screen minus a 16.w margin each side) with an OverflowBox.
                  // That margin space is split between a small gap to the
                  // neighbour card and the neighbour's peek. As it maximizes the
                  // width grows to the full screen (edge-to-edge).
                  final screenW = MediaQuery.sizeOf(context).width;
                  final cardW = lerpDouble(screenW - 32.w, screenW, m)!;
                  Widget card = Padding(
                    padding: EdgeInsets.only(top: tPad, bottom: bPad),
                    child: OverflowBox(
                      minWidth: cardW,
                      maxWidth: cardW,
                      alignment: Alignment.center,
                      child: PhysicalModel(
                        color: Colors.transparent,
                        // Shadow eases out as it fills the screen — a fullscreen
                        // page has nothing to cast a shadow onto.
                        elevation: lerpDouble(14.0, 0.0, m)!,
                        shadowColor: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(radius),
                        // antiAliasWithSaveLayer (not plain antiAlias) so the
                        // rounded clip also applies to the add-to-cart bar's
                        // BackdropFilter — a composited layer that plain
                        // antiAlias leaves square. This rounds the card's BOTTOM
                        // corners in card view; they flatten to square as
                        // `radius` lerps to 0 at fullscreen. At rest the
                        // RepaintBoundary child caches the result, so the
                        // saveLayer only re-runs mid-transition.
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: child,
                      ),
                    ),
                  );
                  if (!isCurrent) {
                    // Neighbours peek at rest to hint the list is swipeable,
                    // then fade out as the centred card maximizes — so no
                    // neighbour edges are ever visible in fullscreen.
                    final opacity = (1.0 - maximize).clamp(0.0, 1.0);
                    if (opacity <= 0.0) return const SizedBox.shrink();
                    card = Opacity(opacity: opacity, child: card);
                  }
                  return card;
                },
                // Strip the bottom safe-area inset so the add-to-cart bar's
                // own SafeArea adds no padding — the bottom gap is owned by the
                // card margin (bPad) above instead. Built once, with the page.
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: RepaintBoundary(
                    child: _ProductDetailPage(
                      product: widget.products[index],
                      isActive: index == _currentIndex,
                      imageGestureActive: _imageGestureActive,
                      maximizeProgress: _maximize,
                      fullscreen: _fullscreen,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductDetailPage extends ConsumerStatefulWidget {
  final ProductData product;
  // Whether this is the centred (focused) page in the outer products
  // slider. Gates the image carousel's auto-play below — peeking neighbour
  // pages shouldn't be quietly auto-advancing their images in the
  // background while the user's looking at a different product.
  final bool isActive;
  // Flips true while a finger is touching this page's image — see the doc
  // on _ProductDetailScreenState._imageGestureActive.
  final ValueNotifier<bool>? imageGestureActive;
  // This page reports its scroll progress (0 = top → 1 = scrolled past the
  // maximize distance) here, but only while it's the active page, so the
  // outer card chrome can maximize/minimize in sync. See
  // _ProductDetailScreenState._maximize.
  final ValueNotifier<double>? maximizeProgress;
  // Coarse on/off "this page is maximized to fullscreen" flag, owned by the
  // outer screen. Drives two things on this page: the image carousel's
  // two-stage collapse swipe (isFullscreen) and the page-level horizontal
  // swipe-to-minimize gesture. Null for the single-product path (no maximize).
  final ValueNotifier<bool>? fullscreen;
  const _ProductDetailPage({
    required this.product,
    this.isActive = true,
    this.imageGestureActive,
    this.maximizeProgress,
    this.fullscreen,
  });

  @override
  ConsumerState<_ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<_ProductDetailPage> {
  late ProductData _currentProduct;
  bool _detailsExpanded = false;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);
  late ScrollController _scrollController;
  // Resolved fullscreen flag: the outer screen's notifier when supplied,
  // otherwise a private always-false one (single-product path) so the rest of
  // the build can listen unconditionally. Only dispose the one we created.
  late final ValueNotifier<bool> _fs;
  bool _ownsFs = false;

  @override
  void initState() {
    super.initState();
    // Subtle tick acknowledging the product opened (navigation = light).
    AppHaptics.light();
    _currentProduct = widget.product;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    if (widget.fullscreen != null) {
      _fs = widget.fullscreen!;
    } else {
      _fs = ValueNotifier<bool>(false);
      _ownsFs = true;
    }
  }

  // How far you have to scroll to fully maximize the card to fullscreen.
  // Roughly in sync with the image header going edge-to-edge, so the two
  // read as one motion rather than two separate animations.
  double get _maximizeDistance => 120.h;

  void _onScroll() {
    final offset = _scrollController.offset;
    _scrollOffset.value = offset;
    // Only the active page owns the shared maximize progress — neighbours
    // must not fight it (their scroll offsets are independent).
    if (widget.isActive) {
      widget.maximizeProgress?.value =
          (offset / _maximizeDistance).clamp(0.0, 1.0);
    }
  }

  @override
  void didUpdateWidget(_ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.id != oldWidget.product.id) {
      _currentProduct = widget.product;
    }
    // On becoming the active page (e.g. after a horizontal swipe settles),
    // sync the shared maximize progress to this page's own scroll position
    // so the card chrome matches immediately instead of lagging a frame.
    if (widget.isActive && !oldWidget.isActive) {
      final offset =
          _scrollController.hasClients ? _scrollController.offset : 0.0;
      widget.maximizeProgress?.value =
          (offset / _maximizeDistance).clamp(0.0, 1.0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    if (_ownsFs) _fs.dispose();
    super.dispose();
  }

  void _minimizeToCard() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _shareProduct() {
    final box = context.findRenderObject() as RenderBox?;
    final Rect? origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    final p = _currentProduct;
    final clean = (p.description ?? '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final url = "https://vhandar.com/product/${p.slug ?? p.id ?? ''}";
    const store = "https://play.google.com/store/apps/details?id=vhandar.com";
    SharePlus.instance.share(ShareParams(
      text: "Check out *${p.name}* on Let's Vhandar!\n\n"
          "Price: Rs. ${p.actualPrice}\n"
          "${clean.isNotEmpty ? '$clean\n\n' : ''}"
          "👉 View Product: $url\n"
          "📲 Download the App: $store",
      subject: p.name,
      sharePositionOrigin: origin,
    ));
  }

  // ── shared card decoration ──────────────────────────────────────────────
  BoxDecoration _cardDecoration(BuildContext context) {
    final vc = context.vColors;
    return BoxDecoration(
      color: vc.surface,
      borderRadius: BorderRadius.circular(_kCardRadius.r),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final product = _currentProduct;
    final isBusiness = ref.watch(isBusinessUserProvider);
    final isOOS = product.isOutOfStock;
    final hasB2BPrice = isBusiness && (product.businessPricePerUnit ?? 0) > 0;
    final price =
        hasB2BPrice ? product.businessActualPrice : product.actualPrice;
    final mrp = hasB2BPrice
        ? (product.businessPricePerUnit ?? 0)
        : (product.pricePerUnit ?? 0);
    final hasDiscount = !isOOS && mrp > 0 && price < mrp;
    final totalItems = ref.watch(totalCartItemsProvider);

    // consistent EdgeInsets reused across all cards
    final cardMargin = EdgeInsets.symmetric(
        horizontal: _kCardHMargin.w, vertical: _kCardVGap.h);

    return CustomScaffoldWrapper(
      backgroundColor: vc.scaffoldBg,
      isScrollable: false,
      extendBodyBehindAppBar: true,
      // ── AppBar ────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ValueListenableBuilder<double>(
          valueListenable: _scrollOffset,
          builder: (context, offset, _) {
            final ratio = ((offset - 50.h) / (150.h - 50.h)).clamp(0.0, 1.0);
            final curved = Curves.easeInOut.transform(ratio);
            return AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              backgroundColor: AppColor.primary.withValues(alpha: curved),
              elevation: curved * 2,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              automaticallyImplyLeading: false,
              // Nudged toward the bottom of the toolbar (not dead-center) so
              // it sits lower, clear of the status bar — now that the hero
              // image is full-bleed behind it, a button glued to the very
              // top edge made the Hero flight read as a boxy resize instead
              // of a photo sliding into place.
              leading: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: _GlassButton(
                    icon: Icons.keyboard_arrow_down_rounded,
                    isGlass: ratio < 0.5,
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
                          onTap: _shareProduct,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar: ProductAddToCartBar(product: product),

      body: Stack(
        children: [
          // While maximized to fullscreen, a horizontal swipe ANYWHERE on the
          // page minimizes back to the card (the outer pager is held inert
          // meanwhile, so it can't change product). In card view the detector
          // is disabled (null callback), so a horizontal swipe pages between
          // products as usual. _fs flips only at the threshold, so this
          // rebuilds rarely, not per scroll frame.
          ValueListenableBuilder<bool>(
            valueListenable: _fs,
            builder: (context, fs, child) => GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: fs ? (_) => _minimizeToCard() : null,
              child: child,
            ),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Image Slider ───────────────────────────────────────────────
                // A PLAIN scrolling sliver — NOT pinned. The photo scrolls up
                // and off with the rest of the page content; it isn't fixed in
                // place. The card → fullscreen look (side margins, rounded
                // corners, shadow) is applied by the OUTER product-card chrome
                // around the whole page, so this just fills the page width. When
                // maximized, a horizontal swipe ON the image minimizes back to
                // the card via the slider's own two-stage intercept
                // (isFullscreen + onRequestCollapse). RepaintBoundary keeps the
                // carousel's repaints off the rest of the list.
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: SizedBox(
                      height: 320.h,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _fs,
                        builder: (context, fs, _) => ProductImageSlider(
                          product: product,
                          heroTag: 'product-img-${widget.product.id}',
                          // Only the centred page owns the Hero, so a single
                          // image flies in/out — peeking neighbour pages don't
                          // drag their own (tag-matched) images along.
                          enableHero: widget.isActive,
                          autoPlay: widget.isActive,
                          isFullscreen: fs,
                          imageGestureActive: widget.imageGestureActive,
                          onRequestCollapse: _minimizeToCard,
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 10.h)),

                // ══════════════════════════════════════════════════════════════
                // TICKET CARD
                // • Shadow lives on the outer Container's BoxDecoration
                // • NO ClipRRect here — ClipRRect eats the box-shadow AND clips
                //   the _TicketCutoutDivider semicircle notches
                // • Children that must be clipped (e.g. ProductVariantSelector)
                //   should do their own internal clipping
                // • Bottom radius: BorderRadius.circular gives all 4 corners
                // ══════════════════════════════════════════════════════════════
                SliverToBoxAdapter(
                  child: Container(
                    margin: cardMargin,
                    decoration: _cardDecoration(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name & Price ───────────────────────────────────────
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name ?? 'Product Name',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: vc.onSurface,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '${product.unitValue?.toInt()} ${product.unit}',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: vc.onSurfaceMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10.h),

                              // Price row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rs. ${price.toInt()}',
                                    style: TextStyle(
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.bold,
                                      color: vc.onSurface,
                                    ),
                                  ),
                                  if (hasDiscount) ...[
                                    SizedBox(width: 8.w),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 2.h),
                                      child: Text(
                                        'MRP Rs.${mrp.toInt()}',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          color: vc.onSurfaceMuted,
                                          fontWeight: FontWeight.w500,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: AppColor.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        'Save Rs.${(mrp - price).toInt()}',
                                        style: TextStyle(
                                          color: AppColor.primary,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 4.h),
                              if (isOOS)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6.r),
                                    border:
                                        Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'Inclusive of all taxes',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color: vc.onSurfaceMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ── Variant Selector ───────────────────────────────────
                        ProductVariantSelector(
                          baseProduct: widget.product,
                          selected: _currentProduct,
                          onVariantChanged: (v) =>
                              setState(() => _currentProduct = v),
                        ),

                        // ── Brand + Ticket Cutout ──────────────────────────────
                        if (product.brandId != null) ...[
                          _TicketCutoutDivider(
                            bgColor: vc.scaffoldBg,
                            surfaceColor: vc.surface,
                          ),
                          ProductBrandSection(brandId: product.brandId!),
                        ],

                        // Just enough clearance so content never touches the
                        // rounded bottom corners of the card.
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),

                // ══════════════════════════════════════════════════════════════
                // PRODUCT DETAILS — own rounded card, outside ticket
                // ══════════════════════════════════════════════════════════════
                SliverToBoxAdapter(
                  child: Container(
                    margin: cardMargin,
                    decoration: _cardDecoration(context),
                    // ClipRRect safe here — no cutout notches, shadow is on parent
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_kCardRadius.r),
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(
                                () => _detailsExpanded = !_detailsExpanded),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Product Details',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: vc.onSurface,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _detailsExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 250),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: vc.onSurfaceMuted,
                                      size: 20.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: _detailsExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Column(
                              children: [
                                Divider(
                                    height: 1, thickness: 1, color: vc.divider),
                                ProductDetailsTable(
                                    product: product, hideHeader: true),
                                SizedBox(height: 8.h),
                              ],
                            ),
                            secondChild: const SizedBox(width: double.infinity),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ══════════════════════════════════════════════════════════════
                // SIMILAR PRODUCTS — own rounded card
                // ══════════════════════════════════════════════════════════════
                if (product.categoryIds?.isNotEmpty == true)
                  ref
                      .watch(
                          similarProductsProvider(product.categoryIds!.first))
                      .when(
                        data: (products) {
                          final filtered = products
                              .where((p) => p.id != product.id)
                              .toList();
                          if (filtered.isEmpty) {
                            return const SliverToBoxAdapter(
                                child: SizedBox.shrink());
                          }
                          return SliverToBoxAdapter(
                            child: Container(
                              margin: cardMargin,
                              decoration: _cardDecoration(context),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(_kCardRadius.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 3.w,
                                            height: 16.h,
                                            decoration: BoxDecoration(
                                              color: AppColor.primary,
                                              borderRadius:
                                                  BorderRadius.circular(2.r),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Similar Products',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: vc.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    SizedBox(
                                      height: ProductItemCard.preferredHeight,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w),
                                        itemCount: filtered.length,
                                        itemBuilder: (context, index) {
                                          final p = filtered[index];
                                          return ProductItemCard(
                                            product: p,
                                            enableHero: true,
                                            onTap: () => context.pushNamed(
                                              LVRoute.productDetailScreen.route,
                                              extra: ProductDetailNavArgs(
                                                products: filtered,
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        loading: () => SliverToBoxAdapter(
                          child: Container(
                            margin: cardMargin,
                            decoration: _cardDecoration(context),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(_kCardRadius.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16.h),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                    child: Row(
                                      children: [
                                        const CustomShimmer.rectangular(
                                            width: 3, height: 16),
                                        SizedBox(width: 8.w),
                                        const CustomShimmer.rectangular(
                                            width: 120, height: 14),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  const ProductHorizontalListShimmer(
                                      itemCount: 4),
                                  SizedBox(height: 16.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                        error: (e, s) =>
                            const SliverToBoxAdapter(child: SizedBox.shrink()),
                      )
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),

                SliverToBoxAdapter(
                  child: SizedBox(height: totalItems > 0 ? 120.h : 24.h),
                ),
              ],
            ),
          ),

          // ── Floating View Cart badge — always in tree, reacts instantly ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 16.h,
            child: Center(
              child: CartFloatingBadge(
                onTap: () => context.push(LVRoute.cartScreen.route),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TICKET CUTOUT DIVIDER
//
// Draws three things on a single CustomPaint:
//   1. Full-width surface-coloured bar (background)
//   2. Left  D-shaped notch (bgColor = scaffold bg → looks "cut out")
//   3. Right D-shaped notch
//   4. Dashed line between the notches
//
// WHY bgColor not transparent?
//   The card has a box-shadow. A truly transparent hole would reveal the
//   shadow bleed from the container behind it.  Matching the scaffold bg
//   colour hides that and creates the illusion of a physical cutout.
// ═════════════════════════════════════════════════════════════════════════════
class _TicketCutoutDivider extends StatelessWidget {
  final Color bgColor;
  final Color surfaceColor;

  const _TicketCutoutDivider({
    required this.bgColor,
    required this.surfaceColor,
  });

  static const double _r = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _r * 2,
      width: double.infinity,
      child: CustomPaint(
        painter: _CutoutDividerPainter(
          bgColor: bgColor,
          surfaceColor: surfaceColor,
        ),
      ),
    );
  }
}

class _CutoutDividerPainter extends CustomPainter {
  final Color bgColor;
  final Color surfaceColor;

  const _CutoutDividerPainter({
    required this.bgColor,
    required this.surfaceColor,
  });

  static const double _r = 16;
  static const double _dashWidth = 7;
  static const double _dashGap = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final w = size.width;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, size.height),
      Paint()..color = surfaceColor,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, cy), radius: _r),
      -math.pi / 2,
      math.pi,
      true,
      Paint()..color = bgColor,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w, cy), radius: _r),
      math.pi / 2,
      math.pi,
      true,
      Paint()..color = bgColor,
    );

    final paint = Paint()
      ..color = bgColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    double x = _r + _dashGap;
    final endX = w - _r - _dashGap;
    while (x < endX) {
      canvas.drawLine(
        Offset(x, cy),
        Offset((x + _dashWidth).clamp(x, endX), cy),
        paint,
      );
      x += _dashWidth + _dashGap;
    }
  }

  @override
  bool shouldRepaint(_CutoutDividerPainter old) =>
      old.bgColor != bgColor || old.surfaceColor != surfaceColor;
}

// ═════════════════════════════════════════════════════════════════════════════
// GLASS BUTTON  (AppBar back / share)
// ═════════════════════════════════════════════════════════════════════════════
class _GlassButton extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final VoidCallback onTap;
  final bool isGlass;

  const _GlassButton({
    this.icon,
    this.svgAsset,
    required this.onTap,
    this.isGlass = true,
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
        width: 38.w,
        height: 38.w,
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
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                )
              : Icon(icon, color: iconColor, size: 20.sp),
        ),
      ),
    );
  }
}
