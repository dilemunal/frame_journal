import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/token_storage.dart';
import '../network/api_client.dart';
import '../router/app_router.dart';
import '../../features/auth/application/auth_notifier.dart';

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final Provider<TokenStorage> tokenStorageProvider =
    Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final AutoDisposeNotifierProvider<AuthNotifier, AuthState> authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  return appRouter(ref);
});

