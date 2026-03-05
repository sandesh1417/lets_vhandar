import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const HomeSectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              title,
              style: KTextStyle.roboto16black5W
                  .copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text('See All', style: TextStyle(color: AppColor.primary)),
          ),
        ],
      ),
    );
  }
}
