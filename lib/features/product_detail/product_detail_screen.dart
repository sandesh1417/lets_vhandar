import 'dart:math' as math;

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

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductData product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late ProductData _currentProduct;
  bool _detailsExpanded = false;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Subtle tick acknowledging the product opened (navigation = light).
    AppHaptics.light();
    _currentProduct = widget.product;
    _scrollController = ScrollController();
    _scrollController
        .addListener(() => _scrollOffset.value = _scrollController.offset);
  }

  @override
  void didUpdateWidget(ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.id != oldWidget.product.id) {
      _currentProduct = widget.product;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
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
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Rs. ${price.toInt()}',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11.sp,
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
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Image Slider ───────────────────────────────────────────────
              // Parallax: as the user scrolls, the image shifts up slightly
              // faster than the page itself, giving it depth. Reuses the
              // existing _scrollOffset ValueNotifier (already fed by
              // _scrollController for the AppBar fade above) — no extra
              // listener/controller, no setState, no Scaffold rebuild. The
              // RepaintBoundary keeps that per-frame repaint isolated to just
              // this image layer.
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 320.h,
                pinned: false,
                backgroundColor: vc.scaffoldBg,
                flexibleSpace: FlexibleSpaceBar(
                  background: RepaintBoundary(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scrollOffset,
                      builder: (_, offset, child) => Transform.translate(
                        offset: Offset(0, -(offset * 0.35).clamp(0.0, 80.0)),
                        child: child,
                      ),
                      child: ProductImageSlider(
                        product: product,
                        heroTag: 'product-img-${widget.product.id}',
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
                        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name ?? 'Product Name',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: vc.onSurface,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${product.unitValue?.toInt()} ${product.unit}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: vc.onSurfaceMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Price row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${price.toInt()}',
                                  style: TextStyle(
                                    fontSize: 22.sp,
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
                                        fontSize: 13.sp,
                                        color: vc.onSurfaceMuted,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.lineThrough,
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
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'Save Rs.${(mrp - price).toInt()}',
                                      style: TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 11.sp,
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
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Inclusive of all taxes',
                                style: TextStyle(
                                  fontSize: 9.sp,
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
                                horizontal: 16.w, vertical: 14.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Product Details',
                                    style: TextStyle(
                                      fontSize: 14.sp,
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
                    .watch(similarProductsProvider(product.categoryIds!.first))
                    .when(
                      data: (products) {
                        final filtered =
                            products.where((p) => p.id != product.id).toList();
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.w),
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
                                            fontSize: 15.sp,
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
                                          onTap: () => context.pushNamed(
                                            LVRoute.productDetailScreen.route,
                                            extra: p,
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
                            borderRadius: BorderRadius.circular(_kCardRadius.r),
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
