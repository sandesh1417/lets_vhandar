import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/widgets/social_media_row.dart';

class AccountVersionFooter extends StatelessWidget {
  final String version;

  const AccountVersionFooter({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          const SocialMediaRow(),
          SizedBox(height: 20.h),
          SvgPicture.asset(
            'assets/icons/vhandar-white-logo.svg',
            width: 110.w,
            colorFilter: const ColorFilter.mode(
              Color(0xFFB0B8B4),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Version $version',
            style: TextStyle(
              color: AppColor.textMuted,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
