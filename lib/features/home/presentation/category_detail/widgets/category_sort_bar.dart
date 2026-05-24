import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';

class CategorySortBar extends ConsumerWidget {
  final String categorySlug;

  const CategorySortBar({super.key, required this.categorySlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = context.vColors;
    final currentSort = ref.watch(selectedSortProvider(categorySlug));
    const sortLabels = {
      'relevance': 'Relevance',
      'price_low_high': 'Price (Low to High)',
      'price_high_low': 'Price (High to Low)',
      'discount_high_low': 'Discount (High to Low)',
      'discount_low_high': 'Discount (Low to High)',
      'name_a_z': 'Name (A to Z)',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: vc.surface,
        border: Border(bottom: BorderSide(color: vc.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Sort By', style: TextStyle(fontSize: 11.sp, color: vc.onSurfaceMuted)),
          SizedBox(width: 6.w),
          InkWell(
            onTap: () => _showSortModal(context, ref),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                border: Border.all(color: vc.inputBorder),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sortLabels[currentSort] ?? 'Relevance',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down, size: 14.sp, color: AppColor.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortModal(BuildContext context, WidgetRef ref) =>
      CategorySortBar.showSortModal(context, ref, categorySlug);

  static void showSortModal(
      BuildContext context, WidgetRef ref, String categorySlug) {
    final options = [
      {'val': 'relevance', 'label': 'Relevance'},
      {'val': 'price_low_high', 'label': 'Price (Low to High)'},
      {'val': 'price_high_low', 'label': 'Price (High to Low)'},
      {'val': 'discount_high_low', 'label': 'Discount (High to Low)'},
      {'val': 'discount_low_high', 'label': 'Discount (Low to High)'},
      {'val': 'name_a_z', 'label': 'Name (A to Z)'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        final vc = context.vColors;
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: vc.divider,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Text(
                    'Sort By',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: vc.onSurface),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final vc = context.vColors;
                      final currentSort = ref.watch(selectedSortProvider(categorySlug));
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          final isSelected = currentSort == opt['val'];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              opt['label']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColor.primary : vc.onSurface,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: AppColor.primary)
                                : Icon(Icons.radio_button_unchecked, color: vc.onSurfaceMuted),
                            onTap: () {
                              ref.read(selectedSortProvider(categorySlug).notifier).state = opt['val'];
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (context.mounted) Navigator.pop(context);
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
