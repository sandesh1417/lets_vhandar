// import 'package:flutter/material.dart';

// const lightThemeColorScheme = ColorScheme(
//   brightness: Brightness.light,
//   // background:Color(0xFFFBFBFB) ,
//   // onBackground: Color(0xFF1D1D1D),

// // Primary Color
//   primary: Color(0xFF0A754E),
//   onPrimary: Color(0xFFFFFFFF),
//   primaryContainer: Color(0xFFFFDAD4),
//   onPrimaryContainer: Color(0xFF410000),
//   primaryFixed: Color(0xFFFFDAD4),
//   onPrimaryFixed: Color(0xFF410000),
//   primaryFixedDim: Color(0xFFFFB4A8),
//   onPrimaryFixedVariant: Color(0xFF930000),

// // Secondary Color
//   secondary: Color(0xFFF5B237),
//   onSecondary: Color(0xFFFFFFFF),
//   secondaryContainer: Color(0xFF5EFBDC),
//   onSecondaryContainer: Color(0xFF00201A),
//   secondaryFixed: Color(0xFF5EFBDC),
//   onSecondaryFixed: Color(0xFF00201A),
//   secondaryFixedDim: Color(0xFF36DEC0),
//   onSecondaryFixedVariant: Color(0xFF005144),

//   // Tertiary Color
//   tertiary: Color(0xFF715B2E),
//   onTertiary: Color(0xFFFFFFFF),
//   tertiaryContainer: Color(0xFFFEDFA6),
//   onTertiaryContainer: Color(0xFF261900),
//   tertiaryFixed: Color(0xFFFEDFA6),
//   onTertiaryFixed: Color(0xFF261900),
//   tertiaryFixedDim: Color(0xFFE0C38C),
//   onTertiaryFixedVariant: Color(0xFF584419),

//   // Error Color
//   error: Color(0xFFBC004C),
//   errorContainer: Color(0xFFFFD9DE),
//   onError: Color(0xFFFFFFFF),
//   onErrorContainer: Color(0xFF3B0716),

//   // Surface Color
//   surface: Color(0xFFF8FAFA),
//   onSurface: Color(0xFF171D1E),
//   onSurfaceVariant: Color(0xFF8C9A95),//hint color
//   surfaceTint: Color(0xFFC00000),
//   surfaceDim: Color(0xFFD8DADB),
//   surfaceBright: Color(0xFFF8FAFA),
//   surfaceContainerLowest: Color(0xFFFFFFFF),
//   surfaceContainerLow: Color(0xFFEFF5F6),
//   surfaceContainer: Color(0xFFECEEEF),
//   // surfaceContainerHigh: Color(0xFFE6E8E9),
//   surfaceContainerHigh: Color(0xFFE3E9EA),
//   surfaceContainerHighest: Color(0xFFE1E3E3),

//   // Other Color
//   outline: Color(0xFFD9DDDC), //border
//   outlineVariant: Color(0xFFBFC8CA),
//   shadow: Color(0xFF000000),
//   onInverseSurface: Color(0xFFEFF1F1),
//   inverseSurface: Color(0xFF2E3132),
//   inversePrimary: Color(0xFFFFB4A8),

//   scrim: Color(0xFF000000),
// );

// //DARK COLOR SCHEME=================================

// const darkThemeColorScheme = ColorScheme(
//   brightness: Brightness.dark,

// // Primary Color
//   primary: Color(0xFFFFB4A8),
//   onPrimary: Color(0xFF690000),
//   primaryContainer: Color(0xFF930000),
//   onPrimaryContainer: Color(0xFFFFDAD4),
//   primaryFixed: Color(0xFFFFDAD4),
//   onPrimaryFixed: Color(0xFF410000),
//   primaryFixedDim: Color(0xFFFFB4A8),
//   onPrimaryFixedVariant: Color(0xFF930000),

// // Secondary Color
//   secondary: Color(0xFF36DEC0),
//   onSecondary: Color(0xFF00382E),
//   secondaryContainer: Color(0xFF005144),
//   onSecondaryContainer: Color(0xFF5EFBDC),
//   secondaryFixed: Color(0xFF5EFBDC),
//   onSecondaryFixed: Color(0xFF00201A),
//   secondaryFixedDim: Color(0xFF36DEC0),
//   onSecondaryFixedVariant: Color(0xFF005144),

//   // Tertiary Color
//   tertiary: Color(0xFF8ADB62),
//   onTertiary: Color(0xFF113800),
//   tertiaryContainer: Color(0xFF1C5200),
//   onTertiaryContainer: Color(0xFFA5F87B),
//   tertiaryFixed: Color(0xFFA5F87B),
//   onTertiaryFixed: Color(0xFF072100),
//   tertiaryFixedDim: Color(0xFF8ADB62),
//   onTertiaryFixedVariant: Color(0xFF1C5200),

//   // Error Color
//   error: Color(0xFFFFB3AD),
//   errorContainer: Color(0xFF930011),
//   onError: Color(0xFF680009),
//   onErrorContainer: Color(0xFFFFDAD6),

//   // Surface Color
//   surface: Color(0xFF101415),
//   onSurface: Color(0xFFE1E3E3),
//   onSurfaceVariant: Color(0xFFBFC8CA),
//   surfaceTint: Color(0xFFFFB4A8),
//   surfaceDim: Color(0xFF101415),
//   surfaceBright: Color(0xFF363A3A),
//   surfaceContainerLowest: Color(0xFF0B0F0F),
//   surfaceContainerLow: Color(0xFF191C1D),
//   surfaceContainer: Color(0xFF1D2021),
//   surfaceContainerHigh: Color(0xFF272B2B),
//   surfaceContainerHighest: Color(0xFF323536),

//   // Other Color
//   outline: Color(0xFF899294),
//   outlineVariant: Color(0xFF3F484A),
//   shadow: Color(0xFF000000),
//   onInverseSurface: Color(0xFF191C1D),
//   inverseSurface: Color(0xFFE1E3E3),
//   inversePrimary: Color(0xFFC00000),
//   scrim: Color(0xFF000000),
// );

import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const ColorScheme lightColorScheme = ColorScheme.light(
      primary: Color(0xFF0A754E),
      secondary: Color(0xFFF5B237),
      tertiary: Color(0xFFCF6679),
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Color(0xFF8C9A95), //hintText
      outline: Color(0xFFD9DDDC), //border
      onPrimaryContainer: Color(0xFF455B53), //icon
      onSecondaryFixedVariant: Color(0xFF696969), //lGreyText
      surfaceDim: Colors.white70, //white03
      secondaryFixedDim: Colors.white30 //white07
      );
  // Dark Theme Colors
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF264136),
    secondary: Colors.amberAccent,
    tertiary: Color(0xFFB00020),
    surface: Color(0xFF2F3541),
    onSurface: Colors.white,
  );
  static const Color greenTxt = Color(0xFF264136); // Can be used for consistent green text

  static Color primary(BuildContext context) => Theme.of(context).colorScheme.primary; // Dynamic based on theme
}
