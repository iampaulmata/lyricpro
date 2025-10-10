import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:lyricpro_app/core/theme_controller.dart';

class AppTheme {
  const AppTheme({required this.accent});

  final AppAccent accent;

  ThemeData get lightTheme => FlexThemeData.light(
        colors: _scheme(Brightness.light),
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(
          blendOnColors: false,
          navigationBarHeight: 64,
          navigationRailLabelType: NavigationRailLabelType.all,
        ),
      );

  ThemeData get darkTheme => FlexThemeData.dark(
        colors: _scheme(Brightness.dark),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(
          blendOnColors: false,
          navigationBarHeight: 64,
          navigationRailLabelType: NavigationRailLabelType.all,
        ),
      );

  FlexSchemeColor _scheme(Brightness brightness) {
    return FlexSchemeColor.from(
      primary: accent.primaryColor,
      secondary: accent.secondaryColor,
      tertiary: accent.tertiaryColor,
      brightness: brightness,
    );
  }
}
