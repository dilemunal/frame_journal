import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/token_storage.dart';

String _defaultBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8080';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}

dynamic _stringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
    required TokenStorage tokenStorage,
  })  : _baseUrl = baseUrl ?? _defaultBaseUrl(),
        _tokenStorage = tokenStorage,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? _defaultBaseUrl(),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.uri.path.contains('refresh')) {
            return handler.next(options);
          }
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }
          if (_isRefreshing) {
            return handler.next(error);
          }
          final refreshToken = await _tokenStorage.readRefreshToken();
          if (refreshToken == null || refreshToken.isEmpty) {
            return handler.next(error);
          }
          _isRefreshing = true;
          try {
            final res = await _dio.post<dynamic>(
              '/api/auth/refresh',
              data: <String, dynamic>{'refreshToken': refreshToken},
              options: Options(headers: <String, dynamic>{'Authorization': ''}),
            );
            final data = res.data;
            if (data is! Map<String, dynamic>) {
              return handler.next(error);
            }
            final newAccess = _stringOrNull(data['accessToken']) ?? _stringOrNull(data['access_token']);
            final newRefresh = _stringOrNull(data['refreshToken']) ?? _stringOrNull(data['refresh_token']);
            if (newAccess == null || newAccess.isEmpty) {
              return handler.next(error);
            }
            await _tokenStorage.saveTokens(
              accessToken: newAccess,
              refreshToken: newRefresh ?? refreshToken,
            );
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccess';
            final response = await _dio.fetch<dynamic>(opts);
            return handler.resolve(response);
          } catch (_) {
            return handler.next(error);
          } finally {
            _isRefreshing = false;
          }
        },
      ),
    );
  }

  final String _baseUrl;
  final TokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  String get baseUrl => _baseUrl;

  Dio get raw => _dio;

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
