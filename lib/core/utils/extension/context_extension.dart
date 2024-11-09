import 'package:flutter/material.dart';

//*  BUILDCONTEXT EXTENSIONS *//
extension ContextExtension on BuildContext {
  // text theme context
  TextTheme get textThemeContext => Theme.of(this).textTheme;

  // app color context
  ColorScheme get appColorContext => Theme.of(this).colorScheme;

  // get screen full height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // get screen full width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  // Extension method on BuildContext for viewInsets
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}
