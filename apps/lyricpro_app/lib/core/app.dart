import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricpro_app/core/app_router.dart';
import 'package:lyricpro_app/core/app_theme.dart';
import 'package:lyricpro_app/core/theme_controller.dart';

final _routerProvider = Provider<AppRouter>((ref) {
  return AppRouter(ref: ref);
});

final _themeProvider = Provider<AppTheme>((ref) {
  return AppTheme(ref: ref);
});

class LyricProApp extends ConsumerWidget {
  const LyricProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(_themeProvider);
    final router = ref.watch(_routerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'LyricPro',
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: themeMode,
      routerConfig: router.config,
      debugShowCheckedModeBanner: false,
    );
  }
}
