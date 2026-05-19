import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/product_detail/widgets/product_brand_section.dart';

import 'widgets/product_add_to_cart_bar.dart';
import 'widgets/product_details_table.dart';
import 'widgets/product_image_slider.dart';
import 'widgets/product_variant_selector.dart';
import 'widgets/product_why_shop_section.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductData product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late ProductData _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  @override
  void didUpdateWidget(ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.id != oldWidget.product.id) {
      _currentProduct = widget.product;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _currentProduct;
    final hasDiscount =
        product.discount != null && (product.discount?.value ?? 0) > 0;

    return CustomScaffoldWrapper(
      backgroundColor: const Color(0xFFF8F9FB),
      isScrollable: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: _GlassButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.all(8.w),
              child: _GlassButton(
                icon: Icons.share_outlined,
                onTap: () {
                  debugPrint('--- Share Button Tapped ---');
                  final box = context.findRenderObject() as RenderBox?;
                  final Rect? sharePositionOrigin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  
                  // Strip HTML tags from description
                  final rawDesc = product.description ?? '';
                  final cleanDesc = rawDesc
                      .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '')
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim();
                  
                  final productUrl = "https://vhandar.com/product/${product.slug ?? product.id ?? ''}";
                  final playStoreUrl = "https://play.google.com/store/apps/details?id=com.example.lets_vhandar";
                  
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
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductAddToCartBar(product: product),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Image Area ───────────────────────────────────────────────
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 320.h,
            pinned: false,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: ProductImageSlider(product: product),
            ),
          ),

          // ─── Product Info Card ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(top: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
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
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textBlack,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${product.unitValue?.toInt()} ${product.unit}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColor.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 14.h),

                        // Price row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${product.actualPrice.toInt()}',
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.textBlack,
                              ),
                            ),
                            if (hasDiscount) ...[
                              SizedBox(width: 10.w),
                              Padding(
                                padding: EdgeInsets.only(bottom: 3.h),
                                child: Text(
                                  'MRP Rs.${product.pricePerUnit?.toInt()}',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColor.textMuted,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1E8B5A),
                                      Color(0xFF27AE70)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '${product.discount?.value?.toInt()}${product.discount?.type == 'flat' ? ' Rs' : '%'} OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          'Inclusive of all taxes',
                          style: TextStyle(
                              fontSize: 10.sp, color: AppColor.textMuted),
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
                      color: Colors.grey.shade100,
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

                  // ── Similar Products ──
                  Row(
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
                          color: AppColor.textBlack,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),

          // Similar Products List
          SliverToBoxAdapter(
            child: SizedBox(
              height: ProductItemCard.preferredHeight,
              child: product.categoryIds?.isNotEmpty == true
                  ? ref
                      .watch(
                          similarProductsProvider(product.categoryIds!.first))
                      .when(
                        data: (products) {
                          final filtered = products
                              .where((p) => p.id != product.id)
                              .toList();
                          if (filtered.isEmpty) {
                            return Center(
                              child: Text(
                                'No similar products found',
                                style: TextStyle(
                                    color: AppColor.textMuted, fontSize: 13.sp),
                              ),
                            );
                          }
                          return ListView.builder(
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
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const SizedBox.shrink(),
                      )
                  : const SizedBox.shrink(),
            ),
          ),
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

  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size ?? 38.w,
        height: size ?? 38.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF5).withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColor.primary, size: iconSize ?? 20.sp),
      ),
    );
  }
}
