import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class ProductDetailScreen extends ConsumerWidget {
  final ProductData product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDiscount =
        product.discount != null && (product.discount?.value ?? 0) > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image Slider
          SliverAppBar(
            expandedHeight: 350.h,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: EdgeInsets.all(8.w),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.black),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: product.images?.length ?? 1,
                    itemBuilder: (context, index) {
                      return CustomImageViewer(
                        path: product.images?.isNotEmpty == true
                            ? product.images![index].url
                            : null,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 100.h,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${product.discount?.value?.toInt()} ${product.discount?.type == 'flat' ? 'OFF' : '% OFF'}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Product Name',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textBlack,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${product.unitValue?.toInt()}${product.unit}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.textMuted,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text(
                        'Rs. ${product.actualPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textBlack,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (hasDiscount) ...[
                        Text(
                          'MRP ${product.pricePerUnit?.toInt()}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColor.textBlack54,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColor.textStrikeThrough,
                            decorationThickness: 2.0,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColor.discountBadge,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'RS. ${product.discount?.value?.toInt()} SAVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '(Inclusive of all taxes)',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColor.textMuted,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Add to Cart Button
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppColor.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'ADD',
                              style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // Why shop from Vhandar
                  Text(
                    'Why shop from Vhandar?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textBlack,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildWhyShopItem(
                    Icons.delivery_dining_outlined,
                    'Superfast Delivery',
                    'Get your order delivered to your doorstep at the earliest from dark stores near you.',
                  ),
                  _buildWhyShopItem(
                    Icons.sell_outlined,
                    'Best Prices & Offers',
                    'Best price destination with offers directly from the manufacturers.',
                  ),
                  _buildWhyShopItem(
                    Icons.category_outlined,
                    'Wide Assortment',
                    'Choose from 5000+ products across food, personal care, household & other categories.',
                  ),

                  SizedBox(height: 32.h),

                  // Product Details Table
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textBlack,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailRow(
                      'Unit', '${product.unitValue?.toInt()} ${product.unit}'),
                  _buildDetailRow('Type', product.status ?? ''),
                  _buildDetailRow('Key Features', product.keyFeatures ?? ''),
                  _buildDetailRow('Shelf Life', product.shelfLife ?? ''),
                  _buildDetailRow('Return Policy', product.returnPolicy ?? ''),
                  _buildDetailRow('Disclaimer', product.disclaimer ?? ''),

                  SizedBox(height: 32.h),

                  // Similar Products
                  Text(
                    'Similar Products',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textBlack,
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // Similar Products List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250.h,
              child: product.categoryIds?.isNotEmpty == true
                  ? ref
                      .watch(
                          similarProductsProvider(product.categoryIds!.first))
                      .when(
                        data: (products) {
                          // Filter out the current product
                          final filteredProducts = products
                              .where((p) => p.id != product.id)
                              .toList();

                          if (filteredProducts.isEmpty) {
                            return const Center(
                                child: Text('No similar products found'));
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final p = filteredProducts[index];
                              return ProductItemCard(
                                product: p,
                                onTap: () {
                                  context.pushNamed(
                                    LVRoute.productDetailScreen.route,
                                    extra: p,
                                  );
                                },
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const SizedBox.shrink(),
                      )
                  : const Center(
                      child: Text('No category information available')),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  Widget _buildWhyShopItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.primary, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textBlack,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textBlack87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textBlack,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColor.textBlack87,
            ),
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
