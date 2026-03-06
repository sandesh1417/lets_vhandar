import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_variants_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class ProductItemCard extends ConsumerStatefulWidget {
  final ProductData product;
  final VoidCallback? onTap;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const ProductItemCard({
    super.key,
    required this.product,
    this.onTap,
    this.width,
    this.margin,
  });

  @override
  ConsumerState<ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends ConsumerState<ProductItemCard> {
  late ProductData _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  void _showVariantBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          height: 300.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentProduct.name ?? 'Select Variant',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textBlack,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ref.watch(productVariantsProvider(widget.product)).when(
                      data: (variants) {
                        return ListView.separated(
                          itemCount: variants.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final v = variants[index];
                            final vHasDiscount = v.discount != null &&
                                (v.discount?.value ?? 0) > 0;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentProduct = v;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    if (v.images?.isNotEmpty == true) ...[
                                      CustomImageViewer(
                                        path: v.images!.first.url,
                                        width: 50.w,
                                        height: 50.h,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: 12.w),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${v.unitValue?.toInt()} ${v.unit}',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              Text(
                                                'Rs. ${v.actualPrice.toInt()}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (vHasDiscount) ...[
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'MRP ${v.pricePerUnit?.toInt()}',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: AppColor.textMuted,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Add button for variant inside sheet
                                    Consumer(
                                      builder: (context, ref, _) {
                                        // Watch the cart items to trigger rebuilds
                                        ref.watch(cartProvider);
                                        final cartCount = ref
                                            .read(cartProvider.notifier)
                                            .getCartItemCount(v.id!);
                                        if (cartCount == 0) {
                                          return ElevatedButton(
                                            onPressed: () {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .addToCart(v);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              side: BorderSide(
                                                  color: AppColor.primary),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                            ),
                                            child: Text('ADD',
                                                style: TextStyle(
                                                    color: AppColor.primary)),
                                          );
                                        } else {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.primary,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => ref
                                                      .read(
                                                          cartProvider.notifier)
                                                      .updateQuantity(
                                                          v.id!, cartCount - 1),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8.w,
                                                            vertical: 4.h),
                                                    color: Colors.transparent,
                                                    child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 16),
                                                  ),
                                                ),
                                                Text('$cartCount',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                GestureDetector(
                                                  onTap: () => ref
                                                      .read(
                                                          cartProvider.notifier)
                                                      .updateQuantity(
                                                          v.id!, cartCount + 1),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8.w,
                                                            vertical: 4.h),
                                                    color: Colors.transparent,
                                                    child: const Icon(Icons.add,
                                                        color: Colors.white,
                                                        size: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const SizedBox.shrink(),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _currentProduct;
    final hasDiscount =
        product.discount != null && (product.discount?.value ?? 0) > 0;
    final discountValue = product.discount?.value?.toInt();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width ?? 140.w,
        margin: widget.margin ?? EdgeInsets.only(right: 12.w, bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100.h, // Reduced from 120.h
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12.r)),
                  ),
                  child: CustomImageViewer(
                    path: product.images?.first.url,
                    borderRadius: 12.r,
                    fit: BoxFit.contain,
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r)),
                      ),
                      child: Column(
                        children: [
                          Text('SAVE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold)),
                          Text('Rs $discountValue',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name ?? 'Product Name',
                      style: TextStyle(
                        fontSize: 11.sp, // Reduced from 12.sp
                        fontWeight: FontWeight.w700,
                        color: AppColor.textBlack87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  if (widget.product.hasVariant == true)
                    GestureDetector(
                      onTap: _showVariantBottomSheet,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                '${product.unitValue?.toInt()} ${product.unit}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColor.textBlack87,
                                  fontWeight: FontWeight.w600,
                                )),
                            SizedBox(width: 4.w),
                            Icon(Icons.keyboard_arrow_down,
                                size: 14.sp, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    )
                  else
                    Text('${product.unitValue?.toInt()}${product.unit}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColor.textBlack54,
                          fontWeight: FontWeight.w500,
                        )),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rs. ${product.actualPrice.toInt()}',
                              style: TextStyle(
                                fontSize: 12.sp, // Reduced from 13.sp
                                fontWeight: FontWeight.bold,
                                color: AppColor.textBlack,
                              )),
                          if (hasDiscount)
                            Text('MRP ${product.pricePerUnit?.toInt()}',
                                style: TextStyle(
                                    fontSize: 9.sp, // Reduced from 10.sp
                                    color: AppColor.textBlack87,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColor.textStrikeThrough,
                                    decorationThickness: 2.0)),
                        ],
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          // Watch the cartItems to trigger rebuilds on quantity changes
                          ref.watch(cartProvider);
                          final cartCount = ref
                              .read(cartProvider.notifier)
                              .getCartItemCount(product.id!);
                          if (cartCount == 0) {
                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .addToCart(product);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.primary),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'ADD',
                                  style: TextStyle(
                                      color: AppColor.primary,
                                      fontSize: 11.sp, // Reduced from 12.sp
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              height: 30.h,
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(
                                              product.id!, cartCount - 1);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 4.h),
                                      color: Colors.transparent,
                                      child: Icon(Icons.remove,
                                          color: Colors.white, size: 16.sp),
                                    ),
                                  ),
                                  Text(
                                    '$cartCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(
                                              product.id!, cartCount + 1);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 4.h),
                                      color: Colors.transparent,
                                      child: Icon(Icons.add,
                                          color: Colors.white, size: 16.sp),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
