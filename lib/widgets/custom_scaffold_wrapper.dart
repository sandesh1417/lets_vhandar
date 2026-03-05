import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/color_constant.dart';

class CustomScaffoldWrapper extends StatelessWidget {
  final Widget body;
  final double? horizontalPadding;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool isScrollable;
  const CustomScaffoldWrapper({
    super.key,
    required this.body,
    this.appBar,
    this.horizontalPadding,
    this.bottomNavigationBar,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1),
          ),
          child: Container(
            height: 844.h,
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(horizontal: horizontalPadding ?? 16.w),
            child: isScrollable ? SingleChildScrollView(child: body) : body,
          ),
        ),
      ),
    );
  }
}
