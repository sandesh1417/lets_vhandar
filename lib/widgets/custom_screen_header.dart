import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class CustomScreenHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final bool showBackButton;

  const CustomScreenHeader({
    super.key,
    required this.title,
    this.trailing,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      titleSpacing: 16.w,
      title: Row(
        children: [
          if (showBackButton)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColor.primary,
                  size: 24.sp,
                ),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
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
