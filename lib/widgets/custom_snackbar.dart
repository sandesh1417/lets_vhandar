// import 'package:flutter/material.dart';

// import '../core/constants/color_constant.dart';

// showCustomSnackBar(BuildContext context, {required String msg, bool isWhite = true}) {
//   ScaffoldMessenger.of(context)
//     ..clearSnackBars()
//     ..showSnackBar(
//       SnackBar(
//         content: Text(
//           msg,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(color: isWhite ? AppColor.bg : AppColor.white),
//         ),
//         backgroundColor: isWhite == true ? AppColor.white.withOpacity(0.7) : AppColor.bg,
//         width: MediaQuery.of(context).size.width / 1.4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(milliseconds: 1500),
//       ),
//     );
// }

// snackBarWithoutContext({required String msg, bool taskSuccess = true}) {
//   return SnackBar(
//     content: Text(
//       msg,
//       textAlign: TextAlign.center,
//       maxLines: 2,
//       overflow: TextOverflow.ellipsis,
//     ),
//     backgroundColor: taskSuccess == true ? AppColor.bg : Colors.red.withOpacity(0.7),
//     // width: MediaQuery.of(context).size.width / 1.4,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     behavior: SnackBarBehavior.floating,
//     duration: const Duration(milliseconds: 1500),
//   );
// }

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class CustomSnackbar {
  /// Shows a premium-looking SnackBar with animation, blur effect and optional icon
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
    bool isSuccess = true,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    const isDarkMode = false;

    // Dismiss any existing SnackBars
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 10),
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        icon,
                        color: isSuccess
                            ? isDarkMode
                                ? Colors.greenAccent
                                : AppColor.white
                            : isDarkMode
                                ? Colors.redAccent
                                : Colors.red,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // color: isDarkMode ? Colors.white : Colors.black87,
                          color: isDarkMode ? Colors.white : AppColor.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: isDarkMode ? Colors.grey[850]!.withOpacity(0.85) : AppColor.primary.withOpacity(0.8),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1,
        vertical: 16,
      ),
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a success message with appropriate styling and icon
  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      isSuccess: true,
      icon: Icons.check_circle_outline,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Shows an error message with appropriate styling and icon
  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      isSuccess: false,
      icon: Icons.error_outline,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Shows an info message with appropriate styling and icon
  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      isSuccess: true,
      icon: Icons.info_outline,
      duration: duration,
      onTap: onTap,
    );
  }
}
