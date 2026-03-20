import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class SubCategoryHorizontalBar extends ConsumerWidget {
  final String categorySlug;

  const SubCategoryHorizontalBar({super.key, required this.categorySlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subCategoriesAsync = ref.watch(subCategoriesProvider(categorySlug));
    final selectedSubSlug = ref.watch(selectedSubCategorySlugProvider(categorySlug));

    return subCategoriesAsync.when(
      data: (subs) {
        if (subs.isEmpty) return const SizedBox.shrink();
        
        return Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: subs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedSubSlug == null;
                return _buildItem(ref, 'All', null, isSelected, null);
              }
              final sub = subs[index - 1];
              final isSelected = selectedSubSlug == sub.slug;
              return _buildItem(
                ref,
                sub.name ?? '',
                sub.slug,
                isSelected,
                sub.images?.isNotEmpty == true ? sub.images!.first.url : null,
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(), // Silent loading for bar
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildItem(WidgetRef ref, String title, String? slug, bool isSelected, String? imageUrl) {
    return InkWell(
      onTap: () {
        ref.read(selectedSubCategorySlugProvider(categorySlug).notifier).state = slug;
      },
      child: Container(
        width: 75.w,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected ? Border.all(color: AppColor.primary.withOpacity(0.3)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null)
              CustomImageViewer(
                path: imageUrl,
                height: 28.h,
                width: 28.w,
                fit: BoxFit.contain,
              )
            else if (slug == null)
              Icon(Icons.apps, color: isSelected ? AppColor.primary : Colors.grey, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColor.primary : AppColor.textBlack54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
