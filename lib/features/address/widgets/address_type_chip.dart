import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

/// Selectable chip for address type (Home / Office / Others).
class AddressTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const AddressTypeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.secondary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: selected ? AppColor.secondary : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16.sp,
                color: selected ? AppColor.secondary : AppColor.textMuted),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? AppColor.secondary : AppColor.textBlack87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
