import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
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

    final data = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null;
    if (data == null) throw Exception('Sunucu yanıtı geçersiz.');
    final accessToken = _stringOrNull(data['accessToken']) ?? _stringOrNull(data['access_token']);
    final refreshToken = _stringOrNull(data['refreshToken']) ?? _stringOrNull(data['refresh_token']);
    if (accessToken == null || accessToken.isEmpty || refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Sunucu token döndürmedi.');
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    state = AuthState(isAuthenticated: true, email: email);
  }

  Future<void> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: '325203630340-lcgk3b43a4sbvdl10ud1ra2l38j6ar34.apps.googleusercontent.com',
    );
    // Önbelleklenmiş token bazen sadece iOS client audience ile gelir; yeni token için önce sessiz signOut.
    await googleSignIn.signOut();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Giriş iptal edildi.');
    }

    final auth = await googleUser.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw Exception('Google hesap bilgisi alınamadı. Lütfen tekrar deneyin.');
    }

    try {
      final response = await _apiClient.post(
        '/api/auth/google-login',
        data: <String, dynamic>{'idToken': idToken},
      );

      final data = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null;
      if (data == null) throw Exception('Sunucu yanıtı geçersiz.');
      final accessToken = _stringOrNull(data['accessToken']) ?? _stringOrNull(data['access_token']);
      final refreshToken = _stringOrNull(data['refreshToken']) ?? _stringOrNull(data['refresh_token']);
      if (accessToken == null || accessToken.isEmpty || refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Sunucu token döndürmedi. Lütfen tekrar deneyin.');
      }

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      state = AuthState(isAuthenticated: true, email: googleUser.email);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Google ile giriş başarısız: $e');
    }
  }

  Future<void> loginWithApple() async {
    final response = await _apiClient.post('/api/auth/apple-login');
    final data = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null;
    if (data == null) throw Exception('Sunucu yanıtı geçersiz.');
    final accessToken = _stringOrNull(data['accessToken']) ?? _stringOrNull(data['access_token']);
    final refreshToken = _stringOrNull(data['refreshToken']) ?? _stringOrNull(data['refresh_token']);
    if (accessToken == null || accessToken.isEmpty || refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Sunucu token döndürmedi.');
    }

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
