import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../../features/auth/application/auth_notifier.dart';

final AutoDisposeNotifierProvider<AuthNotifier, AuthState> authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  return appRouter(ref);
});

