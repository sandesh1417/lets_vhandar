import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

import 'product_card_style.dart';
import 'product_details_table.dart';

/// Expandable "Product Details" card — tap the header to reveal the spec table.
/// The expanded/collapsed state is purely local UI, so it's owned here.
class ProductDetailsExpandable extends StatefulWidget {
  const ProductDetailsExpandable({super.key, required this.product});

  final ProductData product;

  @override
  State<ProductDetailsExpandable> createState() =>
      _ProductDetailsExpandableState();
}

class _ProductDetailsExpandableState extends State<ProductDetailsExpandable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return SliverToBoxAdapter(
      child: Container(
        margin: productCardMargin(),
        decoration: productCardDecoration(context),
        // ClipRRect safe here — no cutout notches, shadow is on parent.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kCardRadius.r),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                        turns: _expanded ? 0.5 : 0,
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
                crossFadeState: _expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  children: [
                    Divider(height: 1, thickness: 1, color: vc.divider),
                    ProductDetailsTable(product: widget.product, hideHeader: true),
                    SizedBox(height: 8.h),
                  ],
                ),
                secondChild: const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
