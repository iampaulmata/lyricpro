import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lyricpro_app/features/editor/presentation/editor_screen.dart';
import 'package:lyricpro_app/features/library/presentation/library_screen.dart';
import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';
import 'package:lyricpro_app/features/setlists/presentation/setlist_screen.dart';
import 'package:lyricpro_app/features/settings/presentation/settings_screen.dart';
import 'package:lyricpro_app/features/splash/presentation/splash_screen.dart';
import 'package:lyricpro_app/features/auth/presentation/login_screen.dart';

class AppRouter {
  AppRouter();

  late final GoRouter config = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: DashboardScreen.routeName,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/library',
        name: LibraryScreen.routeName,
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/setlist',
        name: SetlistScreen.routeName,
        builder: (context, state) {
          final setlistId = state.extra is String
              ? state.extra as String
              : state.uri.queryParameters['id'];
          if (setlistId == null) {
            return const Scaffold(
              body: Center(child: Text('Missing set list identifier')),
            );
          }
          return SetlistScreen(setListId: setlistId);
        },
      ),
      GoRoute(
        path: '/editor',
        name: EditorScreen.routeName,
        builder: (context, state) {
          final songId = state.extra is String
              ? state.extra as String
              : state.uri.queryParameters['id'];
          if (songId == null) {
            return const Scaffold(
              body: Center(child: Text('Missing song identifier')),
            );
          }
          return EditorScreen(songId: songId);
        },
      ),
      GoRoute(
        path: '/performance',
        name: PerformanceScreen.routeName,
        builder: (context, state) => const PerformanceScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: SettingsScreen.routeName,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
