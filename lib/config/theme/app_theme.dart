import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/config/theme/color_schemes.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // fontFamily: GoogleFonts.rubik().fontFamily,
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: AppColors.lightColorScheme,
    fontFamily: "Inter",
    // scaffoldBackgroundColor: ,

    textTheme: TextTheme(
      // displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(
          fontSize: 24.sp, color: Colors.black87, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          fontSize: 20.sp, color: Colors.black87, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
          fontSize: 16.sp, color: Colors.black87, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontSize: 16.sp, color: Colors.black87),
      labelMedium: TextStyle(fontSize: 14.sp, color: Colors.black87),
      labelSmall: TextStyle(fontSize: 12.sp, color: Colors.black87),
    ),
// appBarTheme: const AppBarTheme(
// iconTheme: IconThemeData(color: Colors.white),
// ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Inter',
    colorSchemeSeed: AppColor.primary,
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(
          fontSize: 24.sp, color: Colors.white, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
          fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontSize: 16.sp, color: Colors.white),
      labelMedium: TextStyle(fontSize: 14.sp, color: Colors.white),
      labelSmall: TextStyle(fontSize: 12.sp, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 18.sp, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14.sp, color: Colors.white70),
      bodySmall: TextStyle(fontSize: 12.sp, color: Colors.white60),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.primary,
      iconTheme: IconThemeData(color: AppColor.white),
    ),
    colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primary,
        secondary: AppColor.secondary,
        brightness: Brightness.dark),
  );
}
