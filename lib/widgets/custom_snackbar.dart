import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vhandar/core/constants/color_constant.dart';

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? onTap,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
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
      backgroundColor: backgroundColor,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1,
        vertical: 16,
      ),
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void success(BuildContext context,
      {required String message,
      Duration duration = const Duration(milliseconds: 3000)}) {
    show(
      context,
      message: message,
      backgroundColor: AppColor.primary.withOpacity(0.8),
      icon: Icons.check_circle_outline_outlined,
      duration: duration,
    );
  }

  static void error(BuildContext context,
      {required String message,
      Duration duration = const Duration(milliseconds: 3000)}) {
    show(
      context,
      message: message,
      backgroundColor: Colors.red.withOpacity(0.7),
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  static void info(BuildContext context,
      {required String message,
      Duration duration = const Duration(milliseconds: 3000)}) {
    show(
      context,
      message: message,
      backgroundColor: AppColor.primary.withOpacity(0.8),
      icon: Icons.info_outline,
      duration: duration,
    );
  }
}
