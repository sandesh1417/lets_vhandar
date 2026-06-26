import 'package:flutter/material.dart';

class AppColor {
  static Color primary = const Color(0xFF0A754E);
  static Color secondary = const Color(0xFFF5B237);

  // Brand green gradient for cart buttons/steppers — a brighter green up top
  // fading into a deeper green, giving the controls a glossy, lively look.
  static const Color gradientStart = Color(0xFF16A86A);
  static const Color gradientEnd = Color(0xFF065C3C);
  static const List<Color> primaryGradient = [gradientStart, gradientEnd];

  static Color white = const Color(0xFFFFFFFF);
  static Color black = Colors.black;
  static Color hintText = const Color(0xFF8C9A95);
  static Color lgrayTxt = const Color(0xFF696969);
  static Color error = const Color(0xFFCF6679);
  static Color greenTxtColor = const Color(0xFF1F3A2F);

  // Semi-transparent whites (used for overlays/glass effects)
  static Color white07 = Colors.white.withValues(alpha: 0.7);
  static Color white03 = Colors.white.withValues(alpha: 0.3);
  static Color white02 = Colors.white.withValues(alpha: 0.2);

  // Text colors
  static Color text = Colors.white;
  static Color textBlack = Colors.black;
  static Color textBlack87 = Colors.black87;
  static Color textBlack54 = Colors.black54;
  static Color textMuted = Colors.grey.shade600;
}
