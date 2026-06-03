import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class CustomScreenHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomScreenHeader({
    super.key,
    required this.title,
    this.trailing,
    this.showBackButton = true,
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
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleSpacing: 16.w,
      title: Row(
        children: [
          if (showBackButton)
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
                margin: EdgeInsets.only(right: 4.w),
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
      actions: trailing != null
          ? [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Center(child: trailing!),
              ),
            ]
          : null,
    );
  }
}
