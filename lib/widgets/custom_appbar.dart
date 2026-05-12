import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vhandar/core/constants/color_constant.dart';

import '../core/constants/app_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool? isTitleCenter;
  final bool hideBackBtn;
  final void Function()? backBtnFx;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final double? titleSpacing;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.backBtnFx,
    this.hideBackBtn = false,
    this.isTitleCenter = false,
    this.actions,
    this.leading,
    this.elevation,
    this.backgroundColor,
    this.titleStyle,
    this.titleSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColor.white,
      elevation: elevation ?? 2,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: titleSpacing ?? (hideBackBtn ? 16.w : 0),
      automaticallyImplyLeading: !hideBackBtn,
      title: titleWidget ??
          (title == null
              ? const SizedBox()
              : Text(
                  title!,
                  style: titleStyle ?? KTextStyle.roboto20pri7W,
                )),
      leadingWidth: hideBackBtn ? 0 : 50.w,
      leading: hideBackBtn
          ? null
          : leading ??
              InkWell(
                radius: 10.r,
                borderRadius: BorderRadius.circular(100),
                onTap: backBtnFx ??
                    () {
                      context.pop();
                    },
                child: Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColor.black,
                  ),
                ),
              ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50.h);
}
