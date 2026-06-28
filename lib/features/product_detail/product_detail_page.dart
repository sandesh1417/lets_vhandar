import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:share_plus/share_plus.dart';

import 'animation/card_maximize_controller.dart';
import 'animation/horizontal_swipe_handler.dart';
import 'animation/swipe_dismiss_wrapper.dart';
import 'widgets/product_add_to_cart_bar.dart';
import 'widgets/product_app_bar.dart';
import 'widgets/product_details_expandable.dart';
import 'widgets/product_image_header.dart';
import 'widgets/product_info_section.dart';
import 'widgets/similar_products_section.dart';

/// A single product page inside the [ProductDetailScreen] pager: its own scroll
/// view, AppBar fade, add-to-cart bar and content sections. Thin orchestrator —
/// it wires the shared animation controllers to the UI sections and holds only
/// scroll/selection state; all gesture & morph logic lives under `animation/`.
class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.isActive,
    required this.imageGestureActive,
    required this.maximize,
    required this.activeScroll,
  });

  final ProductData product;

  /// Whether this is the centred (focused) page. Gates Hero ownership, image
  /// auto-play, and whether this page drives the shared maximize/scroll state.
  final bool isActive;

  /// Flips true while a finger is on this page's image (set deep in the slider),
  /// so the outer pager goes inert and can't steal the gallery/collapse swipe.
  final ValueNotifier<bool> imageGestureActive;

  /// Shared card↔fullscreen morph state — this page reports its scroll offset
  /// into it while active.
  final CardMaximizeController maximize;

  /// This page mirrors its scroll offset here (only while active) so the
  /// screen-level [SwipeDismissWrapper] knows whether the page is at the top.
  final ValueNotifier<double> activeScroll;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late ProductData _currentProduct;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Subtle tick acknowledging the product opened (navigation = light).
    AppHaptics.light();
    _currentProduct = widget.product;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    _scrollOffset.value = offset;
    // Only the active page owns the shared maximize progress and reports its
    // scroll position up to the screen-level swipe-to-dismiss — neighbours must
    // not fight it (their scroll offsets are independent).
    if (widget.isActive) {
      widget.activeScroll.value = offset;
      widget.maximize.updateFromOffset(offset);
    }
  }

  @override
  void didUpdateWidget(ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.id != oldWidget.product.id) {
      _currentProduct = widget.product;
    }
    // On becoming the active page (e.g. after a horizontal swipe settles), sync
    // the shared maximize progress to this page's own scroll position so the
    // card chrome matches immediately instead of lagging a frame.
    if (widget.isActive && !oldWidget.isActive) {
      final offset =
          _scrollController.hasClients ? _scrollController.offset : 0.0;
      widget.activeScroll.value = offset;
      widget.maximize.updateFromOffset(offset);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
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

  @override
  Widget build(BuildContext context) {
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

    return CustomScaffoldWrapper(
      backgroundColor: context.vColors.scaffoldBg,
      isScrollable: false,
      extendBodyBehindAppBar: true,
      appBar: ProductDetailAppBar(
        scrollOffset: _scrollOffset,
        product: product,
        price: price,
        onShare: _shareProduct,
      ),
      bottomNavigationBar: ProductAddToCartBar(product: product),
      body: Stack(
        children: [
          // While maximized, a horizontal swipe anywhere on the page minimizes
          // back to the card; in card view it pages between products as usual.
          HorizontalSwipeToMinimize(
            fullscreen: widget.maximize.fullscreen,
            onMinimize: _minimizeToCard,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const DismissDragScrollPhysics(),
              slivers: [
                ProductImageHeader(
                  product: product,
                  heroTag: 'product-img-${widget.product.id}',
                  isActive: widget.isActive,
                  fullscreen: widget.maximize.fullscreen,
                  imageGestureActive: widget.imageGestureActive,
                  onRequestCollapse: _minimizeToCard,
                ),
                SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                ProductInfoSection(
                  product: product,
                  baseProduct: widget.product,
                  price: price,
                  mrp: mrp,
                  hasDiscount: hasDiscount,
                  isOOS: isOOS,
                  onVariantChanged: (v) => setState(() => _currentProduct = v),
                ),
                ProductDetailsExpandable(product: product),
                SimilarProductsSection(
                  product: product,
                  isActive: widget.isActive,
                ),
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
