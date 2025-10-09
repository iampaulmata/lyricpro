import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme {
  AppTheme({required this.ref});

  final Ref ref;

  static const Color _accent = Color(0xFFFF8A3D);
  static const Color _secondaryAccent = Color(0xFF1EB980);

  ThemeData get lightTheme => FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: _accent,
          primaryContainer: Color(0xFFFFB88A),
          secondary: _secondaryAccent,
          secondaryContainer: Color(0xFFA5F2D2),
          tertiary: Color(0xFF136F63),
        ),
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(
          blendOnColors: false,
          navigationBarHeight: 64,
          navigationRailLabelType: NavigationRailLabelType.all,
        ),
      );

  ThemeData get darkTheme => FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: _accent,
          primaryContainer: Color(0xFF33271F),
          secondary: _secondaryAccent,
          secondaryContainer: Color(0xFF133C30),
          tertiary: Color(0xFF256F6A),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(
          blendOnColors: false,
          navigationBarHeight: 64,
          navigationRailLabelType: NavigationRailLabelType.all,
        ),
      );
}
