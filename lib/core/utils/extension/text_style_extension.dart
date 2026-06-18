import 'package:flutter/material.dart';

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700, letterSpacing: 0);
  TextStyle get semibold =>
      copyWith(fontWeight: FontWeight.w600, letterSpacing: 0);
  TextStyle get medium =>
      copyWith(fontWeight: FontWeight.w500, letterSpacing: 0);
  TextStyle get regular =>
      copyWith(fontWeight: FontWeight.w400, letterSpacing: 0);

  TextStyle get italic =>
      copyWith(fontStyle: FontStyle.italic, letterSpacing: 0);
  TextStyle get underlined =>
      copyWith(decoration: TextDecoration.underline, letterSpacing: 0);

  TextStyle withColor(Color color) => copyWith(color: color, letterSpacing: 0);
  TextStyle withSize(double size) => copyWith(fontSize: size, letterSpacing: 0);
}
