import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme {
  AppTheme({required this.ref});

  final Ref ref;

  ThemeData get lightTheme => FlexThemeData.light(
        scheme: FlexScheme.indigo,
        useMaterial3: true,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        appBarStyle: FlexAppBarStyle.material,
      );

  ThemeData get darkTheme => FlexThemeData.dark(
        scheme: FlexScheme.indigo,
        useMaterial3: true,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        appBarStyle: FlexAppBarStyle.material,
      );
}
