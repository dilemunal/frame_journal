import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/auth/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/core_providers.dart';

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    this.email,
    this.userId,
  });

  final bool isAuthenticated;
  final String? email;
  final int? userId;

  AuthState copyWith({
    bool? isAuthenticated,
    String? email,
    int? userId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      userId: userId ?? this.userId,
    );
  }
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

class AuthNotifier extends Notifier<AuthState> {
  late final ApiClient _apiClient;
  late final TokenStorage _tokenStorage;

  @override
  AuthState build() {
    _apiClient = ref.read(apiClientProvider);
    _tokenStorage = ref.read(tokenStorageProvider);
    _checkPersistedLogin();
    return const AuthState(isAuthenticated: false);
  }

  Future<void> _checkPersistedLogin() async {
    final token = await _tokenStorage.readAccessToken();
    final userId = await _tokenStorage.readUserId();
    final email = await _tokenStorage.readEmail();
    if (token != null && token.isNotEmpty) {
      state = AuthState(
        isAuthenticated: true,
        email: email,
        userId: userId,
      );
    }
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

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : null;
    if (data == null) throw Exception('Sunucu yanıtı geçersiz.');
    final accessToken =
        _stringOrNull(data['accessToken']) ??
        _stringOrNull(data['access_token']);
    final refreshToken =
        _stringOrNull(data['refreshToken']) ??
        _stringOrNull(data['refresh_token']);
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw Exception('Sunucu token döndürmedi.');
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final userObj = data['user'] as Map<String, dynamic>?;
    final userId = userObj?['id'] as int?;
    await _tokenStorage.saveUserId(userId);
    await _tokenStorage.saveEmail(email);

    state = AuthState(
      isAuthenticated: true,
      email: email,
      userId: userId,
    );
  }

  Future<void> loginWithGoogle() async {
    final serverClientId = const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
      defaultValue:
          '325203630340-2i6816d9hg3nj445cjitdtbflrt5oi06.apps.googleusercontent.com',
    );
    final googleSignIn = GoogleSignIn(serverClientId: serverClientId);
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

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;
      if (data == null) throw Exception('Sunucu yanıtı geçersiz.');
      final accessToken =
          _stringOrNull(data['accessToken']) ??
          _stringOrNull(data['access_token']);
      final refreshToken =
          _stringOrNull(data['refreshToken']) ??
          _stringOrNull(data['refresh_token']);
      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        throw Exception('Sunucu token döndürmedi. Lütfen tekrar deneyin.');
      }

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final userObj = data['user'] as Map<String, dynamic>?;
      final userId = userObj?['id'] as int?;
      await _tokenStorage.saveUserId(userId);
      await _tokenStorage.saveEmail(googleUser.email);

      state = AuthState(
        isAuthenticated: true,
        email: googleUser.email,
        userId: userId,
      );
      assert(() {
        // ignore: avoid_print
        print(
          '[AuthNotifier] Google login OK, state.isAuthenticated=${state.isAuthenticated}',
        );
        return true;
      }());
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('[AuthNotifier] Google login FAIL: $e');
        // ignore: avoid_print
        print(st);
        return true;
      }());
      if (e is Exception) rethrow;
      throw Exception('Google ile giriş başarısız: $e');
    }
  }

  Future<void> loginWithApple() async {
    final response = await _apiClient.post('/api/auth/apple-login');
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : null;
    if (data == null) throw Exception('Sunucu yanıtı geçersiz.');
    final accessToken =
        _stringOrNull(data['accessToken']) ??
        _stringOrNull(data['access_token']);
    final refreshToken =
        _stringOrNull(data['refreshToken']) ??
        _stringOrNull(data['refresh_token']);
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw Exception('Sunucu token döndürmedi.');
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    state = state.copyWith(isAuthenticated: true);
  }

  Future<void> logout() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}

    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      try {
        await _apiClient.post(
          '/api/auth/logout',
          options: Options(
            headers: <String, dynamic>{'Authorization': 'Bearer $token'},
          ),
        );
      } catch (_) {}
    }

    await _tokenStorage.clearAll();
    state = const AuthState(isAuthenticated: false);
  }
}

/// AutoDispose kullanmıyoruz: await sırasında dispose olup state kaybolmasın, router redirect doğru görsün.
final NotifierProvider<AuthNotifier, AuthState> authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
