import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // fontFamily: GoogleFonts.rubik().fontFamily,
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff80DEEA)),
    primaryColor: AppColor.primary,

    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 24.sp, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 18.sp, color: Colors.black87),
      bodySmall: TextStyle(fontSize: 12.sp, color: Colors.black87),
    ),
// appBarTheme: const AppBarTheme(
// iconTheme: IconThemeData(color: Colors.white),
// ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: AppColor.primary,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
    ),
    appBarTheme: AppBarTheme(
      color: AppColor.primary,
      iconTheme: IconThemeData(color: AppColor.white),
      backgroundColor: AppColor.bg,
    ),
    colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primary, secondary: AppColor.secondary),
  );
}
