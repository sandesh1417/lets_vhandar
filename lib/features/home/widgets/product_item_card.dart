import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_variants_provider.dart';
import 'package:lets_vhandar/widgets/custom_circular_loader.dart';
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

  static double get preferredHeight => 226.h;

  @override
  ConsumerState<ProductItemCard> createState() => _ProductItemCardState();

  static void showVariantBottomSheet(
      BuildContext context, WidgetRef ref, ProductData product,
      {required Function(ProductData) onVariantSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return Container(
              padding: EdgeInsets.all(16.w),
              height: 400.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name ?? 'Select Variant',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textBlack,
                            ),
                          ),
                          Text(
                            'Choose your preferred size/pack',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColor.textMuted,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: ref.watch(productVariantsProvider(product)).when(
                          data: (variants) {
                            if (variants.isEmpty) {
                              return Center(
                                child: Text(
                                  'No variants available',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColor.textMuted,
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              itemCount: variants.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                final v = variants[index];
                                final hasDiscount = v.discount != null &&
                                    (v.discount?.value ?? 0) > 0;
                                final savings = v.pricePerUnit!.toInt() -
                                    v.actualPrice.toInt();

                                return GestureDetector(
                                  onTap: () {
                                    onVariantSelected(v);
                                    Navigator.pop(context);
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            if (v.images?.isNotEmpty ==
                                                true) ...[
                                              Container(
                                                padding: EdgeInsets.all(4.w),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade100),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: CustomImageViewer(
                                                  path: v.images!.first.url,
                                                  width: 50.w,
                                                  height: 50.h,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              SizedBox(width: 16.w),
                                            ],
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${v.unitValue?.toInt()} ${v.unit}',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColor.textBlack,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .baseline,
                                                    textBaseline:
                                                        TextBaseline.alphabetic,
                                                    children: [
                                                      Text(
                                                        'Rs ${v.actualPrice.toInt()}',
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: AppColor
                                                              .textBlack,
                                                        ),
                                                      ),
                                                      if (hasDiscount) ...[
                                                        SizedBox(width: 8.w),
                                                        Text(
                                                          'MRP ${v.pricePerUnit?.toInt()}',
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: AppColor
                                                                .textMuted,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _VariantCartButton(product: v),
                                          ],
                                        ),
                                      ),
                                      if (hasDiscount)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 4.h),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFE53935),
                                                  Color(0xFFFF7043)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16.r),
                                                bottomRight:
                                                    Radius.circular(12.r),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('SAVE',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8.sp,
                                                        fontWeight:
                                                            FontWeight.w900)),
                                                SizedBox(width: 4.w),
                                                Text('Rs $savings',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w900)),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CustomCircularLoader()),
                          error: (e, s) => Center(
                            child: Text(
                              'Failed to load variants',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductItemCardState extends ConsumerState<ProductItemCard> {
  late ProductData _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  void _showVariantBottomSheet() {
    ProductItemCard.showVariantBottomSheet(context, ref, widget.product,
        onVariantSelected: (v) {
      setState(() {
        _currentProduct = v;
      });
    });
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
        height: ProductItemCard.preferredHeight,
        margin: widget.margin ?? EdgeInsets.only(right: 12.w, bottom: 8.h),
        padding: EdgeInsets.zero,
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
                  height: 100.h, // Reduced for compactness
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // color: Colors.grey.shade50,
                    color: Colors.white,
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                          Text(
                              'Rs ${product.pricePerUnit!.toInt() - product.actualPrice.toInt()}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (product.isVegeterian != null)
                  Positioned(
                    bottom: 6.h,
                    right: 6.w,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: product.isVegeterian!
                              ? const Color(0xFF008B58)
                              : const Color(0xFFE53935),
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          color: product.isVegeterian!
                              ? const Color(0xFF008B58)
                              : const Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name ?? 'Product Name',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textBlack87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 6.h),
                      (widget.product.hasVariant == true ||
                              widget.product.parentId != null)
                          ? GestureDetector(
                              onTap: _showVariantBottomSheet,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
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
                                        size: 14.sp,
                                        color: Colors.grey.shade600),
                                  ],
                                ),
                              ),
                            )
                          : Text('${product.unitValue?.toInt()}${product.unit}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColor.textBlack54,
                                fontWeight: FontWeight.w500,
                              )),
                    ],
                  ),
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
            )),
            SizedBox(height: 4.h)
          ],
        ),
      ),
    );
  }
}

class _VariantCartButton extends ConsumerWidget {
  final ProductData product;

  const _VariantCartButton({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cartProvider);
    final cartCount =
        ref.read(cartProvider.notifier).getCartItemCount(product.id!);

    if (cartCount == 0) {
      return ElevatedButton(
        onPressed: () {
          ref.read(cartProvider.notifier).addToCart(product);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: AppColor.primary),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text('ADD', style: TextStyle(color: AppColor.primary)),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => ref
                  .read(cartProvider.notifier)
                  .updateQuantity(product.id!, cartCount - 1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                color: Colors.transparent,
                child: const Icon(Icons.remove, color: Colors.white, size: 16),
              ),
            ),
            Text('$cartCount',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => ref
                  .read(cartProvider.notifier)
                  .updateQuantity(product.id!, cartCount + 1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                color: Colors.transparent,
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      );
    }
  }
}
