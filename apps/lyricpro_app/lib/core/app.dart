import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'app_theme.dart';

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

    return MaterialApp.router(
      title: 'LyricPro',
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router.config,
      debugShowCheckedModeBanner: false,
    );
  }
}
