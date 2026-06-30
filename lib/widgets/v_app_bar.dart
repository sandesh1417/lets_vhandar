import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

/// Shared brand app bar: green background, 44×44 back button (with light haptic),
/// and a bold white title. Use this instead of hand-rolling the same AppBar in
/// each screen.
class VAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  /// Optional override for the back action. Defaults to `context.pop()`.
  final VoidCallback? onBack;

  const VAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primary,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      scrolledUnderElevation: 2,
      automaticallyImplyLeading: false,
      titleSpacing: 16.w,
      title: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              if (onBack != null) {
                onBack!();
              } else {
                context.pop();
              }
            },
            child: Container(
              width: 44.w,
              height: 44.h,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}
