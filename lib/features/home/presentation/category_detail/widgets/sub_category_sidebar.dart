import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
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

        final vc = context.vColors;
        return Container(
          width: 76.w,
          decoration: BoxDecoration(
            color: vc.surface,
            border: Border(right: BorderSide(color: vc.divider)),
          ),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: subs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedSubSlug == null;
                return _buildSidebarItem(context, ref, 'All', null, isSelected, null);
              }
              final sub = subs[index - 1];
              final isSelected = selectedSubSlug == sub.slug;
              return _buildSidebarItem(
                context,
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

  Widget _buildSidebarItem(BuildContext context, WidgetRef ref, String title,
      String? slug, bool isSelected, String? imageUrl) {
    final vc = context.vColors;
    return InkWell(
      onTap: () {
        ref
            .read(selectedSubCategorySlugProvider(categorySlug).notifier)
            .state = slug;
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(width: 3.w, color: AppColor.primary),
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null)
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColor.primary.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7.r),
                  child: CustomImageViewer(
                    path: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (slug == null)
              Icon(
                Icons.grid_view_rounded,
                color: isSelected ? AppColor.primary : vc.onSurfaceMuted,
                size: 24.sp,
              ),
            SizedBox(height: 5.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColor.primary : vc.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
