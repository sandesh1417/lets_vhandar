import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

class ProductBrandSection extends ConsumerWidget {
  final String brandId;
  const ProductBrandSection({super.key, required this.brandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(brandByIdProvider(brandId)).when(
          data: (brand) {
            if (brand == null) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => context.pushNamed('brandDetailScreen',
                  pathParameters: {'slug': brand.slug ?? ''}),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: context.vColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: context.vColors.divider),
                ),
                child: Row(
                  children: [
                    // Minimized Brand Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 42.w,
                        height: 42.w,
                        color: context.vColors.surface,
                        child: CustomImageViewer(
                          path: brand.images?.isNotEmpty == true
                              ? brand.images!.first.url
                              : null,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Brand Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            brand.name ?? 'Brand Name',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: context.vColors.onSurface,
                            ),
                          ),
                          Text(
                            'Explore all products',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: context.vColors.onSurfaceMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: context.vColors.onSurfaceMuted, size: 14.sp),
                  ],
                ),
              ),
            );
          },
          loading: () => Container(
            margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: context.vColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.vColors.divider),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 42.w,
                  height: 42.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: const CustomShimmer.rectangular(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CustomShimmer.rectangular(height: 14, width: 100),
                      SizedBox(height: 6.h),
                      const CustomShimmer.rectangular(height: 10, width: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
  }
}
