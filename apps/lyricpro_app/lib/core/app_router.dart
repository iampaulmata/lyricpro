import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';

class AppRouter {
  AppRouter({required this.ref});

  final Ref ref;

  late final GoRouter config = GoRouter(
    debugLogDiagnostics: false,
    observers: <NavigatorObserver>[],
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
