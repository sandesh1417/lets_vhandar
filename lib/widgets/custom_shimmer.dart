import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

class CustomShimmer extends StatefulWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const CustomShimmer.rectangular({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  });

  const CustomShimmer.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase =
        isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;
    final shimmerHighlight =
        isDark ? const Color(0xFF383838) : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: ShapeDecoration(
            shape: widget.shapeBorder,
            gradient: LinearGradient(
              colors: [shimmerBase, shimmerHighlight, shimmerBase],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-2.0 + _controller.value * 4.0, -0.3),
              end: Alignment(0.0 + _controller.value * 4.0, 0.3),
            ),
          ),
        );
      },
    );
  }
}

class GridShimmer extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final int itemCount;
  final bool isCircle;

  const GridShimmer({
    super.key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 0.82,
    this.itemCount = 8,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Column(
          children: [
            isCircle
                ? const CustomShimmer.circular(width: 65, height: 65)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child:
                        const CustomShimmer.rectangular(height: 75, width: 75),
                  ),
            SizedBox(height: 6.h),
            const CustomShimmer.rectangular(height: 10, width: 50),
          ],
        );
      },
    );
  }
}

class OrderListShimmer extends StatelessWidget {
  final int itemCount;

  const OrderListShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: vc.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: vc.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomShimmer.rectangular(height: 14, width: 120),
                  CustomShimmer.rectangular(height: 20, width: 80),
                ],
              ),
              SizedBox(height: 12.h),
              const CustomShimmer.rectangular(height: 12, width: 200),
              SizedBox(height: 8.h),
              const CustomShimmer.rectangular(height: 12, width: 150),
              SizedBox(height: 12.h),
              Divider(color: vc.divider, height: 1),
              SizedBox(height: 12.h),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomShimmer.rectangular(height: 16, width: 100),
                  CustomShimmer.rectangular(height: 28, width: 90),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class HorizontalListShimmer extends StatelessWidget {
  final double height;
  final double width;
  final int itemCount;

  const HorizontalListShimmer({
    super.key,
    this.height = 110,
    this.width = 75,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          return SizedBox(
            width: width.w,
            child: Column(
              children: [
                const CustomShimmer.circular(width: 65, height: 65),
                SizedBox(height: 6.h),
                const CustomShimmer.rectangular(height: 10, width: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductHorizontalListShimmer extends StatelessWidget {
  final int itemCount;

  const ProductHorizontalListShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return SizedBox(
      height: 226.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return Container(
            width: 140.w,
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: vc.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: const CustomShimmer.rectangular(
                      height: 100, width: double.infinity),
                ),
                Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomShimmer.rectangular(height: 10, width: 100),
                      SizedBox(height: 4.h),
                      const CustomShimmer.rectangular(height: 10, width: 80),
                      SizedBox(height: 12.h),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomShimmer.rectangular(height: 12, width: 45),
                          CustomShimmer.rectangular(height: 24, width: 40),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Scrollable shimmer grid that mirrors [ProductGrid] / [ProductItemCard] layout.
/// Uses [mainAxisExtent] so card height stays consistent with the real grid.
class BrandProductGridShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const BrandProductGridShimmer({
    super.key,
    this.itemCount = 6,
    this.padding,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return GridView.builder(
      padding: padding ?? EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 80.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: mainAxisSpacing ?? 6.h,
        crossAxisSpacing: crossAxisSpacing ?? 6.w,
        mainAxisExtent: 226.h,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: vc.surface,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                child: const CustomShimmer.rectangular(
                    height: 105, width: double.infinity),
              ),
              Padding(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomShimmer.rectangular(
                        height: 10, width: double.infinity),
                    SizedBox(height: 4.h),
                    const CustomShimmer.rectangular(height: 10, width: 80),
                    SizedBox(height: 8.h),
                    const CustomShimmer.rectangular(height: 10, width: 60),
                    SizedBox(height: 10.h),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomShimmer.rectangular(height: 14, width: 55),
                        CustomShimmer.rectangular(height: 28, width: 45),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProductGridShimmer extends StatelessWidget {
  final int itemCount;

  const ProductGridShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: vc.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: vc.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: const CustomShimmer.rectangular(
                    height: 120, width: double.infinity),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomShimmer.rectangular(height: 12, width: 120),
                    SizedBox(height: 6.h),
                    const CustomShimmer.rectangular(height: 10, width: 80),
                    SizedBox(height: 16.h),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomShimmer.rectangular(height: 14, width: 60),
                        CustomShimmer.rectangular(height: 28, width: 50),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class BrandSidebarShimmer extends StatelessWidget {
  final int itemCount;
  const BrandSidebarShimmer({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: const CustomShimmer.rectangular(height: 40, width: 40),
              ),
              SizedBox(height: 5.h),
              const CustomShimmer.rectangular(height: 8, width: 45),
            ],
          ),
        );
      },
    );
  }
}

class BillDetailsShimmer extends StatelessWidget {
  const BillDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return SizedBox(
      height: 200,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomShimmer.rectangular(height: 14, width: 100),
            SizedBox(height: 16.h),
            _billRow(),
            SizedBox(height: 10.h),
            _billRow(width: 100),
            SizedBox(height: 10.h),
            _billRow(width: 140),
            SizedBox(height: 10.h),
            _billRow(width: 110),
            const Spacer(),
            Divider(color: vc.divider, height: 1),
            SizedBox(height: 10.h),
            _billRow(height: 16, width: 80, valueWidth: 70),
          ],
        ),
      ),
    );
  }

  static Widget _billRow({
    double height = 12,
    double width = 120,
    double valueWidth = 55,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomShimmer.rectangular(height: height, width: width),
        CustomShimmer.rectangular(height: height, width: valueWidth),
      ],
    );
  }
}

class OrderDetailShimmer extends StatelessWidget {
  const OrderDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: vc.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomShimmer.rectangular(height: 14, width: 130),
                    SizedBox(height: 8.h),
                    const CustomShimmer.rectangular(height: 11, width: 90),
                  ],
                ),
                const CustomShimmer.rectangular(height: 28, width: 80),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: const CustomShimmer.rectangular(
                height: 56, width: double.infinity),
          ),
          SizedBox(height: 24.h),
          const CustomShimmer.rectangular(height: 14, width: 100),
          SizedBox(height: 12.h),
          ...List.generate(3, (_) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: vc.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: vc.divider),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: const CustomShimmer.rectangular(
                          height: 60, width: 60),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomShimmer.rectangular(
                              height: 12, width: double.infinity),
                          SizedBox(height: 8.h),
                          const CustomShimmer.rectangular(height: 11, width: 80),
                          SizedBox(height: 8.h),
                          const CustomShimmer.rectangular(height: 14, width: 60),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: vc.divider),
            ),
            child: const BillDetailsShimmer(),
          ),
        ],
      ),
    );
  }
}

class MyListsShimmer extends StatelessWidget {
  final int itemCount;
  const MyListsShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: vc.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: vc.divider),
          ),
          child: Row(
            children: [
              const CustomShimmer.circular(width: 40, height: 40),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomShimmer.rectangular(height: 13, width: 140),
                    SizedBox(height: 6.h),
                    const CustomShimmer.rectangular(height: 11, width: 90),
                  ],
                ),
              ),
              const CustomShimmer.rectangular(height: 20, width: 20),
            ],
          ),
        );
      },
    );
  }
}
