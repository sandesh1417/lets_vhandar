import 'package:flutter/material.dart';

@immutable
class VhandarColors extends ThemeExtension<VhandarColors> {
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceElevated;
  final Color scaffoldBg;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color onSurfaceFaint;
  final Color strikethrough;
  final Color divider;
  final Color navBarBg;
  final Color navBarBorder;
  final Color inputFill;
  final Color inputBorder;
  final Color inputBorderFocused;
  final Color shimmerBase;
  final Color shimmerHighlight;
  // Semantic state tokens — use these instead of hardcoded Colors.red/green/etc.
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color danger;
  final Color dangerBg;
  final Color disabledBg;
  final Color disabledFg;
  final Color outOfStockBg;
  final Color outOfStockFg;

  const VhandarColors({
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceElevated,
    required this.scaffoldBg,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceFaint,
    required this.strikethrough,
    required this.divider,
    required this.navBarBg,
    required this.navBarBorder,
    required this.inputFill,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.danger,
    required this.dangerBg,
    required this.disabledBg,
    required this.disabledFg,
    required this.outOfStockBg,
    required this.outOfStockFg,
  });

  static const light = VhandarColors(
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
    surfaceElevated: Color(0xFFFFFFFF),
    scaffoldBg: Color(0xFFF5F5F5),
    onSurface: Color(0xFF1A1A1A),
    onSurfaceMuted: Color(0xFF757575),
    onSurfaceFaint: Color(0xFF9E9E9E),
    strikethrough: Color(0xFF9E9E9E),
    divider: Color(0xFFF0F0F0),
    // navBarBg: Color(0xFFEFF7F2),
    // // navBarBg: Color(0xFFFFFFFF),
    // navBarBorder: Color(0xFFDDDDDD),
    navBarBg: Color(0xE1FFFFFF),
    navBarBorder: Color(0x99FFFFFF),

    inputFill: Color(0xFFFFFFFF),
    inputBorder: Color(0xFFE0E0E0),
    inputBorderFocused: Color(0xFF0A754E),
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
    success: Color(0xFF2E7D32),
    successBg: Color(0xFFE8F5E9),
    warning: Color(0xFFEF6C00),
    warningBg: Color(0xFFFFF3E0),
    danger: Color(0xFFD32F2F),
    dangerBg: Color(0xFFFFEBEE),
    disabledBg: Color(0xFFE0E0E0),
    disabledFg: Color(0xFF9E9E9E),
    outOfStockBg: Color(0xFFEEEEEE),
    outOfStockFg: Color(0xFF9E9E9E),
  );

  // Premium LAYERED dark palette. The whole point is visible separation between
  // tiers — each surface step is distinctly lighter than the one below it, so
  // depth comes from lightness (elevation-by-lightness), not drop shadows:
  //   scaffoldBg #1A1D21  →  surface #25292E  →  surfaceElevated #2D3239
  //   →  surfaceVariant/input #2F353C.
  // Background is a soft charcoal (never pure #000), text is off-white (never
  // pure #FFF), and hairlines are kept very subtle.
  static const dark = VhandarColors(
    // L1 — cards, product tiles (clearly above the scaffold).
    surface: Color(0xFF25292E),
    // L3 — fields, chips, quantity steppers, selected states (the lightest
    // resting surface; "surfaceInput" in the spec).
    surfaceVariant: Color(0xFF2F353C),
    // L2 — bottom sheets, modals, raised footers.
    surfaceElevated: Color(0xFF2D3239),
    // L0 — darkest base, soft charcoal, NOT pure black.
    scaffoldBg: Color(0xFF1A1D21),
    // Off-white primary text (high emphasis).
    onSurface: Color(0xFFF2F4F6),
    // Muted secondary — subtitles, weight, delivery time.
    onSurfaceMuted: Color(0xFFA2A8B0),
    // Tertiary / disabled.
    onSurfaceFaint: Color(0xFF6C737C),
    // Struck-through MRP.
    strikethrough: Color(0xFF7E858E),
    // Subtle hairline.
    divider: Color(0xFF3A4048),

    navBarBg: Color(0xE02D3239),
    navBarBorder: Color(0x14FFFFFF),

    inputFill: Color(0xFF2F353C),
    inputBorder: Color(0xFF3A4048),
    inputBorderFocused: Color(0xFF43B85C),
    shimmerBase: Color(0xFF2D3239),
    shimmerHighlight: Color(0xFF3A4048),
    success: Color(0xFF66BB6A),
    successBg: Color(0xFF1B3A24),
    warning: Color(0xFFFFB74D),
    warningBg: Color(0xFF3A2E1A),
    danger: Color(0xFFEF9A9A),
    dangerBg: Color(0xFF4A1F1F),
    disabledBg: Color(0xFF3A4048),
    disabledFg: Color(0xFF6C737C),
    outOfStockBg: Color(0xFF2F353C),
    outOfStockFg: Color(0xFF7E858E),
  );

  @override
  VhandarColors copyWith({
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceElevated,
    Color? scaffoldBg,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? onSurfaceFaint,
    Color? strikethrough,
    Color? divider,
    Color? navBarBg,
    Color? navBarBorder,
    Color? inputFill,
    Color? inputBorder,
    Color? inputBorderFocused,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? danger,
    Color? dangerBg,
    Color? disabledBg,
    Color? disabledFg,
    Color? outOfStockBg,
    Color? outOfStockFg,
  }) {
    return VhandarColors(
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      onSurfaceFaint: onSurfaceFaint ?? this.onSurfaceFaint,
      strikethrough: strikethrough ?? this.strikethrough,
      divider: divider ?? this.divider,
      navBarBg: navBarBg ?? this.navBarBg,
      navBarBorder: navBarBorder ?? this.navBarBorder,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      inputBorderFocused: inputBorderFocused ?? this.inputBorderFocused,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      danger: danger ?? this.danger,
      dangerBg: dangerBg ?? this.dangerBg,
      disabledBg: disabledBg ?? this.disabledBg,
      disabledFg: disabledFg ?? this.disabledFg,
      outOfStockBg: outOfStockBg ?? this.outOfStockBg,
      outOfStockFg: outOfStockFg ?? this.outOfStockFg,
    );
  }

  @override
  VhandarColors lerp(VhandarColors? other, double t) {
    if (other is! VhandarColors) return this;
    return VhandarColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      onSurfaceFaint: Color.lerp(onSurfaceFaint, other.onSurfaceFaint, t)!,
      strikethrough: Color.lerp(strikethrough, other.strikethrough, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      navBarBorder: Color.lerp(navBarBorder, other.navBarBorder, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputBorderFocused:
          Color.lerp(inputBorderFocused, other.inputBorderFocused, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
      disabledBg: Color.lerp(disabledBg, other.disabledBg, t)!,
      disabledFg: Color.lerp(disabledFg, other.disabledFg, t)!,
      outOfStockBg: Color.lerp(outOfStockBg, other.outOfStockBg, t)!,
      outOfStockFg: Color.lerp(outOfStockFg, other.outOfStockFg, t)!,
    );
  }
}

extension VhandarColorsX on BuildContext {
  VhandarColors get vColors =>
      Theme.of(this).extension<VhandarColors>() ?? VhandarColors.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
