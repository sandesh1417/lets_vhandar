import 'package:flutter/material.dart';

@immutable
class VhandarColors extends ThemeExtension<VhandarColors> {
  final Color surface;
  final Color surfaceVariant;
  final Color scaffoldBg;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color divider;
  final Color navBarBg;
  final Color navBarBorder;
  final Color inputFill;
  final Color inputBorder;
  final Color inputBorderFocused;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const VhandarColors({
    required this.surface,
    required this.surfaceVariant,
    required this.scaffoldBg,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.divider,
    required this.navBarBg,
    required this.navBarBorder,
    required this.inputFill,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const light = VhandarColors(
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
    scaffoldBg: Color(0xFFF5F5F5),
    onSurface: Color(0xFF1A1A1A),
    onSurfaceMuted: Color(0xFF757575),
    divider: Color(0xFFF0F0F0),
    navBarBg: Color(0xE1FFFFFF),
    navBarBorder: Color(0x99FFFFFF),
    inputFill: Color(0xFFFFFFFF),
    inputBorder: Color(0xFFE0E0E0),
    inputBorderFocused: Color(0xFF0A754E),
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
  );

  static const dark = VhandarColors(
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2A2A2A),
    scaffoldBg: Color(0xFF121212),
    onSurface: Color(0xFFF0F0F0),
    onSurfaceMuted: Color(0xFF9E9E9E),
    divider: Color(0xFF2C2C2C),
    navBarBg: Color(0xE01A1A1A),
    navBarBorder: Color(0x40FFFFFF),
    inputFill: Color(0xFF1E1E1E),
    inputBorder: Color(0xFF3A3A3A),
    inputBorderFocused: Color(0xFF0A754E),
    shimmerBase: Color(0xFF2A2A2A),
    shimmerHighlight: Color(0xFF3A3A3A),
  );

  @override
  VhandarColors copyWith({
    Color? surface,
    Color? surfaceVariant,
    Color? scaffoldBg,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? divider,
    Color? navBarBg,
    Color? navBarBorder,
    Color? inputFill,
    Color? inputBorder,
    Color? inputBorderFocused,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return VhandarColors(
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      divider: divider ?? this.divider,
      navBarBg: navBarBg ?? this.navBarBg,
      navBarBorder: navBarBorder ?? this.navBarBorder,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      inputBorderFocused: inputBorderFocused ?? this.inputBorderFocused,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  VhandarColors lerp(VhandarColors? other, double t) {
    if (other is! VhandarColors) return this;
    return VhandarColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      navBarBorder: Color.lerp(navBarBorder, other.navBarBorder, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputBorderFocused:
          Color.lerp(inputBorderFocused, other.inputBorderFocused, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

extension VhandarColorsX on BuildContext {
  VhandarColors get vColors =>
      Theme.of(this).extension<VhandarColors>() ?? VhandarColors.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
