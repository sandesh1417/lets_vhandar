import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

/// Selectable chip for address type (Home / Office / Others).
class AddressTypeChip extends StatelessWidget {
  final String label;
  final String svgAsset;
  final bool selected;
  final VoidCallback onTap;

  const AddressTypeChip({
    super.key,
    required this.label,
    required this.svgAsset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.secondary.withValues(alpha: 0.12)
              : context.vColors.surface,
          border: Border.all(
            color: selected ? AppColor.secondary : context.vColors.divider,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 22.w,
              height: 22.w,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color:
                    selected ? AppColor.secondary : context.vColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
