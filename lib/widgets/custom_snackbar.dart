import 'package:flutter/material.dart';

import '../core/constants/color_constant.dart';

showCustomSnackBar(BuildContext context,
    {required String msg, bool isWhite = true}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: isWhite ? AppColor.bg : AppColor.white),
        ),
        backgroundColor:
            isWhite == true ? AppColor.white.withOpacity(0.7) : AppColor.bg,
        width: MediaQuery.of(context).size.width / 1.4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
}

snackBarWithoutContext({required String msg, bool taskSuccess = true}) {
  return SnackBar(
    content: Text(
      msg,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    backgroundColor:
        taskSuccess == true ? AppColor.bg : Colors.red.withOpacity(0.7),
    // width: MediaQuery.of(context).size.width / 1.4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(milliseconds: 1500),
  );
}
