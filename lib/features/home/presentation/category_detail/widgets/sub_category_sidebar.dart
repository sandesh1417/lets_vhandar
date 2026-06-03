import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

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
                return _SidebarItem(
                  categorySlug: categorySlug,
                  title: 'All',
                  slug: null,
                  isSelected: selectedSubSlug == null,
                  imageUrl: null,
                  description: null,
                );
              }
              final sub = subs[index - 1];
              return _SidebarItem(
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
      loading: () => Container(
        width: 76.w,
        decoration: BoxDecoration(
          color: context.vColors.surface,
          border: Border(right: BorderSide(color: context.vColors.divider)),
        ),
        child: const BrandSidebarShimmer(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SidebarItem extends ConsumerStatefulWidget {
  final String categorySlug;
  final String title;
  final String? slug;
  final bool isSelected;
  final String? imageUrl;
  final String? description;

  const _SidebarItem({
    required this.categorySlug,
    required this.title,
    required this.slug,
    required this.isSelected,
    required this.imageUrl,
    required this.description,
  });

  @override
  ConsumerState<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends ConsumerState<_SidebarItem>
    with TickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;
  late final AnimationController _selectController;
  late final Animation<double> _selectScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _selectScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.96), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 30),
    ]).animate(
        CurvedAnimation(parent: _selectController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_SidebarItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _selectController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _tapController.forward();
    await _tapController.reverse();
    if (mounted) {
      ref
          .read(selectedSubCategorySlugProvider(widget.categorySlug).notifier)
          .state = widget.slug;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 3.w),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColor.primary.withValues(alpha: 0.07)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_tapScale, _selectScale]),
                  builder: (context, child) => Transform.scale(
                    scale: _tapScale.value * _selectScale.value,
                    child: child,
                  ),
                  child: widget.slug == null
                      ? Icon(
                          Icons.grid_view_rounded,
                          color: widget.isSelected
                              ? AppColor.primary
                              : vc.onSurfaceMuted,
                          size: 24.sp,
                        )
                      : Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? vc.surfaceVariant
                                : const Color(0xFFFFF6E6),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: CustomImageViewer(
                              path: widget.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 5.h),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
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
          // Left indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: widget.isSelected ? 3.w : 0,
              decoration: BoxDecoration(color: AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }
}
