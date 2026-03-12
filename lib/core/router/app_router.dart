import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final loggingIn = state.matchedLocation == '/login';

      if (!auth.isAuthenticated) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) return '/';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
