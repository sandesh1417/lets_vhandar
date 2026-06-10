import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';

class SubCategoryHorizontalBar extends ConsumerWidget {
  final String categorySlug;

  const SubCategoryHorizontalBar({super.key, required this.categorySlug});

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
                return _HorizontalTabItem(
                  categorySlug: categorySlug,
                  title: 'All',
                  slug: null,
                  isSelected: selectedSubSlug == null,
                  imageUrl: null,
                  description: null,
                );
              }
              final sub = subs[index - 1];
              return _HorizontalTabItem(
                categorySlug: categorySlug,
                title: sub.name ?? '',
                slug: sub.slug,
                isSelected: selectedSubSlug == sub.slug,
                imageUrl: sub.images?.isNotEmpty == true
                    ? sub.images!.first.url
                    : null,
                description: sub.description,
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HorizontalTabItem extends ConsumerStatefulWidget {
  final String categorySlug;
  final String title;
  final String? slug;
  final bool isSelected;
  final String? imageUrl;
  final String? description;

  const _HorizontalTabItem({
    required this.categorySlug,
    required this.title,
    required this.slug,
    required this.isSelected,
    required this.imageUrl,
    required this.description,
  });

  @override
  ConsumerState<_HorizontalTabItem> createState() =>
      _HorizontalTabItemState();
}

class _HorizontalTabItemState extends ConsumerState<_HorizontalTabItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    if (mounted) {
      ref
          .read(selectedSubCategorySlugProvider(widget.categorySlug).notifier)
          .state = widget.slug;
    }
  }

  void _showInfoSheet(BuildContext context) {
    final desc = _stripHtml(widget.description);
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final vc = ctx.vColors;
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                        color: vc.divider,
                        borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                if (widget.imageUrl != null) ...[
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: ctx.isDark
                          ? vc.surfaceVariant
                          : const Color(0xFFFFF6E6),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: CustomImageViewer(
                        path: widget.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                Text(
                  'Subcategory',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    color: vc.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (desc.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Divider(color: vc.divider),
                  SizedBox(height: 12.h),
                  Text(
                    desc,
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: vc.onSurfaceMuted,
                        height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  SizedBox(height: 8.h),
                  Text(
                    'No description available.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: vc.onSurfaceMuted.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  String _stripHtml(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final hasDesc = widget.slug != null;

    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: 75.w,
            margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: widget.isSelected ? vc.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: widget.isSelected
                  ? Border.all(
                      color: AppColor.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _scale,
                  builder: (context, child) =>
                      Transform.scale(scale: _scale.value, child: child),
                  child: widget.imageUrl != null
                      ? Container(
                          width: 28.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? vc.surfaceVariant
                                : const Color(0xFFFFF6E6),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: CustomImageViewer(
                              path: widget.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : widget.slug == null
                          ? Icon(
                              Icons.grid_view_rounded,
                              color: widget.isSelected
                                  ? AppColor.primary
                                  : vc.onSurfaceMuted,
                              size: 24.sp,
                            )
                          : const SizedBox.shrink(),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: widget.isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? AppColor.primary
                        : vc.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          // Info icon badge — top-right corner of selected items
          if (widget.isSelected && hasDesc)
            Positioned(
              top: 6.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => _showInfoSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: vc.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 12.sp,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
