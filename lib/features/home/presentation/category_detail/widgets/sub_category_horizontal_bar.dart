import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
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
        
        final vc = context.vColors;
        return Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: vc.surfaceVariant,
            border: Border(top: BorderSide(color: vc.divider)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 12.w, right: 70.w),
            itemCount: subs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedSubSlug == null;
                return _buildItem(context, ref, 'All', null, isSelected, null);
              }
              final sub = subs[index - 1];
              final isSelected = selectedSubSlug == sub.slug;
              return _buildItem(
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
      loading: () => const SizedBox.shrink(), // Silent loading for bar
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildItem(BuildContext context, WidgetRef ref, String title, String? slug, bool isSelected, String? imageUrl) {
    final vc = context.vColors;
    return InkWell(
      onTap: () {
        ref.read(selectedSubCategorySlugProvider(categorySlug).notifier).state = slug;
      },
      child: Container(
        width: 75.w,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? vc.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected ? Border.all(color: AppColor.primary.withValues(alpha: 0.3)) : null,
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
              Icon(Icons.grid_view_rounded, color: isSelected ? AppColor.primary : vc.onSurfaceMuted, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
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
