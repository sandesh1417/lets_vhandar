import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF0A754E);
  static const Color secondary = Color(0xFFF5B237);

  // Brand green gradient for cart buttons/steppers — a brighter green up top
  // fading into a deeper green, giving the controls a glossy, lively look.
  static const Color gradientStart = Color(0xFF16A86A);
  static const Color gradientEnd = Color(0xFF065C3C);
  static const List<Color> primaryGradient = [gradientStart, gradientEnd];

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Colors.black;
  static const Color hintText = Color(0xFF8C9A95);
  static const Color lgrayTxt = Color(0xFF696969);
  static const Color error = Color(0xFFCF6679);
  static const Color greenTxtColor = Color(0xFF1F3A2F);

  // Semi-transparent whites (used for overlays/glass effects).
  // Computed via withValues() so they can't be const — but still immutable.
  static final Color white07 = Colors.white.withValues(alpha: 0.7);
  static final Color white03 = Colors.white.withValues(alpha: 0.3);
  static final Color white02 = Colors.white.withValues(alpha: 0.2);

  // Text colors
  static const Color text = Colors.white;
  static const Color textBlack = Colors.black;
  static const Color textBlack87 = Colors.black87;
  static const Color textBlack54 = Colors.black54;
  static final Color textMuted = Colors.grey.shade600;
}
