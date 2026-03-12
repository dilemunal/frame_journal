import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/core_providers.dart';

class AuthState {
  const AuthState({required this.isAuthenticated, this.email});

  final bool isAuthenticated;
  final String? email;

  AuthState copyWith({bool? isAuthenticated, String? email}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  late final ApiClient _apiClient;
  late final TokenStorage _tokenStorage;

  @override
  AuthState build() {
    _apiClient = ref.read(apiClientProvider);
    _tokenStorage = ref.read(tokenStorageProvider);
    return const AuthState(isAuthenticated: false);
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final previous = state;
    state = previous.copyWith(); // trigger listeners

    final response = await _apiClient.post(
      '/api/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    state = AuthState(isAuthenticated: true, email: email);
  }

  Future<void> loginWithGoogle() async {
    final response = await _apiClient.post('/api/auth/google-login');
    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    state = state.copyWith(isAuthenticated: true);
  }

  Future<void> loginWithApple() async {
    final response = await _apiClient.post('/api/auth/apple-login');
    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    state = state.copyWith(isAuthenticated: true);
  }
}

final AutoDisposeNotifierProvider<AuthNotifier, AuthState>
authNotifierProvider = AutoDisposeNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
