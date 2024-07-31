import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/widgets/loader.dart';

import '../core/constants/app_style.dart';
import '../core/constants/color_constant.dart';
import '../core/utils/navigator_services.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPress;
  final double? borderRadius;
  final String buttonTitle;
  final bool? isLoading;
  final bool? isEnabled;
  final Color? buttonColor;
  final double? btnWidth;
  final double? btnHeight;
  final TextStyle? txtStyle;

  const CustomButton({
    super.key,
    required this.onPress,
    this.borderRadius,
    required this.buttonTitle,
    this.isLoading = false,
    this.buttonColor,
    this.btnWidth,
    this.btnHeight,
    this.txtStyle,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: isEnabled ?? true ? onPress : null,
      disabledColor: AppColor.primary.withOpacity(0.3),
      color: buttonColor ?? AppColor.secondary,
      minWidth: btnWidth ?? double.infinity,
      height: btnHeight ?? 45.h,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
      ),
      splashColor: AppColor.primary.withOpacity(0.5),
      child: !(isLoading ?? false)
          ? Text(
              buttonTitle,
              style: txtStyle ?? KTextStyle.roboto16white7W,
            )
          : const CircularLoader(),
    );
  }
}

class CustomCardBtn extends StatelessWidget {
  final void Function()? onPress;
  final String buttonTitle;
  final TextStyle? textStyle;
  const CustomCardBtn(
      {super.key,
      required this.buttonTitle,
      required this.onPress,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(10.r),
      color: AppColor.btn,
      child: InkWell(
        onTap: onPress,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(
              top: 12.h,
              bottom: 12.h,
              left: 24.w,
            ),
            child: Text(
              buttonTitle,
              style: textStyle ??
                  KTextStyle.roboto14white4W.copyWith(color: AppColor.white),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButtonOutline extends StatelessWidget {
  final Function()? onPress;
  final double? borderRadius;
  final String buttonTitle;
  final bool? isLoading;
  final bool? isEnabled;
  final Color? buttonColor;
  final double? btnWidth;
  final double? btnHeight;
  final TextStyle? txtStyle;

  const CustomButtonOutline({
    super.key,
    required this.onPress,
    this.borderRadius,
    required this.buttonTitle,
    this.isLoading = false,
    this.buttonColor,
    this.btnWidth,
    this.btnHeight,
    this.txtStyle,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: isEnabled ?? true ? onPress : null,
      disabledColor: AppColor.primary.withOpacity(0.3),
      color: buttonColor ?? AppColor.white03,
      minWidth: btnWidth ?? double.infinity,
      height: btnHeight ?? 45.h,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColor.primary),
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
      ),
      splashColor: AppColor.primary.withOpacity(0.5),
      child: !isLoading!
          ? Text(
              buttonTitle,
              style: txtStyle ??
                  KTextStyle.roboto14white5W.copyWith(color: Colors.white),
            )
          : SizedBox(
              width: btnWidth ?? double.infinity,
              child: const CircularLoader()),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
          splashRadius: 10,
          padding: const EdgeInsets.only(top: 5),
          icon: Icon(
            Icons.arrow_back_outlined,
            color: AppColor.white07,
            size: 24.w,
          ),
          onPressed: () {
            navigatePop(context);
          }),
    );
  }
}
