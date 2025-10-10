import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricpro_app/core/app_router.dart';
import 'package:lyricpro_app/core/app_theme.dart';
import 'package:lyricpro_app/core/theme_controller.dart';

final _routerProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});

class LyricProApp extends ConsumerWidget {
  const LyricProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final themeState = ref.watch(themeControllerProvider);
    final appTheme = AppTheme(accent: themeState.accent);

    return MaterialApp.router(
      title: 'LyricPro',
      theme: appTheme.lightTheme,
      darkTheme: appTheme.darkTheme,
      themeMode: themeState.mode,
      routerConfig: router.config,
      debugShowCheckedModeBanner: false,
    );
  }
}
