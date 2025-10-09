import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lyricpro_app/features/editor/presentation/editor_screen.dart';
import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';
import 'package:lyricpro_app/features/setlists/presentation/setlist_screen.dart';
import 'package:lyricpro_app/features/settings/presentation/settings_screen.dart';
import 'package:lyricpro_app/features/shared/sample_data.dart';
import 'package:lyricpro_app/features/splash/presentation/splash_screen.dart';

class AppRouter {
  AppRouter({required this.ref});

  final Ref ref;

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
        path: '/setlist',
        name: SetlistScreen.routeName,
        builder: (context, state) {
          final setList = state.extra as SampleSetList? ?? sampleSetLists.first;
          return SetlistScreen(setList: setList);
        },
      ),
      GoRoute(
        path: '/editor',
        name: EditorScreen.routeName,
        builder: (context, state) {
          final song = state.extra as SampleSong? ?? sampleSongs.first;
          return EditorScreen(song: song);
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
