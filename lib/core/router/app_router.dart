import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/entry/presentation/entry_detail_screen.dart';
import '../../features/entry/presentation/entry_screen.dart';
import '../../features/hafiza/presentation/hafiza_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/ritim/presentation/ritim_screen.dart';
import '../../features/templates/presentation/template_builder_screen.dart';
import 'main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, __) => notifyListeners());
  }
}

GoRouter appRouter(Ref ref) {
  final authListenable = _AuthListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authListenable,
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final loggingIn = state.matchedLocation == '/login';
      if (!auth.isAuthenticated) return loggingIn ? null : '/login';
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
        path: '/entry/new',
        name: 'entryNew',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final templateId = int.tryParse(state.uri.queryParameters['templateId'] ?? '');
          final child = EntryScreen(
            templateId: (templateId != null && templateId > 0) ? templateId : null,
          );
          return CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 220),
            reverseTransitionDuration: const Duration(milliseconds: 180),
            child: child,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/entry/:id',
        name: 'entryDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null || id <= 0) {
            return const Scaffold(
              body: Center(child: Text('Geçersiz giriş.')),
            );
          }
          return EntryDetailScreen(entryId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'templates/builder',
                    name: 'templateBuilder',
                    builder: (context, state) =>
                        const TemplateBuilderScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/ritim',
                name: 'ritim',
                builder: (context, state) => const RitimScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/hafiza',
                name: 'hafiza',
                builder: (context, state) => const HafizaScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
