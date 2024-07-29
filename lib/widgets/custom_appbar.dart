import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/utils/navigator_services.dart';

import '../core/constants/app_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool hideBackBtn;
  final void Function()? backBtnFx;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backBtnFx,
    this.hideBackBtn = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: KTextStyle.roboto16white7W,
        ),
        leading: hideBackBtn
            ? const SizedBox()
            : InkWell(
                radius: 10.r,
                borderRadius: BorderRadius.circular(100),
                onTap: backBtnFx ??
                    () {
                      navigatePop(context);
                    },
                child: Padding(
                  padding: EdgeInsets.only(left: 24.w),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppColor.white,
                  ),
                ),
              ));
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);
}
