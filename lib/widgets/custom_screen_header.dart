import 'package:flutter/material.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
