import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/widgets/loader.dart';

import '../core/constants/app_style.dart';
import '../core/constants/color_constant.dart';
import 'shimmer_button_effect.dart';

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
/// Defaults to [AppColor.primary] / white text. Text color auto-picks a
/// brand-correct value from [backgroundColor] (see [_defaultForeground]) —
/// pass `backgroundColor: AppColor.secondary` for the secondary variant
/// without needing to also specify [foregroundColor]; only pass it for a
/// genuinely one-off color that the default rule shouldn't apply to.
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

  /// Runs the idle diagonal shimmer sweep when the button is interactive.
  /// Set `false` to opt a specific button out of the effect.
  final bool enableShimmer;

  /// Idle sweep timing — how long one light sweep takes to cross the button.
  /// Lower = faster. Defaults to [kShimmerSweepDuration].
  final Duration shimmerSweepDuration;

  /// Idle sweep timing — the pause between two sweeps.
  /// Lower = the shimmer repeats more often. Defaults to [kShimmerPauseDuration].
  final Duration shimmerPauseDuration;

  /// Fires a light tap haptic on press. Turn off for buttons that already
  /// drive their own haptic pattern (e.g. kids-zone games, or call sites
  /// that fire a distinct success/error pulse before this would).
  final bool enableHaptic;

  /// Loading sweep timing — speed of the continuous shimmer while [isLoading].
  /// Lower = faster, busier "processing" feel. Defaults to [kLoadingShimmerDuration].
  final Duration loadingShimmerDuration;

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
    this.enableShimmer = true,
    this.shimmerSweepDuration = kShimmerSweepDuration,
    this.shimmerPauseDuration = kShimmerPauseDuration,
    this.loadingShimmerDuration = kLoadingShimmerDuration,
    this.enableHaptic = true,
  }) : assert(
            text != null || child != null, 'Provide either `text` or `child`');

  /// Brand-consistent text color for a given button background, used
  /// whenever a call site doesn't pass an explicit [foregroundColor]. Keeps
  /// every button's text legible/on-brand without each screen having to
  /// remember the right pairing (secondary orange needs dark text, not the
  /// white that was scattered across a few screens with poor contrast).
  static Color _defaultForeground(Color bg) {
    if (bg == AppColor.secondary) return const Color(0xFF392500);
    if (bg.computeLuminance() > 0.6) return AppColor.primary;
    return AppColor.white;
  }

  @override
  Widget build(BuildContext context) {
    // TEMP / DEBUG: force every button into the loading state so the loading
    // shimmer can be reviewed everywhere. Remove this line (or set it back to
    // `this.isLoading`) before shipping.
    // final bool isLoading = true; // this.isLoading;

    final bgColor = backgroundColor ?? AppColor.primary;
    final fgColor = foregroundColor ?? _defaultForeground(bgColor);
    final radius = BorderRadius.circular(borderRadius.r);
    final effectivePadding =
        padding ?? EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w);

    final bool disabled = !isEnabled || isLoading;

    // The label/icon — identical content to before. While loading it is kept
    // (transparent) in the tree so the button preserves its exact dimensions.
    final Widget label = Row(
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

    // Background, shape, elevation, splash and tap handling — unchanged. The
    // visible content is layered on top via the Stack, so this button's own
    // padding is zeroed here and re-applied to the content sizer below; the
    // resulting overall size is identical to the original.
    final Widget background = ElevatedButton(
      onPressed: disabled
          ? null
          : (enableHaptic
              ? () {
                  AppHaptics.light();
                  onPressed?.call();
                }
              : onPressed),
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
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: side ?? BorderSide.none,
        ),
      ),
      child: const SizedBox.shrink(),
    );

    final bool showIdleShimmer = enableShimmer && isEnabled && !isLoading;

    final Widget stack = Stack(
      alignment: Alignment.center,
      children: [
        // Invisible sizer that reproduces ElevatedButton's default minimum
        // (64×48 padded tap target) which the Positioned.fill background no
        // longer contributes. Outer SizedBox width/height still override it.
        const SizedBox(width: 64, height: 48),

        // Bottom: background + shape + ink. Fills the content-defined size.
        Positioned.fill(child: background),

        // Middle: loading skeleton shimmer (covers the full button surface).
        if (isLoading)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: radius,
                child: LoadingShimmerContent(
                  baseColor: bgColor,
                  // Loader is white by default (reads on the coloured button);
                  // pass `loaderColor` to override.
                  spinnerColor: loaderColor ?? AppColor.white,
                  spinnerRadius: loaderSize != null ? loaderSize! / 2 : null,
                  sweepDuration: loadingShimmerDuration,
                ),
              ),
            ),
          ),

        // Middle: idle attention sweep — above the background, below the label,
        // clipped strictly to the button's border radius.
        if (showIdleShimmer)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: radius,
                child: ShimmerSweepOverlay(
                  sweepDuration: shimmerSweepDuration,
                  pauseDuration: shimmerPauseDuration,
                ),
              ),
            ),
          ),

        // Top + size source: the label. Non-positioned, so it defines the
        // Stack's intrinsic size (label + padding) exactly as before. Hidden
        // while loading but still measured to hold the button's dimensions.
        IgnorePointer(
          child: Opacity(
            opacity: isLoading ? 0.0 : 1.0,
            child: Padding(
              padding: effectivePadding,
              child: label,
            ),
          ),
        ),
      ],
    );

    return PressScale(
      enabled: !disabled,
      child: SizedBox(
        width: width,
        height: height,
        child: stack,
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
