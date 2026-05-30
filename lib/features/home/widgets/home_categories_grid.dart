import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';


class HomeCategoriesGrid extends ConsumerWidget {
  const HomeCategoriesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(homeCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () =>
                    navigateToSlug(context, category.slug, isBrand: false),
                child: Column(
                  children: [
                    Container(
                      height: 76.h,
                      width: 76.h,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? context.vColors.surfaceVariant
                            : const Color(0xFFE7F1ED),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: CustomImageViewer(
                        path: category.images?.first.url,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      category.name ?? '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: context.vColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const GridShimmer(
        crossAxisCount: 4,
        itemCount: 8,
        childAspectRatio: 0.68,
        isCircle: false,
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
