import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class HomeFeaturedBrandsList extends ConsumerWidget {
  const HomeFeaturedBrandsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandProvider);

    return brandsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (brands) {
        if (brands.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 106.w,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            physics: const BouncingScrollPhysics(),
            itemCount: brands.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final brand = brands[index];
              final imageUrl = brand.images?.firstOrNull?.url ??
                  brand.images?.firstOrNull?.path;
              return GestureDetector(
                onTap: () => navigateToSlug(context, brand.slug, isBrand: true),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        width: 84.w,
                        height: 84.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColor.primary.withValues(alpha: 0.12),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CustomImageViewer(
                          path: imageUrl,
                          fit: BoxFit.cover,
                          borderRadius: 12.r,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    SizedBox(
                      width: 84.w,
                      child: Text(
                        brand.name ?? '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
