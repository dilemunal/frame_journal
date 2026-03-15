import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'user_email';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveUserId(int? userId) async {
    if (userId == null) {
      await _storage.delete(key: _userIdKey);
    } else {
      await _storage.write(key: _userIdKey, value: userId.toString());
    }
  }

  Future<int?> readUserId() async {
    final value = await _storage.read(key: _userIdKey);
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  Future<void> saveEmail(String? email) async {
    if (email == null || email.isEmpty) {
      await _storage.delete(key: _emailKey);
    } else {
      await _storage.write(key: _emailKey, value: email);
    }
  }

  Future<String?> readEmail() => _storage.read(key: _emailKey);

  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
  }
}
