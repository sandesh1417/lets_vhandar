import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vhandar/features/home/domain/models/product_modal.dart';
import 'package:vhandar/widgets/custom_image_viewer.dart';

class ProductImageSlider extends StatefulWidget {
  final ProductData product;

  const ProductImageSlider({super.key, required this.product});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images ?? [];
    final hasDiscount = widget.product.discount != null &&
        (widget.product.discount?.value ?? 0) > 0;

    return Stack(
      children: [
        // White background behind image
        Container(
          color: Colors.white,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: CustomImageViewer(
                  path: images.isNotEmpty ? images[index].url : null,
                  fit: BoxFit.contain,
                ),
              );
            },
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
                        ? const Color(0xFF0A754E)
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ),

      ],
    );
  }
}
