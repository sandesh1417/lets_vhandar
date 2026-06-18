import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/widgets/loader.dart';

import '../core/constants/app_style.dart';
import '../core/constants/color_constant.dart';

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
      color: AppColor.white02,
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
      disabledColor: AppColor.primary.withValues(alpha: 0.3),
      color: buttonColor ?? AppColor.white03,
      minWidth: btnWidth ?? double.infinity,
      height: btnHeight ?? 45.h,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColor.primary),
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
      ),
      splashColor: AppColor.primary.withValues(alpha: 0.5),
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
            context.pop();
            // navigatePop(context);
          }),
    );
  }
}

/// Single source of truth for the app's elevated button.
///
/// Defaults to [AppColor.primary] / white text, but every visual aspect
/// (background, foreground/text color, border radius, padding, size,
/// elevation, loader) can be overridden per call site. Pass
/// `backgroundColor: AppColor.secondary` (and a matching [foregroundColor])
/// to get the secondary variant instead of adding a separate widget.
class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;
  final IconData? icon;
  final double? iconSize;
  final double iconSpacing;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? foregroundColor;
  final Color? loaderColor;
  final double? loaderSize;
  final double borderRadius;
  final BorderSide? side;
  final double elevation;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.icon,
    this.iconSize,
    this.iconSpacing = 8,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.foregroundColor,
    this.loaderColor,
    this.loaderSize,
    this.borderRadius = 10,
    this.side,
    this.elevation = 0,
    this.width,
    this.height,
    this.padding,
    this.textStyle,
  }) : assert(
            text != null || child != null, 'Provide either `text` or `child`');

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColor.primary;
    final fgColor = foregroundColor ?? AppColor.white;

    final Widget content = isLoading
        ? Center(
            child: CupertinoActivityIndicator(
              color: loaderColor ?? fgColor,
              radius: loaderSize != null ? loaderSize! / 2 : 10,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize ?? 18.sp, color: fgColor),
                SizedBox(width: iconSpacing.w),
              ],
              child ??
                  Text(
                    text!,
                    style: textStyle ??
                        KTextStyle.roboto16white7W.copyWith(color: fgColor),
                  ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          // While loading the button is disabled, so keep (almost) the real
          // color — only a 10% dim. A genuinely disabled button fades more.
          disabledBackgroundColor: disabledBackgroundColor ??
              (isLoading
                  ? bgColor.withValues(alpha: 0.9)
                  : bgColor.withValues(alpha: 0.4)),
          foregroundColor: fgColor,
          elevation: elevation,
          padding:
              padding ?? EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
            side: side ?? BorderSide.none,
          ),
        ),
        child: content,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? foregroundColor;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16.sp),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: color ?? AppColor.secondary,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
