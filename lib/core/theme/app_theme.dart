import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

const _seed = Color(0xFF0A754E);

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    final base = FlexThemeData.light(
      colors: FlexSchemeColor.from(primary: _seed),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 4,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 8,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
    return base.copyWith(
      scaffoldBackgroundColor: VhandarColors.light.scaffoldBg,
      cardColor: VhandarColors.light.surface,
      cardTheme: base.cardTheme.copyWith(
        color: VhandarColors.light.surface,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: const [VhandarColors.light],
    );
  }

  static ThemeData get darkTheme {
    final base = FlexThemeData.dark(
      colors: FlexSchemeColor.from(primary: _seed),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 10,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 15,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
    return base.copyWith(
      scaffoldBackgroundColor: VhandarColors.dark.scaffoldBg,
      cardColor: VhandarColors.dark.surface,
      cardTheme: base.cardTheme.copyWith(
        color: VhandarColors.dark.surface,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: const [VhandarColors.dark],
    );
  }
}
