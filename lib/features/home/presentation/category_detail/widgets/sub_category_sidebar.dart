import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class SubCategorySidebar extends ConsumerWidget {
  final String categorySlug;

  const SubCategorySidebar({super.key, required this.categorySlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subCategoriesAsync = ref.watch(subCategoriesProvider(categorySlug));
    final selectedSubSlug =
        ref.watch(selectedSubCategorySlugProvider(categorySlug));

    return subCategoriesAsync.when(
      data: (subs) {
        if (subs.isEmpty) return const SizedBox.shrink();

        return Container(
          width: 85.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            itemCount: subs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedSubSlug == null;
                return _buildSidebarItem(ref, 'All', null, isSelected, null);
              }
              final sub = subs[index - 1];
              final isSelected = selectedSubSlug == sub.slug;
              return _buildSidebarItem(
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
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSidebarItem(WidgetRef ref, String title, String? slug,
      bool isSelected, String? imageUrl) {
    return InkWell(
      onTap: () {
        ref.read(selectedSubCategorySlugProvider(categorySlug).notifier).state =
            slug;
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? Border(left: BorderSide(color: AppColor.primary, width: 3.w))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null)
              CustomImageViewer(
                path: imageUrl,
                height: 32.h,
                width: 32.w,
                fit: BoxFit.contain,
              )
            else if (slug == null)
              Icon(Icons.apps,
                  color: isSelected ? AppColor.primary : Colors.grey,
                  size: 26.sp),
            SizedBox(height: 6.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
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
