import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

/// A premium, reusable confirmation dialog.
///
/// Usage:
/// ```dart
/// CustomDialog.show(
///   context: context,
///   icon: Icons.logout_outlined,
///   iconColor: AppColor.primary,
///   title: 'Logging Out',
///   message: 'Are you sure you want to log out?',
///   confirmLabel: 'Yes, Logout',
///   confirmColor: AppColor.primary,
///   onConfirm: () async { /* ... */ },
/// );
/// ```
class CustomDialog {
  CustomDialog._();

  static Future<void> show({
    required BuildContext context,

    /// Icon shown in the top circle
    required IconData icon,

    /// Primary tint color — used for the icon and confirm button gradient
    Color? iconColor,

    /// Background tint of the icon circle (defaults to iconColor with 0.08 opacity)
    Color? iconBgColor,

    /// Bold title text
    required String title,

    /// Descriptive body message
    required String message,

    /// Label for the confirm (primary) button
    required String confirmLabel,

    /// Explicit gradient colors for the confirm button.
    /// If null, a gradient from [iconColor] to [iconColor].withOpacity(0.8) is used.
    List<Color>? confirmGradient,

    /// Called when the user taps the confirm button.
    /// The dialog is dismissed before this is called.
    required Future<void> Function() onConfirm,

    /// Label for the cancel button (defaults to 'Cancel')
    String cancelLabel = 'Cancel',

    /// Called when the user taps cancel (dialog dismisses automatically)
    VoidCallback? onCancel,
  }) {
    final effectiveIconColor = iconColor ?? AppColor.primary;
    final effectiveIconBg =
        iconBgColor ?? effectiveIconColor.withValues(alpha: 0.08);
    final effectiveGradient = confirmGradient ??
        [effectiveIconColor, effectiveIconColor.withValues(alpha: 0.8)];

    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        final vc = Theme.of(dialogContext).extension<VhandarColors>() ?? VhandarColors.light;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ──────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: effectiveIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: effectiveIconColor, size: 32.sp),
                ),

                SizedBox(height: 16.h),

                // ── Title ─────────────────────────────────────
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: vc.onSurface,
                  ),
                ),

                SizedBox(height: 10.h),

                // ── Message ───────────────────────────────────
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: vc.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Confirm Button ────────────────────────────
                _DialogButton(
                  label: confirmLabel,
                  gradient: LinearGradient(
                    colors: effectiveGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shadowColor: effectiveIconColor.withValues(alpha: 0.3),
                  textColor: Colors.white,
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await onConfirm();
                  },
                ),

                SizedBox(height: 10.h),

                // ── Cancel Button ─────────────────────────────
                _DialogButton(
                  label: cancelLabel,
                  backgroundColor: vc.surfaceVariant,
                  textColor: vc.onSurface,
                  onTap: () {
                    Navigator.pop(dialogContext);
                    onCancel?.call();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Private button widget ──────────────────────────────────────────────────

class _DialogButton extends StatelessWidget {
  final String label;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final Color? shadowColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    this.gradient,
    this.backgroundColor,
    required this.textColor,
    this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? backgroundColor : null,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: shadowColor != null
                ? [
                    BoxShadow(
                      color: shadowColor!,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
