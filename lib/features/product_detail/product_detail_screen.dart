import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/product_detail/widgets/product_brand_section.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:share_plus/share_plus.dart';

import 'widgets/product_add_to_cart_bar.dart';
import 'widgets/product_details_table.dart';
import 'widgets/product_image_slider.dart';
import 'widgets/product_variant_selector.dart';
import 'widgets/product_why_shop_section.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductData product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late ProductData _currentProduct;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });
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
    debugPrint('--- Share Button Tapped ---');
    final box = context.findRenderObject() as RenderBox?;
    final Rect? sharePositionOrigin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    final product = _currentProduct;
    // Strip HTML tags from description
    final rawDesc = product.description ?? '';
    final cleanDesc = rawDesc
        .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final productUrl =
        "https://vhandar.com/product/${product.slug ?? product.id ?? ''}";
    const playStoreUrl =
        "https://play.google.com/store/apps/details?id=com.vhandar.app";

    final shareText = "Check out *${product.name}* on Let's Vhandar!\n\n"
        "Price: Rs. ${product.actualPrice}\n"
        "${cleanDesc.isNotEmpty ? '$cleanDesc\n\n' : ''}"
        "👉 View Product: $productUrl\n"
        "📲 Download the App: $playStoreUrl";

    debugPrint('Sharing content: $shareText');
    Share.share(
      shareText,
      subject: product.name,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final product = _currentProduct;
    final hasDiscount =
        product.discount != null && (product.discount?.value ?? 0) > 0;

    return CustomScaffoldWrapper(
      backgroundColor: vc.scaffoldBg,
      isScrollable: false,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ValueListenableBuilder<double>(
          valueListenable: _scrollOffset,
          builder: (context, offset, child) {
            final double collapseStart = 50.h;
            final double collapseEnd = 150.h;
            final double ratio =
                ((offset - collapseStart) / (collapseEnd - collapseStart))
                    .clamp(0.0, 1.0);

            final double curvedRatio = Curves.easeInOut.transform(ratio);
            final Color appBarBgColor =
                vc.surface.withValues(alpha: curvedRatio);
            final double elevation = curvedRatio * 2.0;

            return AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: appBarBgColor,
              elevation: elevation,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              automaticallyImplyLeading: false,
              leading: Center(
                child: _GlassButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                  isGlass: ratio < 0.5,
                ),
              ),
              titleSpacing: 0,
              title: Opacity(
                opacity: curvedRatio,
                child: Transform.translate(
                  offset: Offset(0, (1 - curvedRatio) * 12.h),
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
                                color: vc.onSurface,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Rs. ${product.actualPrice.toInt()}',
                              style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _GlassButton(
                      icon: Icons.share_outlined,
                      onTap: _shareProduct,
                      isGlass: ratio < 0.5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: ProductAddToCartBar(product: product),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Image Area ───────────────────────────────────────────────
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 320.h,
            pinned: false,
            backgroundColor: vc.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: ProductImageSlider(product: product),
            ),
          ),

          // ─── Product Info Card ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(top: 4.h),
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name & Price ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name ?? 'Product Name',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
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
                              'Rs. ${product.actualPrice.toInt()}',
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
                                  'MRP Rs.${product.pricePerUnit?.toInt()}',
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
                                  color: AppColor.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '${product.discount?.value?.toInt()}${product.discount?.type == 'flat' ? ' Rs' : '%'} OFF',
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
                        SizedBox(height: 2.h),
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

                  // ── Brand Section ──
                  if (product.brandId != null)
                    ProductBrandSection(brandId: product.brandId!),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Divider(
                      height: 1.h,
                      color: vc.divider,
                      thickness: 1,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Variant Selector ──
                  ProductVariantSelector(
                    baseProduct: widget.product,
                    selected: _currentProduct,
                    onVariantChanged: (v) =>
                        setState(() => _currentProduct = v),
                  ),
                ],
              ),
            ),
          ),

          // ─── Body Content ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  ProductDetailsTable(product: product),
                  SizedBox(height: 20.h),
                  const ProductWhyShopSection(),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ),

          // Similar Products
          if (product.categoryIds?.isNotEmpty == true)
            ref.watch(similarProductsProvider(product.categoryIds!.first)).when(
                  data: (products) {
                    final filtered = products
                        .where((p) => p.id != product.id)
                        .toList();
                    if (filtered.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              children: [
                                Container(
                                  width: 3.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                    color: AppColor.primary,
                                    borderRadius: BorderRadius.circular(2.r),
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
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                        ],
                      ),
                    );
                  },
                  loading: () => SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator(color: AppColor.primary)),
                  ),
                  error: (e, s) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                )
          else
            const SliverToBoxAdapter(child: SizedBox.shrink()),

          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double? size;
  final double? iconSize;
  final bool isGlass;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.size,
    this.iconSize,
    this.isGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size ?? 38.w,
        height: size ?? 38.w,
        decoration: BoxDecoration(
          color: isGlass
              ? const Color(0xFFF0FAF5).withValues(alpha: 0.9)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isGlass ? AppColor.primary : context.vColors.onSurface,
          size: iconSize ?? 20.sp,
        ),
      ),
    );
  }
}
