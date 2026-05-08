import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

// Soft background tints cycling per category card
const _kCategoryBgColors = [
  Color(0xFFEAF6EE),
  Color(0xFFFFF8E7),
  Color(0xFFEEF2FF),
  Color(0xFFFFF0F0),
  Color(0xFFE8F9F7),
  Color(0xFFF5EEFF),
  Color(0xFFFFF4E6),
  Color(0xFFEFF9FF),
];

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
              childAspectRatio: 0.68,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final bgColor =
                  _kCategoryBgColors[index % _kCategoryBgColors.length];
              return GestureDetector(
                onTap: () => context.push('/category-detail/${category.slug}'),
                child: Column(
                  children: [
                    Container(
                      height: 64.h,
                      width: 64.h,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: CustomImageViewer(
                          path: category.images?.first.url,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      category.name ?? '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textBlack87,
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
