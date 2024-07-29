import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/color_constant.dart';

class CustomScaffoldWrapper extends StatelessWidget {
  final Widget child;
  final double? horizontalPadding;
  final PreferredSizeWidget? appBar;
  const CustomScaffoldWrapper(
      {super.key, required this.child, this.appBar, this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: appBar,
      body: SafeArea(
        child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // textScaler: const TextScaler.linear(0.4),
              textScaler: const TextScaler.linear(1),
            ),
            child: Container(
                height: 844.h,
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPadding ?? 24.w),
                child: child)),
      ),
    );
  }
}
